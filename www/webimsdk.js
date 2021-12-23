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
    sendFile: function (filePath, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendFile", [filePath]);
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
    getUnreadByVisitorMessageCount: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "getUnreadByVisitorMessageCount", [])
    },
    sendKeyboardRequest: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendKeyboardRequest", [requestMessageCurrentChatId, buttonId])
    },
    setChatRead: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "setChatRead", [])
    },
    onLogging: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onLogging", [])
    }
};
