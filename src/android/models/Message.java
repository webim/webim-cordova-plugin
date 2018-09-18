package ru.webim.plugin.models;

public class Message {
    public String id;
    public String text;
    public String url;
    public String timestamp;
    public String sender;

    public static Message fromWebimMessage(com.webimapp.android.sdk.Message message) {
        Message resultMessage = new Message();
        resultMessage.id = message.getId().toString();
        resultMessage.text = message.getText();
        resultMessage.sender = message.getSenderName();
        resultMessage.timestamp = (message.getTime() / 1000) + "";
        if (message.getAttachment() != null) {
            resultMessage.url = message.getAttachment().getUrl();
        }

        return resultMessage;
    }
}