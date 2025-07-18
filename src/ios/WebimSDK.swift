import Photos

@objc(WebimSDK) class WebimSDK : CDVPlugin {
    
    private var session: WebimSession?
    private var messageTracker: MessageTracker?
    private var accountName: String?
    private var closeWithClearVisitorData = false
    private var isFirstMessage = false
    var onMessageCallbackId: String?
    var onTypingCallbackId: String?
    var onFileCallbackId: String?
    var onBanCallbackId: String?
    var onDialogCallbackId: String?
    var onFileMessageErrorCallbackId: String?
    var onConfirmCallbackId: String?
    var onFatalErrorCallbackId: String?
    var onRateOperatorCallbackId: String?
    var showRateOperatorWindowCallbackId: String?
    var sendDialogToEmailAddressCallbackId: String?
    var onUnreadByVisitorMessageCountCallbackId: String?
    var onDeletedMessageCallbackId: String?
    var onSurveyCallbackId: String?
    var onNextQuestionCallbackId: String?
    var onSurveyCancelCallbackId: String?
    var onChatStateCallbackId: String?
    var onLoggingCallbackId: String?


    @objc(init:)
    func `init`(_ command: CDVInvokedUrlCommand) {
        if session != nil {
            closeInternal()
        }
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        let callbackId = command.callbackId
        onFatalErrorCallbackId = callbackId
        let args = command.arguments[0] as! NSDictionary
        accountName = args["accountName"] as? String
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
            if onLoggingCallbackId != nil {
                sessionBuilder = sessionBuilder.set(webimLogger: self, verbosityLevel: .VERBOSE)
            }
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
                session?.getStream().set(chatStateListener: self)
                self.session?.getStream().set(surveyListener: self)
                try messageTracker = session?.getStream().newMessageTracker(messageListener: self)
                try session?.resume()
                pluginResult = nil
            } catch { }
        }
        if let pluginResult = pluginResult {
            pluginResult.setKeepCallbackAs(true)
            self.commandDelegate!.send(
                pluginResult,
                callbackId: callbackId
            )
        }
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

    @objc(onChatState:)
    func onChatState(_ command: CDVInvokedUrlCommand) {
        onChatStateCallbackId = command.callbackId
    }

    @objc(onLogging:)
    func onLogging(_ command: CDVInvokedUrlCommand) {
        onLoggingCallbackId = command.callbackId
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
            onFileCallbackId = nil
            onBanCallbackId = nil
            onFileMessageErrorCallbackId = nil
            onConfirmCallbackId = nil
            onFatalErrorCallbackId = nil
            onRateOperatorCallbackId = nil
            sendDialogToEmailAddressCallbackId = nil
            onDeletedMessageCallbackId = nil
            onChatStateCallbackId = nil
            if let callbackId = callbackId {
                onTypingCallbackId = nil
                onUnreadByVisitorMessageCountCallbackId = nil
                onDialogCallbackId = nil
                onSurveyCallbackId = nil
                onNextQuestionCallbackId = nil
                onSurveyCancelCallbackId = nil
                showRateOperatorWindowCallbackId = nil
                onLoggingCallbackId = nil
                
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
        let chatState = session?.getStream().getChatState()
        do {
            try messageID = session?.getStream().send(message: userMessage as! String)
        } catch { }
        let message: [String: Any]
        if chatState != .NONE && chatState != .UNKNOWN {
            message = messageToDictionary(id: messageID ?? "error", text: userMessage as! String, url: nil, timestamp: String(Int64(NSDate().timeIntervalSince1970 * 1000)), sender: nil, isFirst: false)
        } else {
            message = messageToDictionary(id: messageID ?? "error", text: userMessage as! String, url: nil, timestamp: String(Int64(NSDate().timeIntervalSince1970 * 1000)), sender: nil, isFirst: true)
            isFirstMessage = true
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: callbackId)
    }
    
    @objc(editMessage:)
    func editMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let newText = command.arguments[0] as! String
        let editMessageDict = command.arguments[1] as! NSDictionary
        let editMessage: Message
        do {
            let canBeReplied = editMessageDict["canBeReplied"] as? Bool == true
            let canBeEdited = editMessageDict["canBeEdited"] as? Bool == true
            var attachment: MessageAttachment? = nil
            if let url = editMessageDict["url"] as? String {
                attachment = MessageAttachmentImpl(urlString: url,
                                                       size: 0,
                                                       filename: "file",
                                                       contentType: "file")
            }
            editMessage = MessageImpl(serverURLString: accountName ?? "",
                                         id: editMessageDict["id"] as? String ?? "",
                                         keyboard: nil,
                                         keyboardRequest: nil,
                                         operatorID: nil,
                                         quote: nil,
                                         senderAvatarURLString: nil,
                                         senderName: "",
                                         type: .VISITOR,
                                         data: nil,
                                         text: editMessageDict["text"] as? String ?? "",
                                         timeInMicrosecond: Int64(editMessageDict["timestamp"] as? String ?? "0") ?? 0,
                                         attachment: attachment,
                                         historyMessage: false,
                                         internalID: editMessageDict["currentChatID"] as? String ?? "",
                                         rawText: nil,
                                         read: false,
                                         messageCanBeEdited:  canBeEdited,
                                         messageCanBeReplied: canBeReplied)
            _ = try session?.getStream().edit(message: editMessage, text: newText, completionHandler: self)
        } catch {
        }
        sendCallbackResult(callbackId: callbackId!)
    }
    
    @objc(deleteMessage:)
    func deleteMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let deleteMessageDict = command.arguments[0] as! NSDictionary
        let deleteMessage: Message
        do {
            let canBeReplied = deleteMessageDict["canBeReplied"] as? Bool == true
            let canBeEdited = deleteMessageDict["canBeEdited"] as? Bool == true
            var attachment: MessageAttachment? = nil
            if let url = deleteMessageDict["url"] as? String {
                attachment = MessageAttachmentImpl(urlString: url,
                                                       size: 0,
                                                       filename: "file",
                                                       contentType: "file")
            }
            deleteMessage = MessageImpl(serverURLString: accountName ?? "",
                                         id: deleteMessageDict["id"] as? String ?? "",
                                         keyboard: nil,
                                         keyboardRequest: nil,
                                         operatorID: nil,
                                         quote: nil,
                                         senderAvatarURLString: nil,
                                         senderName: "",
                                         type: .VISITOR,
                                         data: nil,
                                         text: deleteMessageDict["text"] as? String ?? "",
                                         timeInMicrosecond: Int64(deleteMessageDict["timestamp"] as? String ?? "0") ?? 0,
                                         attachment: attachment,
                                         historyMessage: false,
                                         internalID: deleteMessageDict["currentChatID"] as? String ?? "",
                                         rawText: nil,
                                         read: false,
                                         messageCanBeEdited: canBeEdited,
                                         messageCanBeReplied: canBeReplied)
            _ = try session?.getStream().delete(message: deleteMessage, completionHandler: self)
        } catch {
        }
        sendCallbackResult(callbackId: callbackId!)
    }

    @objc(replyMessage:)
    func replyMessage(_ command: CDVInvokedUrlCommand) {
        let callbackId = command.callbackId
        let userMessage = command.arguments[0]
        let repliedMessageDict = command.arguments[1] as! NSDictionary
        var messageID: String?
        let chatState = session?.getStream().getChatState()
        let repliedMessage: Message
        do {
            let canBeReplied = repliedMessageDict["canBeReplied"] as? Bool == true
            let canBeEdited = repliedMessageDict["canBeEdited"] as? Bool == true
            let sender = repliedMessageDict["operator"] as? NSDictionary
            let senderName = sender?["firstname"] as? String
            let avatar = sender?["avatar"] as? String
            var attachment: MessageAttachment? = nil
            if let url = repliedMessageDict["url"] as? String {
                attachment = MessageAttachmentImpl(urlString: url,
                                                       size: 0,
                                                       filename: "file",
                                                       contentType: "file")
            }
            repliedMessage = MessageImpl(serverURLString: accountName ?? "",
                                         id: repliedMessageDict["id"] as? String ?? "",
                                         keyboard: nil,
                                         keyboardRequest: nil,
                                         operatorID: nil,
                                         quote: nil,
                                         senderAvatarURLString: avatar,
                                         senderName: senderName ?? "",
                                         type: .VISITOR,
                                         data: nil,
                                         text: repliedMessageDict["text"] as? String ?? "",
                                         timeInMicrosecond: Int64(repliedMessageDict["timestamp"] as? String ?? "0") ?? 0,
                                         attachment: attachment,
                                         historyMessage: false,
                                         internalID: repliedMessageDict["currentChatID"] as? String ?? "",
                                         rawText: nil,
                                         read: false,
                                         messageCanBeEdited: canBeEdited,
                                         messageCanBeReplied: canBeReplied)
            try messageID = session?.getStream().reply(message: userMessage as! String, repliedMessage: repliedMessage)
        } catch { }
        let message: [String: Any]
        if chatState != .NONE && chatState != .UNKNOWN {
            message = messageToDictionary(id: messageID ?? "error", text: userMessage as! String, url: nil, timestamp: String(Int64(NSDate().timeIntervalSince1970 * 1000)), sender: nil, isFirst: false, quote: repliedMessage)
        } else {
            message = messageToDictionary(id: messageID ?? "error", text: userMessage as! String, url: nil, timestamp: String(Int64(NSDate().timeIntervalSince1970 * 1000)), sender: nil, isFirst: true, quote: repliedMessage)
            isFirstMessage = true
        }
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

    @objc(sendKeyboardRequest:)
    func sendKeyboardRequest(_ command: CDVInvokedUrlCommand) {
        let callbackContextId = command.callbackId
        let requestMessageCurrentChatId = command.arguments[0] as? String ?? ""
        let buttonID = command.arguments[1] as? String ?? ""
        do {
            try session?.getStream().sendKeyboardRequest(buttonID: buttonID, messageCurrentChatID: requestMessageCurrentChatId, completionHandler: SendKeyboardRequestCompletionHandlerImpl(webimSDK: self, callbackContextId: callbackContextId))
        } catch { }
    }

    @objc(setChatRead:)
    func setChatRead(_ command: CDVInvokedUrlCommand) {
        let callbackContextId = command.callbackId
        do {
            try session?.getStream().setChatRead()
        } catch { }
    }

    @objc(rateOperator:)
    func rateOperator(_ command: CDVInvokedUrlCommand) {
        onRateOperatorCallbackId = command.callbackId
        let operatorId = command.arguments[0] as? String
        let rating = command.arguments[1] as? Int
        do {
            try session?.getStream().rateOperatorWith(id: operatorId,
                                                      note: nil,
                                                      byRating: rating ?? -1,
                                                      comletionHandler: self)
        } catch { }
    }

    @objc(rateOperatorWithNote:)
    func rateOperatorWithNote(_ command: CDVInvokedUrlCommand) {
        onRateOperatorCallbackId = command.callbackId
        let operatorId = command.arguments[0] as? String
        let rating = command.arguments[1] as? Int
        let note = command.arguments[2] as? String
        do {
            try session?.getStream().rateOperatorWith(id: operatorId,
                                                      note: note,
                                                      byRating: rating ?? -1,
                                                      comletionHandler: self)
        } catch { }
    }

    @objc(showRateOperatorWindow:)
    func showRateOperatorWindow(_ command: CDVInvokedUrlCommand) {
        showRateOperatorWindowCallbackId = command.callbackId
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

    @objc(getShowEmailButton:)
        func getShowEmailButton(_ command: CDVInvokedUrlCommand) {
            let callbackId = command.callbackId
            if var accountName = accountName {
                let url: URL?
                if accountName.contains("https://") || accountName.contains("http://") {
                    if accountName.last == "/" {
                        accountName.removeLast()
                    }
                    url = URL(string: "\(accountName)/js/v/all-settings.js.php")
                } else {
                    url = URL(string: "https://\(accountName).webim.ru/js/v/all-settings.js.php")
                }
                if let url = url {
                    let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        var dataString = String(data: data ?? Data(), encoding: .utf8)
                        dataString?.removeFirst(29)
                        dataString?.removeLast(2)
                        let dataJSON = try? JSONSerialization.jsonObject(with: dataString?.data(using: .utf8, allowLossyConversion: false) ?? Data()) as? [String: Any]
                        #if swift(>=5.0)
                        let accountConfig = dataJSON?["accountConfig"] as? [String: Any?]
                        #else
                        let accountConfig = dataJSON??["accountConfig"] as? [String: Any?]
                        #endif
                        if let showEmailButton = accountConfig?["show_visitor_send_chat_to_email_button"] as? Bool {
                            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"showEmailButton\":\(showEmailButton)}")
                            pluginResult?.setKeepCallbackAs(true)
                            self?.commandDelegate!.send(pluginResult, callbackId: callbackId)
                        } else {
                            self?.sendCallbackError(callbackId: callbackId!, error: "Show email button key not found")
                        }
                    }
                    dataTask.resume()
                }
            } else {
                sendCallbackError(callbackId: callbackId!, error: "Account name is nil")
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

    func messageToDictionary(message: Message, isFirst: Bool = false) -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = message.getID()
        dict["currentChatID"] = message.getCurrentChatID()
        dict["text"] = message.getText()
        dict["isFirst"] = isFirst
        dict["isReadByOperator"] = message.isReadByOperator()
        dict["canBeReplied"] = message.canBeReplied()
        dict["canBeEdited"] = message.canBeEdited()
        if let quote = message.getQuote() {
            var quoteDict = [String: String]()
            switch quote.getState() {
            case .filled:
                quoteDict["state"] = "filled"
                break
            case .notFound:
                quoteDict["state"] = "notFound"
                break
            case .pending:
                quoteDict["state"] = "pending"
                break
            }
            quoteDict["senderName"] = quote.getSenderName()
            quoteDict["message"] = quote.getMessageText()
            if let timestamp = quote.getMessageTimestamp() {
                quoteDict["timestamp"] = String(timestamp.timeIntervalSince1970 * 1000)
            }
            if let quoteAttachment = quote.getMessageAttachment() {
                quoteDict["url"] = quoteAttachment.getURL().absoluteString

            }
            quoteDict["authorID"] = quote.getAuthorID()
            quoteDict["messageID"] = quote.getMessageID()
            dict["quote"] = quoteDict
        }
        if let attachment = message.getAttachment() {
            dict["url"] = (attachment.getURL()).absoluteString
            dict["fileSize"] = attachment.getSize()
            dict["contentType"] = attachment.getContentType()
            dict["extraText"] = attachment.getExtraText()
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
        if message.getType() == .keyboard,
           let keyboard = message.getKeyboard() {
            var keyboardDict = [String: Any]()
            switch keyboard.getState() {
            case .pending:
                keyboardDict["state"] = "pending"
            case .completed:
                keyboardDict["state"] = "completed"
            case .canceled:
                keyboardDict["state"] = "canceled"
            }
            let keyboardButtons = keyboard.getButtons()
            var keyboardButtonsDict = [[String: String]]()
            for array in keyboardButtons {
                for button in array {
                    keyboardButtonsDict.append(["text": button.getText(), "id": button.getID()])
                }
            }
            keyboardDict["buttons"] = keyboardButtonsDict
            if let keyboardResponse = keyboard.getResponse() {
                keyboardDict["keyboardResponse"] = ["messageID": keyboardResponse.getMessageID(), "buttonID": keyboardResponse.getButtonID()]
            }


            dict["keyboard"] = keyboardDict

        }
        if message.getType() == .keyboardResponse,
           let keyboardRequest = message.getKeyboardRequest() {
            var keyboardRequestDict: [String: Any] = ["messageID": keyboardRequest.getMessageID()]
            keyboardRequestDict["button"] = ["id": keyboardRequest.getButton().getID(), "text": keyboardRequest.getButton().getText()]
            dict["keyboardRequest"] = keyboardRequestDict
        }
        return dict
    }

    func messageToDictionary(id: String,
                             text: String,
                             url: String?,
                             timestamp: String,
                             sender: String?,
                             isFirst: Bool,
                             quote: Message? = nil) -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id
        dict["text"] = text
        dict["url"] = url
        dict["sender"] = sender
        dict["timestamp"] = timestamp
        dict["isFirst"] = isFirst
        dict["isReadByOperator"] = false
        if let quote = quote {
            var quoteDict = [String: String]()
            quoteDict["state"] = "pending"
            quoteDict["senderName"] = quote.getSenderName()
            quoteDict["message"] = quote.getText()
            quoteDict["timestamp"] = String(quote.getTime().timeIntervalSince1970 * 1000)
            if let quoteAttachment = quote.getAttachment() {
                quoteDict["url"] = quoteAttachment.getURL().absoluteString
            }
            quoteDict["messageID"] = quote.getID()
            dict["quote"] = quoteDict
        }
        return dict
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
        return ""
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
        return ""
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
        return ""
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
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToDictionary(message: newMessage))
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onMessageCallbackId)
            }
        } else {
            if let onFileCallbackId = onFileCallbackId {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToDictionary(message: newMessage, isFirst: isFirstMessage))
                if isFirstMessage {
                    isFirstMessage = false
                }
                pluginResult?.setKeepCallbackAs(true)
                self.commandDelegate!.send(pluginResult, callbackId: onFileCallbackId)
            }
        }
    }

    func removed(message: Message) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToDictionary(message: message))
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onDeletedMessageCallbackId)
    }

    func removedAllMessages() {

    }

    func changed(message oldVersion: Message, to newVersion: Message) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: messageToDictionary(message: newVersion, isFirst: isFirstMessage))
        pluginResult?.setKeepCallbackAs(true)
        if isFirstMessage {
            isFirstMessage = false
        }
        if newVersion.getType() != MessageType.FILE_FROM_OPERATOR
            && newVersion.getType() != MessageType.FILE_FROM_VISITOR {
            if let onConfirmCallbackId = onConfirmCallbackId {
                self.commandDelegate!.send(pluginResult, callbackId: onConfirmCallbackId)
            }
        } else {
            if let onFileCallbackId = onFileCallbackId {
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

extension WebimSDK: ChatStateListener {
    func changed(state previousState: ChatState, to newState: ChatState) {
        if previousState == .UNKNOWN {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
            pluginResult?.setKeepCallbackAs(true)
            self.commandDelegate!.send(
                pluginResult,
                callbackId: onFatalErrorCallbackId
            )
        }
        if (previousState == .CHATTING || previousState == .UNKNOWN) && newState == .CLOSED_BY_OPERATOR {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
            pluginResult?.setKeepCallbackAs(true)
            self.commandDelegate!.send(
                pluginResult,
                callbackId: showRateOperatorWindowCallbackId
            )
        }
        let pluginResult: CDVPluginResult?
        switch newState {
        case .CHATTING:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"chatting\"}")
            break
        case .CHATTING_WITH_ROBOT:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"chattingWithRobot\"}")
            break
        case .CLOSED_BY_OPERATOR:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"closedByOperator\"}")
            break
        case .CLOSED_BY_VISITOR:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"closedByVisitor\"}")
            break
        case .INVITATION:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"invitation\"}")
            break
        case .NONE:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"none\"}")
            break
        case .QUEUE:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"queue\"}")
            break
        case .UNKNOWN:
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"chatState\":\"unknown\"}")
            break
        }
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(
            pluginResult,
            callbackId: onChatStateCallbackId
        )
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

extension WebimSDK: DeleteMessageCompletionHandler {
    func onFailure(messageID: String, error: DeleteMessageError) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onConfirmCallbackId)
    }
}

extension WebimSDK: EditMessageCompletionHandler {
    func onFailure(messageID: String, error: EditMessageError) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: onConfirmCallbackId)
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

class SendKeyboardRequestCompletionHandlerImpl: SendKeyboardRequestCompletionHandler {
    let webimSDK: WebimSDK
    let callbackContextId: String?

    init(webimSDK: WebimSDK,
         callbackContextId: String?) {
        self.webimSDK = webimSDK
        self.callbackContextId = callbackContextId
    }

    func onSuccess(messageID: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"result\":\"Success\"}")
        pluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(pluginResult, callbackId: callbackContextId)
    }

    func onFailure(messageID: String, error: KeyboardResponseError) {
        let errorPluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        errorPluginResult?.setKeepCallbackAs(true)
        webimSDK.commandDelegate!.send(errorPluginResult, callbackId: callbackContextId)
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
                #if swift(>=5.0)
                resultData = image.jpegData(compressionQuality: 0.5)!
                #else
                resultData = UIImageJPEGRepresentation(image, 0.5)!
                #endif
                resultMimeType = MimeType()
                var components = self.fileName.components(separatedBy: ".")
                if components.count > 1 {
                    components.removeLast()
                    resultFileName = components.joined(separator: ".")
                }
                resultFileName += ".jpeg"
            } else {
                #if swift(>=5.0)
                resultData = image.pngData()!
                #else
                resultData = UIImagePNGRepresentation(image)!
                #endif
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

extension WebimSDK: WebimLogger {
    func log(entry: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "{\"log\":\"\(entry)\"}")
        pluginResult?.setKeepCallbackAs(true)
        commandDelegate!.send(pluginResult, callbackId: onLoggingCallbackId)
    }
}
