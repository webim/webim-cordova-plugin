package ru.webim.plugin.models;

public class KeyboardRequest {
    public String messageID;
    public KeyboardButton button;

    public static KeyboardRequest getKeyboardRequest(ru.webim.android.sdk.Message.KeyboardRequest keyboardRequest) {
        KeyboardRequest resultKeyboardRequest = new KeyboardRequest();
        if (keyboardRequest != null) {
            resultKeyboardRequest.messageID = keyboardRequest.getMessageId();
            resultKeyboardRequest.button = ru.webim.plugin.models.KeyboardButton.getKeyboardButton(keyboardRequest.getButtons());
        }
        return resultKeyboardRequest;
    }
}
