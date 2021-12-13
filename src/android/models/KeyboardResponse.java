package ru.webim.plugin.models;

public class KeyboardResponse {
    public String buttonID;
    public String messageID;

    public static KeyboardResponse getKeyboardResponse(ru.webim.android.sdk.Message.KeyboardResponse keyboardResponse) {
        KeyboardResponse resultKeyboardResponse = new KeyboardResponse();
        if (keyboardResponse != null) {
            resultKeyboardResponse.buttonID = keyboardResponse.getButtonId();
            resultKeyboardResponse.messageID = keyboardResponse.getMessageId();
        }

        return resultKeyboardResponse;
    }
}
