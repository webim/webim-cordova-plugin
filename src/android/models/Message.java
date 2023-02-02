package ru.webim.plugin.models;

public class Message {
    public String id;
    public String currentChatID;
    public String text;
    public String url;
    public int imageWidth;
    public int imageHeight;
    public String thumbUrl;
    public long fileSize;
    public String contentType;
    public String timestamp;
    public String sender;
    public ru.webim.plugin.models.Quote quote;
    public ru.webim.plugin.models.Employee operator;
    public ru.webim.plugin.models.Keyboard keyboard;
    public ru.webim.plugin.models.KeyboardRequest keyboardRequest;
    public boolean isFirst = false;
    public boolean isReadByOperator;
    public boolean canBeReplied;
    public boolean canBeEdited;

    public static Message fromParams(String id,
                                     String text,
                                     String url,
                                     String timestamp,
                                     String sender,
                                     ru.webim.android.sdk.Message quote,
                                     boolean isFirst) {
        Message resultMessage = new Message();
        resultMessage.id = id;
        resultMessage.text = text;
        resultMessage.sender = sender;
        resultMessage.timestamp = timestamp;
        resultMessage.url = url;
        resultMessage.isFirst = isFirst;
        if (quote != null) {
            resultMessage.quote = ru.webim.plugin.models.Quote.getQuote(quote.getQuote());
        }
        resultMessage.canBeReplied = false;
        resultMessage.canBeEdited = false;
        resultMessage.isReadByOperator = false;

        return resultMessage;
    }

    public static Message fromWebimMessage(ru.webim.android.sdk.Message message) {
        Message resultMessage = new Message();
        resultMessage.id = message.getClientSideId().toString();
        resultMessage.currentChatID = message.getServerSideId();
        resultMessage.text = message.getText();
        resultMessage.isReadByOperator = message.isReadByOperator();
        resultMessage.canBeReplied = message.canBeReplied();
        resultMessage.canBeEdited = message.canBeEdited();
        if (message.getType() != ru.webim.android.sdk.Message.Type.FILE_FROM_OPERATOR
                && message.getType() != ru.webim.android.sdk.Message.Type.OPERATOR) {
            resultMessage.sender = message.getSenderName();
        } else {
            resultMessage.operator = ru.webim.plugin.models.Employee.getEmployeeFromParams(message.getSenderName(),
                    message.getSenderAvatarUrl());
        }
        ru.webim.android.sdk.Message.Attachment attachment = message.getAttachment();
        if (attachment != null) {
            if (resultMessage.text.trim().isEmpty()) {
                resultMessage.text = attachment.getFileInfo().getFileName();
            }
            resultMessage.url = attachment.getFileInfo().getUrl();
            resultMessage.fileSize = attachment.getFileInfo().getSize();
            resultMessage.contentType = attachment.getFileInfo().getContentType();
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

        if (message.getType() == ru.webim.android.sdk.Message.Type.KEYBOARD) {
            resultMessage.keyboard = ru.webim.plugin.models.Keyboard.getKeyboard(message.getKeyboard());
        }

        if (message.getType() == ru.webim.android.sdk.Message.Type.KEYBOARD_RESPONSE) {
            resultMessage.keyboardRequest = ru.webim.plugin.models.KeyboardRequest.getKeyboardRequest(message.getKeyboardRequest());
        }

        if (message.getQuote() != null) {
            resultMessage.quote = ru.webim.plugin.models.Quote.getQuote(message.getQuote());
        }

        return resultMessage;
    }
}