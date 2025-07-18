package ru.webim.plugin.models;

import java.util.ArrayList;
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
            List<List<ru.webim.android.sdk.Message.KeyboardButton>> buttonsList = keyboard.getButtons();
            if (buttonsList != null) {
                resultKeyboard.buttons = new ArrayList<KeyboardButton>();
                try {
                    for (int i = 0; i < buttonsList.size(); i++) {
                        List<ru.webim.android.sdk.Message.KeyboardButton> keyboardButtons = buttonsList.get(i);
                        for (int j = 0; j < keyboardButtons.size(); j++) {
                            resultKeyboard.buttons.add(ru.webim.plugin.models.KeyboardButton.getKeyboardButton(keyboardButtons.get(j)));
                        }
                    }
                } catch (IndexOutOfBoundsException ignored) { }
            }
        }

        return resultKeyboard;
    }
}
