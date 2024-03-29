/*global cordova, module*/

module.exports = {
    init: function (params, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "init", [params]);
    },
    requestDialog: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "requestDialog", []);
    },
    getMessagesHistory: function (limit, offset, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "getMessagesHistory", [limit, offset]);
    },
    typingMessage: function (message, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "typingMessage", [message]);
    },
    sendMessage: function (message, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendMessage", [message]);
    },
    replyMessage: function (message, repliedMessage, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "replyMessage", [message, repliedMessage]);
    },
    sendFile: function (filePath, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendFile", [filePath]);
    },
    editMessage: function (newText, message, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "editMessage", [newText, message]);
    },
    deleteMessage: function (message, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "deleteMessage", [message]);
    },
    sendSurveyAnswer: function (surveyAnswer, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendSurveyAnswer", [surveyAnswer]);
    },
    cancelSurvey: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "cancelSurvey", []);
    },
    onMessage: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onMessage", []);
    },
    onDeletedMessage: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onDeletedMessage", []);
    },
    onFile: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onFile", []);
    },
    onTyping: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onTyping", []);
    },
    onConfirm: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onConfirm", []);
    },
    onDialog: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onDialog", []);
    },
    onBan: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onBan", []);
    },
    close: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "close", []);
    },
    rateOperator: function (id, rating, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "rateOperator", [id, rating]);
    },
    rateOperatorWithNote: function (id, rating, note, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "rateOperator", [id, rating, note]);
    },
    sendDialogToEmailAddress: function (emailAddress, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendDialogToEmailAddress", [emailAddress]);
    },
    onUnreadByVisitorMessageCount: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onUnreadByVisitorMessageCount", [])
    },
    onSurvey: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onSurvey", [])
    },
    onNextQuestion: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onNextQuestion", [])
    },
    onSurveyCancel: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onSurveyCancel", [])
    },
    onChatState: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onChatState", [])
    },
    getUnreadByVisitorMessageCount: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "getUnreadByVisitorMessageCount", [])
    },
    sendKeyboardRequest: function (requestMessageCurrentChatId, buttonId, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendKeyboardRequest", [requestMessageCurrentChatId, buttonId])
    },
    setChatRead: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "setChatRead", [])
    },
    getShowEmailButton: function  (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "getShowEmailButton", [])
    },
    showRateOperatorWindow: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "showRateOperatorWindow", [])
    },
    onLogging: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onLogging", [])
    }
};
