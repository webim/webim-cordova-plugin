//
//  MessageItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that encapsulates message data, received from a server.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MessageItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case authorID = "authorId"
        case avatarURLString = "avatar"
        case canBeEdited = "canBeEdited"
        case canBeReplied = "canBeReplied"
        case chatID = "chatId"
        case clientSideID = "clientSideId"
        case data = "data"
        case deleted = "deleted"
        case id = "id"
        case kind = "kind"
        case quote = "quote"
        case read = "read"
        case senderName = "name"
        case text = "text"
        case timestampInMicrosecond = "ts_m"
        case timestampInSecond = "ts"
        case extraText = "extra_text"
    }

    // MARK: - Properties
    var authorID: String?
    var avatarURLString: String?
    var canBeEdited: Bool?
    var canBeReplied: Bool?
    var chatID: String?
    var clientSideID: String?
    var data: [String: Any?]?
    var deleted: Bool?
    var id: String?
    var kind: MessageKind?
    var quote: QuoteItem?
    var senderName: String?
    var text: String?
    var timestampInMicrosecond: Int64 = -1
    var timestampInSecond: Double?
    var read: Bool?
    var extraText: String?

    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let messageKind = jsonDictionary[JSONField.kind.rawValue] as? String {
            kind = MessageKind(rawValue: messageKind)
        }

        if let authorID = jsonDictionary[JSONField.authorID.rawValue] as? Int {
            self.authorID = String(authorID)
        }

        if let avatarURLString = jsonDictionary[JSONField.avatarURLString.rawValue] as? String {
            self.avatarURLString = avatarURLString
        }

        if let canBeEdited = jsonDictionary[JSONField.canBeEdited.rawValue] as? Bool {
            self.canBeEdited = canBeEdited
        }

        if let canBeReplied = jsonDictionary[JSONField.canBeReplied.rawValue] as? Bool {
            self.canBeReplied = canBeReplied
        }

        if let chatID = jsonDictionary[JSONField.chatID.rawValue] as? String {
            self.chatID = chatID
        }

        if let clientSideID = jsonDictionary[JSONField.clientSideID.rawValue] as? String {
            self.clientSideID = clientSideID
        }

        if let data = jsonDictionary[JSONField.data.rawValue] as? [String: Any?] {
            self.data = data
            self.extraText = data[JSONField.extraText.rawValue] as? String
        }

        if let deleted = jsonDictionary[JSONField.deleted.rawValue] as? Bool {
            self.deleted = deleted
        }

        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }

        if let quote = jsonDictionary[JSONField.quote.rawValue] as? [String: Any?] {
            self.quote = QuoteItem(jsonDictionary: quote)
        }

        if let read = jsonDictionary[JSONField.read.rawValue] as? Bool {
            self.read = read
        }

        if let senderName = jsonDictionary[JSONField.senderName.rawValue] as? String {
            self.senderName = senderName
        }

        if let text = jsonDictionary[JSONField.text.rawValue] as? String {
            self.text = text
        }

        if let timestampInMicrosecond = jsonDictionary[JSONField.timestampInMicrosecond.rawValue] as? Int64 {
            self.timestampInMicrosecond = timestampInMicrosecond
        }

        if let timestampInSecond = jsonDictionary[JSONField.timestampInSecond.rawValue] as? Double {
            self.timestampInSecond = timestampInSecond
        }
    }

    // MARK: - Methods

    func getClientSideID() -> String? {
        if clientSideID == nil {
            clientSideID = id
        }

        return clientSideID
    }

    func getID() -> String? {
        return id
    }

    func getText() -> String? {
        return text
    }

    func getSenderID() -> String? {
        return authorID
    }

    func getSenderAvatarURLString() -> String? {
        return avatarURLString
    }

    func getData() -> [String: Any?]? {
        return data
    }

    func isDeleted() -> Bool {
        return (deleted == true)
    }

    func getKind() -> MessageKind? {
        return kind
    }

    func getQuote() -> QuoteItem? {
        return quote
    }

    func getSenderName() -> String? {
        return senderName
    }

    func getTimeInMicrosecond() -> Int64? {
        return ((timestampInMicrosecond != -1) ? timestampInMicrosecond : Int64(timestampInSecond! * 1_000_000))
    }

    func getRead() -> Bool? {
        return read
    }

    func setRead(read:Bool) {
        self.read = read
    }

    func getCanBeEdited() -> Bool {
        return canBeEdited ?? false
    }

    func getCanBeReplied() -> Bool {
        return canBeReplied ?? false
    }
    
    func getExtraText() -> String? {
        return extraText
    }

    // MARK: -
    enum MessageKind: String {
        // Raw values equal to field names received in responses from server.
        case actionRequest = "action_request"
        case contactInformationRequest = "cont_req"
        case contactInformation = "contacts"
        case fileFromOperator = "file_operator"
        case fileFromVisitor = "file_visitor"
        case forOperator = "for_operator"
        case info = "info"
        case keyboard = "keyboard"
        case keyboardResponse = "keyboard_response"
        case operatorMessage = "operator"
        case operatorBusy = "operator_busy"
        case visitorMessage = "visitor"

        // MARK: - Initialization
        init(messageType: MessageType) {
            switch messageType {
            case .ACTION_REQUEST:
                self = .actionRequest

                break
            case .CONTACTS_REQUEST:
                self = .contactInformationRequest

                break
            case .FILE_FROM_OPERATOR:
                self = .fileFromOperator

                break
            case .FILE_FROM_VISITOR:
                self = .fileFromVisitor

                break
            case .INFO:
                self = .info

                break
            case .OPERATOR:
                self = .operatorMessage

                break
            case .OPERATOR_BUSY:
                self = .operatorBusy

                break
            case .VISITOR:
                self = .visitorMessage

                break
            case .keyboard:
                self = .keyboard

                break
            case .keyboardResponse:
                self = .keyboardResponse

                break
            }
        }

    }

}

// MARK: - Equatable
extension MessageItem: Equatable {

    // MARK: - Methods
    static func == (lhs: MessageItem,
                    rhs: MessageItem) -> Bool {
        if (((lhs.id == rhs.id)
            && (lhs.clientSideID == rhs.clientSideID))
            && (lhs.timestampInSecond == rhs.timestampInSecond))
            && (lhs.text == rhs.text) {
            return true
        }

        return false
    }

}

/**
 Class that encapsulates message quote data, received from a server.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class QuoteItem {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case state = "state"
        case message = "message"
        case authorId = "authorId"
        case id = "id"
        case kind = "kind"
        case senderName = "name"
        case text = "text"
        case timestamp = "ts"
    }

    // MARK: - Properties
    private var state: QuoteStateItem?
    private var authorId: String?
    private var id: String?
    private var kind: MessageItem.MessageKind?
    private var senderName: String?
    private var text: String?
    private var timestamp: Int64 = -1

    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            self.state = QuoteStateItem(rawValue: state)
        }

        guard let message = jsonDictionary[JSONField.message.rawValue] as? [String: Any?] else {
            return
        }

        if let messageKind = message[JSONField.kind.rawValue] as? String {
            kind = MessageItem.MessageKind(rawValue: messageKind)
        }

        if let authorId = message[JSONField.authorId.rawValue] as? Int {
            self.authorId = String(authorId)
        }

        if let id = message[JSONField.id.rawValue] as? String {
            self.id = id
        }

        if let senderName = message[JSONField.senderName.rawValue] as? String {
            self.senderName = senderName
        }

        if let text = message[JSONField.text.rawValue] as? String {
            self.text = text
        }

        if let timestamp = message[JSONField.timestamp.rawValue] as? Int64 {
            self.timestamp = timestamp
        }
    }

    static func toDictionary(quote: Quote) -> [String: Any] {

        var messageDictionary = [String : Any]()
        if let authorId = quote.getAuthorID() {
            messageDictionary[JSONField.authorId.rawValue] = authorId
        }
        if let timestamp = quote.getMessageTimestamp() {
            messageDictionary[JSONField.timestamp.rawValue] = Int64(timestamp.timeIntervalSince1970)
        }
        if let id = quote.getMessageID() {
            messageDictionary[JSONField.id.rawValue] = id
        }
        if let text = quote.getMessageText() {
            messageDictionary[JSONField.text.rawValue] = text
        }
        if quote.getMessageAttachment() != nil,
           let quoteImpl = quote as? QuoteImpl {
            messageDictionary[JSONField.text.rawValue] = quoteImpl.getRawText()
        }
        if let messageType = quote.getMessageType() {
            messageDictionary[JSONField.kind.rawValue] = MessageItem.MessageKind(messageType: messageType).rawValue
        }
        if let senderName = quote.getSenderName() {
            messageDictionary[JSONField.senderName.rawValue] = senderName
        }
        return [JSONField.state.rawValue: QuoteStateItem(quoteState: quote.getState()).rawValue, JSONField.message.rawValue: messageDictionary]
    }

    // MARK: - Methods

    func getID() -> String? {
        return id
    }

    func getText() -> String? {
        return text
    }

    func getAuthorID() -> String? {
        return authorId
    }

    func getMessageKind() -> MessageItem.MessageKind? {
        return kind
    }

    func getSenderName() -> String? {
        return senderName
    }

    func getTimeInMicrosecond() -> Int64? {
        return Int64(timestamp * 1_000_000)
    }

    func getState() -> QuoteStateItem? {
        return state
    }

    // MARK: -
    enum QuoteStateItem: String {
        // Raw values equal to field names received in responses from server.
        case pending = "pending"
        case filled = "filled"
        case notFound = "not-found"

        init(quoteState: QuoteState) {
            switch quoteState {
            case .filled:
                self = .filled

                break
            case .pending:
                self = .pending

                break
            case .notFound:
                self = .notFound
            }
        }
    }
}
