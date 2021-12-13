//
//  OperatorItem.swift
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
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
struct KeyboardItem {

    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case buttons = "buttons"
        case state = "state"
        case response = "response"
    }

    // MARK: - Properties
    private let buttons: [[KeyboardButtonItem]]
    var state: KeyboardState
    private var response: KeyboardResponseItem?

    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let data = jsonDictionary[JSONField.buttons.rawValue] as? [[[String: Any?]]] {
            var buttonArrayArray = [[KeyboardButtonItem]]()
            for buttonArray in data {
                var newButtonArray = [KeyboardButtonItem]()
                for button in buttonArray {
                    guard let buttonItem = KeyboardButtonItem(jsonDictionary: button) else {
                        WebimInternalLogger.shared.log(entry: "Getting KeyboardButtonItem from json failure in KeyboardItem.\(#function)")
                        return nil
                    }
                    newButtonArray.append(buttonItem)
                }
                buttonArrayArray.append(newButtonArray)
            }
            self.buttons = buttonArrayArray
        } else {
            return nil
        }

        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            switch state {
            case "pending":
                self.state = .pending
            case "completed":
                self.state = .completed
            default:
                self.state = .canceled
            }
        } else {
            return nil
        }

        if let response = jsonDictionary[JSONField.response.rawValue] as? [String: Any?] {
            self.response = KeyboardResponseItem(jsonDictionary: response)
        }
    }

    // MARK: - Methods

    func getButtons() -> [[KeyboardButtonItem]] {
        return buttons
    }

    func getState() -> KeyboardState {
        return state
    }

    func getResponse() -> KeyboardResponseItem? {
        return response
    }
}

/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
struct KeyboardButtonItem {

    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case text = "text"
        case config = "config"
    }

    // MARK: - Properties
    private let id: String?
    private let text: String?

    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        } else {
            return nil
        }

        if let text = jsonDictionary[JSONField.text.rawValue] as? String {
            self.text = text
        } else {
            return nil
        }
    }

    // MARK: - Methods

    func getId() -> String {
        guard let id = id else {
            WebimInternalLogger.shared.log(entry: "ID is nil in KeyboardButtonItem.\(#function)")
            return String()
        }
        return id
    }

    func getText() -> String {
        guard let text = text else {
            WebimInternalLogger.shared.log(entry: "Text is nil in KeyboardButtonItem.\(#function)")
            return String()
        }
        return text
    }

}

/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
struct KeyboardResponseItem {

    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case buttonId = "buttonId"
        case messageId = "messageId"
    }

    // MARK: - Properties
    private let messageId: String?
    private let buttonId: String?

    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let buttonId = jsonDictionary[JSONField.buttonId.rawValue] as? String {
            self.buttonId = buttonId
        } else {
            return nil
        }

        if let messageId = jsonDictionary[JSONField.messageId.rawValue] as? String {
            self.messageId = messageId
        } else {
            return nil
        }
    }

    // MARK: - Methods

    func getMessageId() -> String {
        guard let messageId = messageId else {
            WebimInternalLogger.shared.log(entry: "Message ID is nil in KeyboardResponseItem.\(#function)")
            return String()
        }
        return messageId
    }

    func getButtonId() -> String {
        guard let buttonId = buttonId else {
            WebimInternalLogger.shared.log(entry: "Button ID is nil in KeyboardResponseItem.\(#function)")
            return String()
        }
        return buttonId
    }
}

/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
struct KeyboardRequestItem {

    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case button = "button"
        case messageId = "messageId"
        case request = "request"
    }

    // MARK: - Properties
    private let button: KeyboardButtonItem?
    private let messageId: String?

    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let button = jsonDictionary[JSONField.button.rawValue] as? [String: Any?] {
            self.button = KeyboardButtonItem(jsonDictionary: button)
        } else {
            return nil
        }

        if let request = jsonDictionary[JSONField.request.rawValue] as? [String: Any?],
            let messageId = request[JSONField.messageId.rawValue] as? String {
            self.messageId = messageId
        } else {
            return nil
        }
    }

    // MARK: - Methods

    func getMessageId() -> String {
        guard let messageId = messageId else {
            WebimInternalLogger.shared.log(entry: "Message ID is nil in KeyboardRequestItem.\(#function)")
            return String()
        }
        return messageId
    }

    func getButton() -> KeyboardButtonItem {
        guard let button = button else {
            WebimInternalLogger.shared.log(entry: "Button is nil in KeyboardRequestItem.\(#function)")
            fatalError("Button is nil in KeyboardRequestItem.\(#function)")
        }
        return button
    }
}
