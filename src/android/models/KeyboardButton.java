package ru.webim.plugin.models;

public class KeyboardButton {
    public String text;
    public String id;

    public static KeyboardButton getKeyboardButton(ru.webim.android.sdk.Message.KeyboardButton keyboardButton) {
        KeyboardButton resultKeyboardButton = new KeyboardButton();
        if (keyboardButton != null) {
            resultKeyboardButton.text = keyboardButton.getText();
            resultKeyboardButton.id = keyboardButton.getId();
        }
        return resultKeyboardButton;
    }
}
