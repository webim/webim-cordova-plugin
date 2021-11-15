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
    public boolean isFirst = false;
    public boolean isReadByOperator;

    public static Message fromParams(String id,
                                     String text,
                                     String url,
                                     String timestamp,
                                     String sender,
                                     boolean isFirst) {
        Message resultMessage = new Message();
        resultMessage.id = id;
        resultMessage.text = text;
        resultMessage.sender = sender;
        resultMessage.timestamp = timestamp;
        resultMessage.url = url;
        resultMessage.isFirst = isFirst;
        resultMessage.isReadByOperator = false;

        return resultMessage;
    }

    public static Message fromWebimMessage(ru.webim.android.sdk.Message message) {
        Message resultMessage = new Message();
        resultMessage.id = message.getClientSideId().toString();
        resultMessage.text = message.getText();
        resultMessage.isReadByOperator = message.isReadByOperator();
        if (message.getType() != ru.webim.android.sdk.Message.Type.FILE_FROM_OPERATOR
                && message.getType() != ru.webim.android.sdk.Message.Type.OPERATOR) {
            resultMessage.sender = message.getSenderName();
        } else {
            resultMessage.operator = Employee.getEmployeeFromParams(message.getSenderName(),
                    message.getSenderAvatarUrl());
        }
        ru.webim.android.sdk.Message.Attachment attachment = message.getAttachment();
        if (attachment != null) {
            if(resultMessage.text.trim().isEmpty()) {
                resultMessage.text = attachment.getFileInfo().getFileName();
            }
            resultMessage.url = attachment.getFileInfo().getUrl();
            ru.webim.android.sdk.Message.ImageInfo imageInfo = attachment.getFileInfo().getImageInfo();
            if (imageInfo != null) {
                resultMessage.thumbUrl = imageInfo.getThumbUrl();
                resultMessage.imageWidth = imageInfo.getWidth();
                resultMessage.imageHeight = imageInfo.getHeight();
            }
        }

        if (message.getType() == ru.webim.android.sdk.Message.Type.INFO) {
            resultMessage.timestamp = Long.toString(message.getTime() - 1);
        } else {
            resultMessage.timestamp = Long.toString(message.getTime());
        }

        return resultMessage;
    }
}