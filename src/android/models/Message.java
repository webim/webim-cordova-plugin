package ru.webim.plugin.models;

public class Message {
    public String id;
    public String text;
    public String url;
    public int imageWidth;
    public int imageHeight;
    public String thumbUrl;
    public String timestamp;
    public String sender;
    public Employee operator;

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
        if (message.getType() != com.webimapp.android.sdk.Message.Type.FILE_FROM_OPERATOR
                && message.getType() != com.webimapp.android.sdk.Message.Type.OPERATOR) {
            resultMessage.sender = message.getSenderName();
        } else {
            resultMessage.operator = Employee.getEmployeeFromParams(message.getSenderName(),
                    message.getSenderAvatarUrl());
        }
        com.webimapp.android.sdk.Message.Attachment attachment = message.getAttachment();
        if (attachment != null) {
            if(resultMessage.text.trim().isEmpty()) {
                resultMessage.text = attachment.getFileName();
            }
            resultMessage.url = attachment.getUrl();
            com.webimapp.android.sdk.Message.ImageInfo imageInfo = attachment.getImageInfo();
            if (imageInfo != null) {
                resultMessage.thumbUrl = imageInfo.getThumbUrl();
                resultMessage.imageWidth = imageInfo.getWidth();
                resultMessage.imageHeight = imageInfo.getHeight();
            }
        }

        resultMessage.timestamp = Long.toString(message.getTime());

        return resultMessage;
    }
}