package ru.webim.plugin.models;

public class Message {
    public String id;
    public String text;
    public String url;
    public String timestamp;
    public String sender;

    public static Message fromParams(String id,
                                     String text,
                                     String url,
                                     String timestamp,
                                     String sender) {
        Message resultMessage = new Message();
        resultMessage.id = id;
        resultMessage.text = text;
        resultMessage.sender = sender;
        resultMessage.timestamp = timestamp;
        resultMessage.url = url;

        return resultMessage;
    }

    public static Message fromWebimMessage(com.webimapp.android.sdk.Message message) {
        Message resultMessage = new Message();
        resultMessage.id = message.getId().toString();
        resultMessage.text = message.getText();
        resultMessage.sender = message.getSenderName();
        resultMessage.timestamp = Long.toString(message.getTime());
        if (message.getAttachment() != null) {
            resultMessage.url = message.getAttachment().getUrl();
        }

        return resultMessage;
    }
}