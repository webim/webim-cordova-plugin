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
    onMessage: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "onMessage", []);
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
    rateOperator: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "rateOperator", [id, rating]);
    },
    sendDialogToEmailAddress: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WebimSDK", "sendDialogToEmailAddress", [emailAddress]);
    }
};
