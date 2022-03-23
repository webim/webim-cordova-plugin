package ru.webim.plugin.models;

import java.util.List;

public class Keyboard {
    public String state;
    public List<KeyboardButton> buttons;
    public KeyboardResponse keyboardResponse;

    public static Keyboard getKeyboard(ru.webim.android.sdk.Message.Keyboard keyboard) {
        Keyboard resultKeyboard = new Keyboard();
        if (keyboard != null) {
            if (keyboard.getState() != null) {
                switch (keyboard.getState()) {
                    case PENDING:
                        resultKeyboard.state = "pending";
                    case COMPLETED:
                        resultKeyboard.state = "completed";
                    case CANCELLED:
                        resultKeyboard.state = "cancelled";
                }
            }
            resultKeyboard.keyboardResponse = ru.webim.plugin.models.KeyboardResponse.getKeyboardResponse(keyboard.getKeyboardResponse());
            List<List<ru.webim.android.sdk.Message.KeyboardButtons>> buttonsList = keyboard.getButtons();
            if (buttonsList != null) {
                for (int i = 0; i < buttonsList.size(); i++) {
                    List<ru.webim.android.sdk.Message.KeyboardButtons> keyboardButtons = buttonsList.get(i);
                    for (int j = 0; i < keyboardButtons.size(); j++) {
                        resultKeyboard.buttons.add(ru.webim.plugin.models.KeyboardButton.getKeyboardButton(keyboardButtons.get(j)));
                    }
                }
            }
        }

        return resultKeyboard;
    }
}
