package ru.webim.plugin.models;

public class Quote {
    public String state;
    public String id;
    public String text;
    public String url;
    public String timestamp;
    public String senderName;
    public String authorID;

    public static Quote getQuote(ru.webim.android.sdk.Message.Quote quote) {
        if (quote == null) {
            return null;
        }
        ru.webim.plugin.models.Quote resultQuote = new ru.webim.plugin.models.Quote();
        switch (quote.getState()) {
            case PENDING:
                resultQuote.state = "pending";
                break;
            case FILLED:
                resultQuote.state = "filled";
                break;
            case NOT_FOUND:
                resultQuote.state = "notFound";
                break;
        }
        resultQuote.id = quote.getMessageId();
        resultQuote.senderName = quote.getSenderName();
        resultQuote.text = quote.getMessageText();
        resultQuote.timestamp = String.valueOf(quote.getMessageTimestamp());
        resultQuote.authorID = quote.getAuthorId();
        if (quote.getMessageAttachment() != null) {
            resultQuote.url = quote.getMessageAttachment().getUrl();
        }
        return resultQuote;
    }
}
