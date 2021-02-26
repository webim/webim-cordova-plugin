import Photos

@objc(WebimSDK) class WebimSDK : CDVPlugin {
    
    private var session: WebimSession?
    private var messageTracker: MessageTracker?
    private var closeWithClearVisitorData = false
    var onMessageCallbackId: String?
    var onTypingCallbackId: String?
    var onFileCallbackId: String?
    var onBanCallbackId: String?
    var onDialogCallbackId: String?
    var onFileMessageErrorCallbackId: String?
    var onConfirmCallbackId: String?
    var onFatalErrorCallbackId: String?
    var onRateOperatorCallbackId: String?
    var sendDialogToEmailAddressCallbackId: String?
    var onUnreadByVisitorMessageCountCallbackId: String?
    var onDeletedMessageCallbackId: String?
    var onSurveyCallbackId: String?
    var onNextQuestionCallbackId: String?
    var onSurveyCancelCallbackId: String?


    @objc(init:)
    func `init`(_ command: CDVInvokedUrlCommand) {
        if session != nil {
            closeInternal()
        }
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        let callbackId = command.callbackId
        onFatalErrorCallbackId = callbackId
        let args = command.arguments[0] as! NSDictionary
        let accountName = args["accountName"] as? String
        let location = args["location"] as? String
        let deviceToken = args["pushToken"] as? String
        let isLocalHistoryStoragingEnabled = args["storeHistoryLocally"] as? Bool
        self.closeWithClearVisitorData = args["closeWithClearVisitorData"] as? Bool ?? false
        if let accountName = accountName {
            var sessionBuilder = Webim.newSessionBuilder()
                .set(accountName: accountName)
                .set(location: location ?? "mobile")
                .set(fatalErrorHandler: self)
                .set(remoteNotificationSystem: ((deviceToken != nil) ? .APNS : .NONE))
                .set(deviceToken: deviceToken)
                .set(isLocalHistoryStoragingEnabled: isLocalHistoryStoragingEnabled ?? false)
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
                session?.getStream().set(unreadByVisitorMessageCountChangeListener: self)
                self.session?.getStream().set(surveyListener: self)
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

    @objc(onDeletedMessage:)
    func onDeletedMessage(_ command: CDVInvokedUrlCommand) {
        onDeletedMessageCallbackId = command.callbackId
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

    @objc(onUnreadByVisitorMessageCount:)
    func onUnreadByVisitorMessageCount(_ command: CDVInvokedUrlCommand) {
        onUnreadByVisitorMessageCountCallbackId = command.callbackId
    }

    @objc(onSurvey:)
    func onSurvey(_ command: CDVInvokedUrlCommand) {
        onSurveyCallbackId = command.callbackId
    }

    @objc(onNextQuestion:)
    func onNextQuestion(_ command: CDVInvokedUrlCommand) {
        onNextQuestionCallbackId = command.callbackId
    }

    @objc(onSurveyCancel:)
    func onSurveyCancel(_ command: CDVInvokedUrlCommand) {
        onSurveyCancelCallbackId = command.callbackId
    }

    @objc(close:)
    func close(_ command: CDVInvokedUrlCommand) {
        closeInternal(command)
    }

    private func closeInternal(_ command: CDVInvokedUrlCommand? = nil) {
        let callbackId = command?.callbackId
        if session != nil {
            do {
                try messageTracker?.destroy()
                if closeWithClearVisitorData {
                    try session?.destroyWithClearVisitorData()
                    closeWithClearVisitorData = false
                } else {
                    try session?.destroy()
                }
            } catch { }
            session = nil
            messageTracker = nil
            onMessageCallbackId = nil
            onTypingCallbackId = nil
            onFileCallbackId = nil
            onBanCallbackId = nil
            onDialogCallbackId = nil
            onFileMessageErrorCallbackId = nil
            onConfirmCallbackId = nil
            onFatalErrorCallbackId = nil
            onRateOperatorCallbackId = nil
            sendDialogToEmailAddressCallbackId = nil
            onUnreadByVisitorMessageCountCallbackId = nil
            onDeletedMessageCallbackId = nil
            onSurveyCallbackId = nil
            onNextQuestionCallbackId = nil
            onSurveyCancelCallbackId = nil
            if let callbackId = callbackId {
                sendCallbackResult(callbackId: callbackId)
            }
        } else {
            if let callbackId = callbackId {
                sendCallbackError(callbackId: callbackId)
            }
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

        if let data = try? Data(contentsOf: url) {
            let file = WebimFile(url: url, data: data)
            file.send(session: session, completionHandler: self) { error in
                if let error = error {
                    print("Error while sending a file: \(error).")
                }
            }
        }
    }

    @objc(sendSurveyAnswer:)
    func sendSurveyAnswer(_ command: CDVInvokedUrlCommand) {
        let surveyAnswer = command.arguments[0] as? String ?? ""
        let callbackContextId = command.callbackId
        do {
            try session?.getStream().send(surveyAnswer: surveyAnswer, completionHandler: SendSurveyAnswerCompletionHandlerImpl(webimSDK: self, callbackContextId: callbackContextId))
        } catch { }
    }

    @objc(cancelSurvey:)
    func cancelSurvey(_ command: CDVInvokedUrlCommand) {
        let callbackContextId = command.callbackId
        do {
            try session?.getStream().closeSurvey(completionHandler: SurveyCloseCompletionHandlerImpl(webimSDK: self, callbackContextId: callbackContextId))
        } catch { }
    }

    @objc(rateOperator:)
    func rateOperator(_ command: CDVInvokedUrlCommand) {
        onRateOperatorCallbackId = command.callbackId
        let operatorId = command.arguments[0] as? String
        let rating = command.arguments[1] as? Int
        do {
            try session?.getStream().rateOperatorWith(id: operatorId,
                                                      byRating: rating ?? -1,
                                                      comletionHandler: self)
        } catch { }
    }

    @objc(sendDialogToEmailAddress:)
    func sendDialogToEmailAddress(_ command: CDVInvokedUrlCommand) {
        let emailAddress = command.arguments[0] as? String
        sendDialogToEmailAddressCallbackId = command.callbackId
        do {
            try session?.getStream().sendDialogTo(emailAddress: emailAddress ?? "", completionHandler: SendDialogToEmailAddressCompletionImpl(webimSDK: self))
        } catch { }
    }

    @objc(getUnreadByVisitorMessageCount:)
    func getUnreadByVisitorMessageCount(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let count = session?.getStream().getUnreadByVisitorMessageCount() ?? 0
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"unreadByVisitorMessageCount\":\(count)}")
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
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
        if message.getType() == .INFO {
            dict["timestamp"] = String(message.getTime().timeIntervalSince1970 * 1000 - 1)
        } else {
            dict["timestamp"] = String(message.getTime().timeIntervalSince1970 * 1000)
        }
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

    func surveyToJSON(survey: Survey) -> String {
        var dict = [String: Any]()
        dict["id"] = survey.getID()
        var config = [String: String]()
        config["id"] = String(survey.getConfig().getID())
        config["version"] = survey.getConfig().getVersion()
        dict["config"] = config
        var currentQuestionInfo = [String: String]()
        currentQuestionInfo["formId"] = String(survey.getCurrentQuestionInfo().getFormID())
        currentQuestionInfo["questionId"] = String(survey.getCurrentQuestionInfo().getQuestionID())
        dict["currentQuestionInfo"] = currentQuestionInfo

        if let JSONData = try? JSONSerialization.data(withJSONObject: dict,
                                                      options: .prettyPrinted),
            let JSONText = String(data: JSONData, encoding: String.Encoding.utf8) {
            return JSONText
        }
        return "";
    }

    func nextQuestionToJSON(nextQuestion: SurveyQuestion) -> String {
        var dict = [String: Any]()
        switch nextQuestion.getType() {
        case .radio:
            dict["type"] = "radio"
            break
        case .comment:
            dict["type"] = "comment"
            break
        case .stars:
            dict["type"] = "stars"
            break
        }
        dict["text"] = nextQuestion.getText()

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
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToJSON(message: message))
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onDeletedMessageCallbackId)
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
            self.commandDelegate!.send(pluginResult, callbackId: onBanCallbackId)
            break
        case .UNKNOWN:
            break
        case .VISITOR_BANNED:
            self.commandDelegate!.send(pluginResult, callbackId: onBanCallbackId)
            break
        case .WRONG_PROVIDED_VISITOR_HASH:
            self.commandDelegate!.send(pluginResult, callbackId: onBanCallbackId)
            break
        }
    }
}

extension WebimSDK: RateOperatorCompletionHandler {
    func onSuccess() {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onRateOperatorCallbackId)
    }

    func onFailure(error: RateOperatorError) {
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(errorPluginResult, callbackId: onRateOperatorCallbackId)
    }


}

extension WebimSDK : SendFileCompletionHandler {
    func onSuccess(messageID: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
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

extension WebimSDK: UnreadByVisitorMessageCountChangeListener {
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"unreadByVisitorMessageCount\":" + String(newValue) + "}")
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onUnreadByVisitorMessageCountCallbackId)
    }


}

extension WebimSDK: SurveyListener {
    func on(survey: Survey) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: surveyToJSON(survey: survey))
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onSurveyCallbackId)
    }

    func on(nextQuestion: SurveyQuestion) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: nextQuestionToJSON(nextQuestion: nextQuestion))
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onNextQuestionCallbackId)
    }

    func onSurveyCancelled() {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"")
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onSurveyCallbackId)
    }
}

class SendSurveyAnswerCompletionHandlerImpl: SendSurveyAnswerCompletionHandler {
    let webimSDK: WebimSDK
    let callbackContextId: String?

    init(webimSDK: WebimSDK,
         callbackContextId: String?) {
        self.webimSDK = webimSDK
        self.callbackContextId = callbackContextId
    }

    func onSuccess() {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
        pluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(pluginResult, callbackId: callbackContextId)
    }

    func onFailure(error: SendSurveyAnswerError) {
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(errorPluginResult, callbackId: callbackContextId)
    }
}

class SurveyCloseCompletionHandlerImpl: SurveyCloseCompletionHandler {
    let webimSDK: WebimSDK
    let callbackContextId: String?

    init(webimSDK: WebimSDK,
         callbackContextId: String?) {
        self.webimSDK = webimSDK
        self.callbackContextId = callbackContextId
    }

    func onSuccess() {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
        pluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(pluginResult, callbackId: callbackContextId)
    }

    func onFailure(error: SurveyCloseError) {
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(errorPluginResult, callbackId: callbackContextId)
    }


}

class SendDialogToEmailAddressCompletionImpl: SendDialogToEmailAddressCompletionHandler {

    let webimSDK: WebimSDK

    init(webimSDK: WebimSDK) {
        self.webimSDK = webimSDK
    }

    func onSuccess() {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
        pluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(pluginResult, callbackId: webimSDK.sendDialogToEmailAddressCallbackId)
    }

    func onFailure(error: SendDialogToEmailAddressError) {
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(errorPluginResult, callbackId: webimSDK.sendDialogToEmailAddressCallbackId)
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
        
        let imageExtension = self.url.pathExtension.lowercased()
        if (imageExtension != "jpg"
            && imageExtension != "jpeg"
            && imageExtension != "png"
            && isImage(contentType: self.mimeType.value)) {
            
            let image = UIImage(data: self.data)!
            if imageExtension == "heic" || imageExtension == "heif" {
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
