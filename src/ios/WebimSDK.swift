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

    func onMessage(_ command: CDVInvokedUrlCommand) {
        onMessageCallbackId = command.callbackId
    }

    func onTyping(_ command: CDVInvokedUrlCommand) {
        onTypingCallbackId = command.callbackId
    }

    func onConfirm(_ command: CDVInvokedUrlCommand) {
        onConfirmCallbackId = command.callbackId
    }

    func onFile(_ command: CDVInvokedUrlCommand) {
        onFileCallbackId = command.callbackId
    }

    func onBan(_ command: CDVInvokedUrlCommand) {
        onBanCallbackId = command.callbackId
    }

    func onDialog(_ command: CDVInvokedUrlCommand) {
        onDialogCallbackId = command.callbackId
    }

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

    func typingMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let userMessage = command.arguments[0] as? String

        do {
            try session?.getStream().setVisitorTyping(draftMessage: userMessage?.count == 0 ? nil : userMessage)
        } catch { }
        sendCallbackResult(callbackId: callbackId!)
    }

    func requestDialog(_ command: CDVInvokedUrlCommand) {
        do {
            try session?.getStream().startChat()
            sendCallbackResult(callbackId: command.callbackId!)
        } catch { }
    }

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

    func sendFile(_ command: CDVInvokedUrlCommand) {
        onFileMessageErrorCallbackId = command.callbackId
        let url = URL(string: (command.arguments[0] as? String)!)
        var fileName = url!.lastPathComponent
        var mimeType = MimeType(url: url!)

        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
        if let phAsset = fetchResult.firstObject {
            PHImageManager.default().requestImageData(for: phAsset, options: nil) {
                (imageData, dataURI, orientation, info) -> Void in
                if var imageData = imageData {
                    let imageExtension = url!.pathExtension.lowercased()
                    let image = UIImage(data: imageData)!
                    if imageExtension == "jpg" || imageExtension == "jpeg" {
                        imageData = UIImageJPEGRepresentation(image, 1.0)!
                    } else if imageExtension == "heic" || imageExtension == "heif" {
                        imageData = UIImageJPEGRepresentation(image, 0.5)!
                        mimeType = MimeType()
                        var components = fileName.components(separatedBy: ".")
                        if components.count > 1 {
                            components.removeLast()
                            fileName = components.joined(separator: ".")
                        }
                        fileName += ".jpeg"
                    } else {
                        imageData = UIImagePNGRepresentation(image)!
                    }
                    do {
                        try _ = self.session?.getStream().send(file: imageData,
                                                               filename: fileName,
                                                               mimeType: mimeType.value,
                                                               completionHandler: self)
                    } catch { }
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
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")
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
        self.commandDelegate!.send(pluginResult, callbackId: onFatalErrorCallbackId)
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
