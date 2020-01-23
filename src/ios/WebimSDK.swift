import Photos

@objc(WebimSDK) class WebimSDK : CDVPlugin {
    private var session: WebimSession?
    private var messageTracker: MessageTracker?
    var onMessageCallbackId: String?
    var onTypingCallbackId: String?
    var onFileCallbackId: String?
    var onBanCallbackId: String?
    var onDialogCallbackId: String?
    var onFileMessageErrorCallbackId: String?
    var onConfirmCallbackId: String?
    var onFatalErrorCallbackId: String?


    @objc(init:)
    func `init`(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        let callbackId = command.callbackId
        onFatalErrorCallbackId = callbackId
        let args = command.arguments[0] as! NSDictionary
        let accountName = args["accountName"] as? String
        let location = args["location"] as? String
        let deviceToken = args["pushToken"] as? String
        if let accountName = accountName {
            var sessionBuilder = Webim.newSessionBuilder()
                .set(accountName: accountName)
                .set(location: location ?? "mobile")
                .set(fatalErrorHandler: self)
                .set(remoteNotificationSystem: ((deviceToken != nil) ? .APNS : .NONE))
                .set(deviceToken: deviceToken)
                .set(isLocalHistoryStoragingEnabled: false)
            if let visitorFields = args["visitorFields"] as? NSDictionary {
                let jsonData = try? JSONSerialization.data(withJSONObject: visitorFields, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                if let jsonString = jsonString {
                    sessionBuilder = sessionBuilder.set(visitorFieldsJSONString: jsonString)
                }
            }
            do {
                session = try sessionBuilder.build()
                session?.getStream().set(operatorTypingListener:self)
                session?.getStream().set(currentOperatorChangeListener: self)
                try messageTracker = session?.getStream().newMessageTracker(messageListener: self)
                try session?.resume()
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
            } catch { }
        }
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(
            pluginResult,
            callbackId: callbackId
        )
    }

    @objc(onMessage:)
    func onMessage(_ command: CDVInvokedUrlCommand) {
        onMessageCallbackId = command.callbackId
    }

    @objc(onTyping:)
    func onTyping(_ command: CDVInvokedUrlCommand) {
        onTypingCallbackId = command.callbackId
    }

    @objc(onConfirm:)
    func onConfirm(_ command: CDVInvokedUrlCommand) {
        onConfirmCallbackId = command.callbackId
    }

    @objc(onFile:)
    func onFile(_ command: CDVInvokedUrlCommand) {
        onFileCallbackId = command.callbackId
    }

    @objc(onBan:)
    func onBan(_ command: CDVInvokedUrlCommand) {
        onBanCallbackId = command.callbackId
    }

    @objc(onDialog:)
    func onDialog(_ command: CDVInvokedUrlCommand) {
        onDialogCallbackId = command.callbackId
    }

    @objc(close:)
    func close(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        if session != nil {
            do {
                try session?.destroy()
            } catch { }
            session = nil
            onMessageCallbackId = nil
            onTypingCallbackId = nil
            onFileCallbackId = nil
            onBanCallbackId = nil
            onDialogCallbackId = nil
            onFileMessageErrorCallbackId = nil
            sendCallbackResult(callbackId: callbackId!)
        } else {
            sendCallbackError(callbackId: callbackId!)
        }
    }

    @objc(getMessagesHistory:)
    func getMessagesHistory(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let limit = command.arguments[0] as? Int
        let offset = command.arguments[1] as? Int
        var messagesSDK = [[String: Any]]()
        let completionHandler: ([Message]) -> () = { [weak self] messages in
            for message in messages {
                messagesSDK.append((self?.messageToDictionary(message: message))!)
            }
            self?.sendCallbackResult(callbackId: callbackId!, resultArray: messagesSDK)
        }
        if offset == 0 {
            do {
                try messageTracker?.getLastMessages(byLimit: limit ?? 25, completion: completionHandler)
            } catch { }
        } else {
            do {
                try messageTracker?.getNextMessages(byLimit: limit ?? 25, completion: completionHandler)
            } catch { }
        }
    }

    @objc(typingMessage:)
    func typingMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let userMessage = command.arguments[0] as? String

        do {
            try session?.getStream().setVisitorTyping(draftMessage: userMessage?.count == 0 ? nil : userMessage)
        } catch { }
        sendCallbackResult(callbackId: callbackId!)
    }

    @objc(requestDialog:)
    func requestDialog(_ command: CDVInvokedUrlCommand) {
        do {
            try session?.getStream().startChat()
            sendCallbackResult(callbackId: command.callbackId!)
        } catch { }
    }

    @objc(sendMessage:)
    func sendMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let userMessage = command.arguments[0]
        var messageID: String?
        do {
            try messageID = session?.getStream().send(message: userMessage as! String)
        } catch { }
        let message = messageToJSON(id: messageID ?? "error", text: userMessage as! String, url: nil, timestamp: String(Int64(NSDate().timeIntervalSince1970 * 1000)), sender: nil)
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    @objc(sendFile:)
    func sendFile(_ command: CDVInvokedUrlCommand) {
        onFileMessageErrorCallbackId = command.callbackId
        guard let url = URL(string: (command.arguments[0] as? String)!), let session = session else {
            return
        }

        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        if let phAsset = fetchResult.firstObject {
            PHImageManager.default().requestImageData(for: phAsset, options: nil) {
                (imageData, dataURI, orientation, info) -> Void in
                if let imageData = imageData {
                    let file = WebimFile(url: url, data: imageData)
                    file.send(session: session, completionHandler: self) { error in
                        if let error = error {
                            print("Error while sending a file: \(error).")
                        }
                    }
                }
            }
        } else if let data = try? Data(contentsOf: url) {
            let file = WebimFile(url: url, data: data)
            file.send(session: session, completionHandler: self) { error in
                if let error = error {
                    print("Error while sending a file: \(error).")
                }
            }
        }
    }

    private func sendCallbackResult(callbackId: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    private func sendCallbackResult(callbackId: String, resultDictionary: Dictionary<AnyHashable, Any>) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultDictionary)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    private func sendCallbackResult(callbackId: String, resultArray: [Any]) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: resultArray)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    private func sendCallbackError(callbackId: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    private func sendCallbackError(callbackId: String, error: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }

    func messageToJSON(message: Message) -> String {
        let dict = messageToDictionary(message: message)
        if let JSONData = try? JSONSerialization.data(withJSONObject: dict,
                                                      options: .prettyPrinted),
            let JSONText = String(data: JSONData, encoding: String.Encoding.utf8) {
            return JSONText
        }
        return "";
    }

    func messageToDictionary(message: Message) -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = message.getID()
        dict["text"] = message.getText()
        if let attachment = message.getAttachment() {
            dict["url"] = (attachment.getURL()).absoluteString
            if let imageInfo = attachment.getImageInfo() {
                dict["thumbUrl"] = (imageInfo.getThumbURL()).absoluteString
                dict["imageWidth"] = imageInfo.getWidth()
                dict["imageHeight"] = imageInfo.getHeight()
            }
        }
        if message.getType() != .FILE_FROM_OPERATOR && message.getType() != .OPERATOR {
            dict["sender"] = message.getSenderName()
        } else {
            var `operator` = [String: String]()
            `operator`["firstname"] = message.getSenderName()
            `operator`["avatar"] = message.getSenderAvatarFullURL()?.absoluteString
            dict["operator"] = `operator`
        }
        dict["timestamp"] = String(message.getTime().timeIntervalSince1970 * 1000)
        return dict;
    }

    func messageToJSON(id: String,
                       text: String,
                       url: String?,
                       timestamp: String,
                       sender: String?) -> String {
        var dict = [String: String]()
        dict["id"] = id
        dict["text"] = text
        dict["url"] = url
        dict["sender"] = sender
        dict["timestamp"] = timestamp
        if let JSONData = try? JSONSerialization.data(withJSONObject: dict,
                                                      options: .prettyPrinted),
            let JSONText = String(data: JSONData, encoding: String.Encoding.utf8) {
            return JSONText
        }
        return "";
    }

    func dialogStateToJSON(op: Operator?) -> String {
        var dict = [String: Any]()
        var employee = [String: String]()
        employee["id"] = op?.getID()
        employee["firstname"] = op?.getName()
        employee["avatar"] = op?.getAvatarURL()?.absoluteString
        dict["employee"] = employee

        if let JSONData = try? JSONSerialization.data(withJSONObject: dict,
                                                      options: .prettyPrinted),
            let JSONText = String(data: JSONData, encoding: String.Encoding.utf8) {
            return JSONText
        }
        return "";
    }
}

extension WebimSDK : OperatorTypingListener {
    func onOperatorTypingStateChanged(isTyping: Bool) {
        if let onTypingCallbackId = onTypingCallbackId {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: isTyping)
            pluginResult?.setKeepCallbackAs(true)
            self.commandDelegate!.send(pluginResult, callbackId: onTypingCallbackId)
        }
    }
}

extension WebimSDK: MessageListener {
    func added(message newMessage: Message, after previousMessage: Message?) {
        if newMessage.getType() != MessageType.FILE_FROM_OPERATOR
            && newMessage.getType() != MessageType.FILE_FROM_VISITOR {
            if onMessageCallbackId != nil && newMessage.getType() != .VISITOR {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToJSON(message: newMessage))
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onMessageCallbackId)
            }
        } else {
            if let onFileCallbackId = onFileCallbackId {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToJSON(message: newMessage))
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onFileCallbackId)
            }
        }
    }

    func removed(message: Message) {

    }

    func removedAllMessages() {

    }

    func changed(message oldVersion: Message, to newVersion: Message) {
        if newVersion.getType() != MessageType.FILE_FROM_OPERATOR
            && newVersion.getType() != MessageType.FILE_FROM_VISITOR {
            if let onConfirmCallbackId = onConfirmCallbackId {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToJSON(message: newVersion))
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onConfirmCallbackId)
            }
        } else {
            if let onFileCallbackId = onFileCallbackId {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToJSON(message: newVersion))
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onFileCallbackId)
            }
        }
    }
}

extension WebimSDK : FatalErrorHandler {
    func on(error: WebimError) {
        let errorType = error.getErrorType()
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true)
        pluginResult?.setKeepCallbackAs(true)
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(errorPluginResult, callbackId: onFatalErrorCallbackId)
        switch errorType {
        case .ACCOUNT_BLOCKED:
            self.commandDelegate!.send(pluginResult, callbackId: onBanCallbackId)
            break
        case .PROVIDED_VISITOR_FIELDS_EXPIRED:
            break
        case .UNKNOWN:
            break
        case .VISITOR_BANNED:
            self.commandDelegate!.send(pluginResult, callbackId: onBanCallbackId)
            break
        case .WRONG_PROVIDED_VISITOR_HASH:
            break
        }
    }
}

extension WebimSDK : SendFileCompletionHandler {
    func onSuccess(messageID: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onFileMessageErrorCallbackId)
    }

    func onFailure(messageID: String, error: SendFileError) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onFileMessageErrorCallbackId)
    }

}

extension WebimSDK : CurrentOperatorChangeListener {
    func changed(operator previousOperator: Operator?, to newOperator: Operator?) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: dialogStateToJSON(op: newOperator))
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onDialogCallbackId)
    }
}

class WebimFile {
    
    let data: Data
    let fileName: String
    let mimeType: MimeType
    let url: URL
    
    init(url fileUrl: URL, data fileData: Data) {
        self.data = fileData
        self.fileName = fileUrl.lastPathComponent
        self.mimeType = MimeType(url: fileUrl)
        self.url = fileUrl
    }
    
    private func sendInternal(session: WebimSession,
              completionHandler: SendFileCompletionHandler?,
              completion: @escaping (Error?) -> Void) {
        
        var resultData = self.data
            var resultMimeType = self.mimeType
        var resultFileName = self.fileName
        
        if (isImage(contentType: self.mimeType.value)) {
            let imageExtension = self.url.pathExtension.lowercased()
            let image = UIImage(data: self.data)!
            if imageExtension == "jpg" || imageExtension == "jpeg" {
                resultData = UIImageJPEGRepresentation(image, 1.0)!
            } else if imageExtension == "heic" || imageExtension == "heif" {
                resultData = UIImageJPEGRepresentation(image, 0.5)!
                resultMimeType = MimeType()
                var components = self.fileName.components(separatedBy: ".")
                if components.count > 1 {
                    components.removeLast()
                    resultFileName = components.joined(separator: ".")
                }
                resultFileName += ".jpeg"
            } else {
                resultData = UIImagePNGRepresentation(image)!
            }
        }
        
        // Run in main thread to prevent INVALID_THREAD error
        DispatchQueue.main.async {
            do {
                try _ = session.getStream().send(file: resultData,
                                                 filename: resultFileName,
                                                 mimeType: resultMimeType.value,
                                                 completionHandler: completionHandler)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func send(session: WebimSession,
              completionHandler: SendFileCompletionHandler?,
              completion: @escaping (Error?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendInternal(session: session,
                              completionHandler: completionHandler,
                              completion: completion)
        }
    }
}
