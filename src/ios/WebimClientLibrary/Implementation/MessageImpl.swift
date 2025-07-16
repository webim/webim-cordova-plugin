//
//  MessageImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/**
 Internal messages representasion.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class MessageImpl {
    
    // MARK: - Properties
    let attachment: MessageAttachment?
    let id: String
    let keyboard: Keyboard?
    let keyboardRequest: KeyboardRequest?
    let operatorID: String?
    let quote: Quote?
    let rawText: String?
    let senderAvatarURLString: String?
    let senderName: String
    let sendStatus: MessageSendStatus
    let serverURLString: String
    let text: String
    let timeInMicrosecond: Int64
    let type: MessageType
    var currentChatID: String?
    var data: [String: Any?]?
    var historyID: HistoryID?
    var historyMessage: Bool
    var read: Bool
    var messageCanBeEdited: Bool
    var messageCanBeReplied: Bool

    // MARK: - Initialization
    init(serverURLString: String,
         id: String,
         keyboard: Keyboard?,
         keyboardRequest: KeyboardRequest?,
         operatorID: String?,
         quote: Quote?,
         senderAvatarURLString: String?,
         senderName: String,
         sendStatus: MessageSendStatus = .SENT,
         type: MessageType,
         data: [String: Any?]?,
         text: String,
         timeInMicrosecond: Int64,
         attachment: MessageAttachment?,
         historyMessage: Bool,
         internalID: String?,
         rawText: String?,
         read: Bool,
         messageCanBeEdited: Bool,
         messageCanBeReplied: Bool) {
        self.attachment = attachment
        self.data = data
        self.id = id
        self.keyboard = keyboard
        self.keyboardRequest = keyboardRequest
        self.operatorID = operatorID
        self.quote = quote
        self.rawText = rawText
        self.senderAvatarURLString = senderAvatarURLString
        self.senderName = senderName
        self.sendStatus = sendStatus
        self.serverURLString = serverURLString
        self.text = text
        self.timeInMicrosecond = timeInMicrosecond
        self.type = type
        self.read = read
        self.messageCanBeEdited = messageCanBeEdited
        self.messageCanBeReplied = messageCanBeReplied

        self.historyMessage = historyMessage
        if historyMessage {
            historyID = HistoryID(dbID: internalID!,
                                  timeInMicrosecond: timeInMicrosecond)
        } else {
            currentChatID = internalID
        }
    }

    // MARK: - Methods

    func getRawText() -> String? {
        return rawText
    }

    func getSenderAvatarURLString() -> String? {
        return senderAvatarURLString
    }

    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }

    func hasHistoryComponent() -> Bool {
        return (historyID != nil)
    }

    func getHistoryID() -> HistoryID? {
        guard historyID != nil else {
            WebimInternalLogger.shared.log(entry: "Message \(self.toString()) do not have history component.",
                verbosityLevel: .DEBUG)

            return nil
        }

        return historyID
    }

    func getServerUrlString() -> String {
        return serverURLString
    }

    func getSource() -> MessageSource {
        return (historyMessage ? MessageSource.history : MessageSource.currentChat)
    }

    func transferToCurrentChat(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryHistory(historyEquivalentMessage: self)

            return message
        }

        setSecondaryCurrentChat(currentChatEquivalentMessage: message)

        invertHistoryStatus()

        return self
    }

    func transferToHistory(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryCurrentChat(currentChatEquivalentMessage: self)

            return message
        }

        setSecondaryHistory(historyEquivalentMessage: message)

        invertHistoryStatus()

        return self
    }

    func invertHistoryStatus() {
        guard historyID != nil,
            currentChatID != nil else {
                WebimInternalLogger.shared.log(entry: "Message \(self.toString()) has not history component or does not belong to current chat.",
                    verbosityLevel: .DEBUG)

                return
        }

        historyMessage = !historyMessage
    }

    func setSecondaryHistory(historyEquivalentMessage: MessageImpl) {
        guard !getSource().isHistoryMessage(),
            historyEquivalentMessage.getSource().isHistoryMessage() else {
                WebimInternalLogger.shared.log(entry: "Message \(self.toString()) is already has history component.",
                    verbosityLevel: .DEBUG)

                return
        }

        historyID = historyEquivalentMessage.getHistoryID()
    }

    func setSecondaryCurrentChat(currentChatEquivalentMessage: MessageImpl) {
        guard getSource().isHistoryMessage(),
            !currentChatEquivalentMessage.getSource().isHistoryMessage() else {
                WebimInternalLogger.shared.log(entry: "Current chat equivalent of the message \(self.toString()) is already has history component.",
                    verbosityLevel: .DEBUG)

                return
        }

        currentChatID = currentChatEquivalentMessage.getCurrentChatID()
    }

    func setRead(isRead: Bool) {
        read = isRead
    }

    func getRead() -> Bool {
        return read
    }

    func setMessageCanBeEdited(messageCanBeEdited: Bool) {
        self.messageCanBeEdited = messageCanBeEdited
    }

    func toString() -> String {
        return """
MessageImpl {
    serverURLString = \(serverURLString),
    ID = \(id),
    operatorID = \(operatorID ?? "nil"),
    senderAvatarURLString = \(senderAvatarURLString ?? "nil"),
    senderName = \(senderName),
    type = \(type),
    text = \(text),
    timeInMicrosecond = \(timeInMicrosecond),
    attachment = \(attachment?.getURL().absoluteString ?? "nil"),
    historyMessage = \(historyMessage),
    currentChatID = \(currentChatID ?? "nil"),
    historyID = \(historyID?.getDBid() ?? "nil"),
    rawText = \(rawText ?? "nil"),
    read = \(read)
}
"""
    }

    // MARK: -
    enum MessageSource {
        case history
        case currentChat

        // MARK: - Methods

        func assertIsCurrentChat() throws {
            guard isCurrentChatMessage() else {
                throw MessageError.invalidState("Current message is not a part of current chat.")
            }
        }

        func assertIsHistory() throws {
            guard isHistoryMessage() else {
                throw MessageError.invalidState("Current message is not a part of the history.")
            }
        }

        func isHistoryMessage() -> Bool {
            return (self == .history)
        }

        func isCurrentChatMessage() -> Bool {
            return (self == .currentChat)
        }

    }

    // MARK: -
    enum MessageError: Error {
        case invalidState(String)
    }

}

// MARK: - Message
extension MessageImpl: Message {

    func getQuote() -> Quote? {
        return quote
    }

    func getAttachment() -> MessageAttachment? {
        return attachment
    }

    func getData() -> [String: Any?]? {
        return data
    }

    func getID() -> String {
        return id
    }

    func getCurrentChatID() -> String? {
        guard let currentChatID = currentChatID else {
            WebimInternalLogger.shared.log(entry: "Message \(self.toString()) do not have an ID in current chat or do not exist in current chat or chat exists itself not.",
                                           verbosityLevel: .DEBUG)

            return nil
        }

        return currentChatID
    }

    func getKeyboard() -> Keyboard? {
        return keyboard
    }

    func getKeyboardRequest() -> KeyboardRequest? {
        return keyboardRequest
    }

    func getOperatorID() -> String? {
        return operatorID
    }

    func getSenderAvatarFullURL() -> URL? {
        guard let senderAvatarURLString = senderAvatarURLString else {
            return nil
        }

        return URL(string: (serverURLString + senderAvatarURLString))
    }

    func getSendStatus() -> MessageSendStatus {
        return sendStatus
    }

    func getSenderName() -> String {
        return senderName
    }

    func getText() -> String {
        return text
    }

    func getTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timeInMicrosecond / 1_000_000))
    }

    func getType() -> MessageType {
        return type
    }

    func isEqual(to message: Message) -> Bool {
        return (self == message as! MessageImpl)
    }

    func isReadByOperator() -> Bool {
        return getRead() //todo: maybe returns old value
    }

    func canBeEdited() -> Bool {
        return messageCanBeEdited
    }

    func canBeReplied() -> Bool {
        return messageCanBeReplied
    }

}

// MARK: - Equatable
extension MessageImpl: Equatable {

    static func == (lhs: MessageImpl,
                    rhs: MessageImpl) -> Bool {
        return ((((((((lhs.id == rhs.id)
            && (lhs.operatorID == rhs.operatorID))
            && (lhs.rawText == rhs.rawText))
            && (lhs.senderAvatarURLString == rhs.senderAvatarURLString))
            && (lhs.senderName == rhs.senderName))
            && (lhs.text == rhs.text))
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond))
            && (lhs.type == rhs.type))
            && (lhs.isReadByOperator() == rhs.isReadByOperator()
            && (lhs.canBeEdited() == rhs.canBeEdited()))
    }

}

// MARK: -
/**
 Internal messages' attachments representation.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MessageAttachmentImpl {

    // MARK: - Constants
    private enum Period: Int64 {
        case attachmentURLExpires = 300 // (seconds) = 5 (minutes).
    }


    // MARK: - Properties
    let urlString: String
    let size: Int64?
    let filename: String
    let contentType: String
    let imageInfo: ImageInfo?
    let extraText: String?


    // MARK: - Initialization
    init(urlString: String,
         size: Int64?,
         filename: String,
         contentType: String,
         imageInfo: ImageInfo? = nil,
         extraText: String? = nil) {
        self.urlString = urlString
        self.size = size
        self.filename = filename
        self.contentType = contentType
        self.imageInfo = imageInfo
        self.extraText = extraText
    }

    // MARK: - Methods
    static func getAttachment(byServerURL serverURLString: String,
                              webimClient: WebimClient,
                              text: String,
                              extraText: String? = nil) -> MessageAttachment? {
        let textData = text.data(using: .utf8)!
        guard let textDictionary = try? JSONSerialization.jsonObject(with: textData,
                                                                     options: []) as? [String: Any?] else {
                                                                        WebimInternalLogger.shared.log(entry: "Message attachment parameters parsing failed: \(text).",
                                                                            verbosityLevel: .WARNING)

                                                                        return nil
        }

        #if swift(>=5.0)
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary)
        #else
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary!)
        #endif
        guard let filename = fileParameters.getFilename(),
            let guid = fileParameters.getGUID(),
            let contentType = fileParameters.getContentType() else {
            return nil
        }

        guard let pageID = webimClient.getDeltaRequestLoop().getAuthorizationData()?.getPageID(),
            let authorizationToken = webimClient.getDeltaRequestLoop().getAuthorizationData()?.getAuthorizationToken() else {
                WebimInternalLogger.shared.log(entry: "Tried to access to message attachment without authorization data.")

                return nil
        }

        let expires = Int64(Date().timeIntervalSince1970) + Period.attachmentURLExpires.rawValue
        let data: String = guid + String(expires)
        if let hash = data.hmacSHA256(withKey: authorizationToken) {
            let fileURLString = serverURLString + WebimActions.ServerPathSuffix.downloadFile.rawValue + "/"
                + guid + "/"
                + filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "?"
                + "page-id" + "=" + pageID + "&"
                + "expires" + "=" + String(expires) + "&"
                + "hash" + "=" + hash

            return MessageAttachmentImpl(urlString: fileURLString,
                                         size: fileParameters.getSize(),
                                         filename: filename,
                                         contentType: contentType,
                                         imageInfo: extractImageInfoOf(fileParameters: fileParameters,
                                                                       with: fileURLString),
                                         extraText: extraText)
        } else {
            WebimInternalLogger.shared.log(entry: "Error creating message attachment link due to HMAC SHA256 encoding error.")

            return nil
        }
    }

    // MARK: Private methods
    private static func extractImageInfoOf(fileParameters: FileParametersItem?,
                                           with fileURLString: String?) -> ImageInfo? {
        guard fileParameters != nil,
            fileURLString != nil else {
            return nil
        }

        let imageSize = fileParameters?.getImageParameters()?.getSize()
        guard imageSize != nil else {
            return nil
        }

        let thumbURLString = (fileURLString == nil) ? nil : (fileURLString! + "&thumb=ios")
        guard thumbURLString != nil else {
            return nil
        }

        return ImageInfoImpl(withThumbURLString: thumbURLString!,
                             width: imageSize!.getWidth(),
                             height: imageSize!.getHeight())
    }

}

// MARK: - MessageAttachment
extension MessageAttachmentImpl: MessageAttachment {

    func getContentType() -> String {
        return contentType
    }

    func getFileName() -> String {
        return filename
    }

    func getImageInfo() -> ImageInfo? {
        return imageInfo
    }

    func getSize() -> Int64? {
        return size
    }

    func getURL() -> URL {
        return URL(string: urlString)!
    }
    
    func getExtraText() -> String? {
        return extraText
    }

}

// MARK: -
/**
 Internal image information representation.
 - seealso:
 `MessageAttachment`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class ImageInfoImpl: ImageInfo {

    // MARK: - Properties
    private let thumbURLString: String
    private let width: Int?
    private let height: Int?

    // MARK: - Initialization
    init(withThumbURLString thumbURLString: String,
         width: Int?,
         height: Int?) {
        self.thumbURLString = thumbURLString
        self.width = width
        self.height = height
    }

    // MARK: - Methods
    // MARK: ImageInfo protocol methods

    func getThumbURL() -> URL {
        return URL(string: thumbURLString)!
    }

    func getHeight() -> Int? {
        return height
    }

    func getWidth() -> Int? {
        return width
    }

}

// MARK: -
/**
 - seealso:
 `Keyboard`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardImpl: Keyboard {

    var keyboardItem: KeyboardItem

    init?(data: [String: Any?]) {
        if let keyboard = KeyboardItem(jsonDictionary: data) {
            self.keyboardItem = keyboard
        } else {
            return nil
        }
    }

    static func getKeyboard(jsonDictionary: [String : Any?]) -> Keyboard? {
        return KeyboardImpl(data: jsonDictionary)
    }

    func getButtons() -> [[KeyboardButton]] {
        var buttonArrayArray = [[KeyboardButton]]()
        for buttonArray in keyboardItem.getButtons() {
            var newButtonArray = [KeyboardButton]()
            for button in buttonArray {
                guard let buttonImpl = KeyboardButtonImpl(data: button) else {
                    WebimInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardImpl.\(#function)")
                    return []
                }
                newButtonArray.append(buttonImpl)
            }
            buttonArrayArray.append(newButtonArray)
        }
        return buttonArrayArray
    }

    func getState() -> KeyboardState {
        return keyboardItem.getState()
    }

    func getResponse() -> KeyboardResponse? {
        return KeyboardResponseImpl(data: keyboardItem.getResponse())
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardButton`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardButtonImpl: KeyboardButton {

    let buttonItem: KeyboardButtonItem

    init?(data: KeyboardButtonItem?) {
        if let buttonItem = data {
            self.buttonItem = buttonItem
        } else {
            return nil
        }
    }

    func getID() -> String {
        return buttonItem.getId()
    }

    func getText() -> String {
        return buttonItem.getText()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardResponse`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardResponseImpl: KeyboardResponse {

    let keyboardResponseItem: KeyboardResponseItem

    init?(data: KeyboardResponseItem?) {
        if let keyboardResponse = data {
            self.keyboardResponseItem = keyboardResponse
        } else {
            return nil
        }
    }

    func getButtonID() -> String {
        return keyboardResponseItem.getButtonId()
    }

    func getMessageID() -> String {
        return keyboardResponseItem.getMessageId()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardResponse`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardRequestImpl: KeyboardRequest {

    let keyboardRequestItem: KeyboardRequestItem

    init?(data: [String: Any?]) {
        if let keyboardRequest = KeyboardRequestItem(jsonDictionary: data) {
            self.keyboardRequestItem = keyboardRequest
        } else {
            return nil
        }
    }

    static func getKeyboardRequest(jsonDictionary: [String : Any?]) -> KeyboardRequest? {
        return KeyboardRequestImpl(data: jsonDictionary)
    }

    func getButton() -> KeyboardButton {
        guard let buttonImpl = KeyboardButtonImpl(data: keyboardRequestItem.getButton()) else {
            WebimInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
            fatalError("Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
        }
        return buttonImpl
    }

    func getMessageID() -> String {
        return keyboardRequestItem.getMessageId()
    }
}

// MARK: -
/**
 - seealso:
 `Message.getQuote()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class QuoteImpl: Quote {

    private let state: QuoteState
    private let authorID: String?
    private let messageAttachment: MessageAttachment?
    private let messageID: String?
    private let messageType: MessageType?
    private let senderName: String?
    private let text: String?
    private let rawText: String?
    private let timestamp: Int64?

    init(state: QuoteState,
         authorID: String?,
         messageAttachment: MessageAttachment?,
         messageID: String?,
         messageType: MessageType?,
         senderName: String?,
         text: String?,
         rawText: String?,
         timestamp: Int64?) {
        self.state = state
        self.authorID = authorID
        self.messageAttachment = messageAttachment
        self.messageID = messageID
        self.messageType = messageType
        self.senderName = senderName
        self.text = text
        self.rawText = rawText
        self.timestamp = timestamp
    }

    // MARK: - Methods
    static func getQuote(quoteItem: QuoteItem?, messageAttachment: MessageAttachment?, serverURL: String, webimClient: WebimClient) -> Quote? {
        guard let quoteItem = quoteItem else {
            return nil
        }
        var text = quoteItem.getText()
        let rawText = quoteItem.getText()
        var messageType: MessageType? = nil
        if let messageKind = quoteItem.getMessageKind() {
            messageType = MessageMapper.convert(messageKind: messageKind)
        }
        var quoteMessageAttachment = messageAttachment
        if let messageAttachment = messageAttachment {
            text = messageAttachment.getFileName()
        } else if messageType == .FILE_FROM_OPERATOR || messageType == .FILE_FROM_VISITOR,
           let rawText = text {
            quoteMessageAttachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURL, webimClient: webimClient, text: rawText)
            if let quoteMessageAttachment = quoteMessageAttachment {
                text = quoteMessageAttachment.getFileName()
            }
        }
        guard let quoteState = quoteItem.getState() else {
            WebimInternalLogger.shared.log(entry: "Quote Item has not State in KeyboardRequestImpl.\(#function)")
            return nil
        }

        return QuoteImpl(state: convert(quoteState: quoteState),
                         authorID: quoteItem.getAuthorID(),
                         messageAttachment: quoteMessageAttachment,
                         messageID: quoteItem.getID(),
                         messageType: messageType,
                         senderName: quoteItem.getSenderName(),
                         text: text,
                         rawText: rawText,
                         timestamp: quoteItem.getTimeInMicrosecond())
    }

    func getRawText() -> String? {
        return rawText
    }

    func getAuthorID() -> String? {
        return authorID
    }

    func getMessageAttachment() -> MessageAttachment? {
        return messageAttachment
    }

    func getMessageTimestamp() -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp / 1_000_000))

    }

    func getMessageID() -> String? {
        return messageID
    }

    func getMessageText() -> String? {
        return text
    }

    func getMessageType() -> MessageType? {
        return messageType
    }

    func getSenderName() -> String? {
        return senderName
    }

    func getState() -> QuoteState {
        return state
    }

    static private func convert(quoteState: QuoteItem.QuoteStateItem) -> QuoteState {
        switch quoteState {
        case .pending:
            return .pending
        case .filled:
            return .filled
        case .notFound:
            return .notFound
        }
    }
}
