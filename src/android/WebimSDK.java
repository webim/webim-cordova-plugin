package ru.webim.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.webkit.MimeTypeMap;


import com.google.gson.Gson;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import ru.webim.android.sdk.FatalErrorHandler;
import ru.webim.android.sdk.Message;
import ru.webim.android.sdk.MessageListener;
import ru.webim.android.sdk.MessageStream;
import ru.webim.android.sdk.MessageTracker;
import ru.webim.android.sdk.Operator;
import ru.webim.android.sdk.Survey;
import ru.webim.android.sdk.Webim;
import ru.webim.android.sdk.WebimSession;
import ru.webim.android.sdk.Webim.SessionBuilder;
import ru.webim.android.sdk.WebimError;
import ru.webim.android.sdk.WebimLog;
import ru.webim.android.sdk.impl.StringId;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class WebimSDK extends CordovaPlugin {
    private static final String DEFAULT_LOCATION = "mobile";

    private Activity activity;
    private Context context;
    private String accountName;
    private WebimSession session;
    private Handler handler;
    private ListController listController;
    private boolean closeWithClearVisitorData = false;
    private boolean hasFirstMessage;

    private CallbackContext receiveMessageCallback;
    private CallbackContext receiveFileCallback;
    private CallbackContext typingMessageCallback;
    private CallbackContext confirmMessageCallback;
    private CallbackContext dialogCallback;
    private CallbackContext banCallback;
    private CallbackContext rateOperatorCallback;
    private CallbackContext sendDialogToEmailAddressCallback;
    private CallbackContext showRateOperatorWindowCallback;
    private CallbackContext onUnreadByVisitorMessageCountCallback;
    private CallbackContext onDeletedMessageCallback;
    private CallbackContext onSurveyCallback;
    private CallbackContext onNextQuestionCallback;
    private CallbackContext onSurveyCancelCallback;
    private CallbackContext onLoggingCallback;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.activity = cordova.getActivity();
        this.context = cordova.getActivity().getApplicationContext();
        this.handler = new Handler();
    }

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext)
            throws JSONException {

        switch (action) {
            case "init":
                init(data.getJSONObject(0), callbackContext);
                return true;

            case "sendMessage":
                String message = data.getString(0);
                sendMessage(message, callbackContext);
                return true;

            case "requestDialog":
                requestDialog(callbackContext);
                return true;

            case "getMessagesHistory":
                int limit = Integer.parseInt(data.getString(0));
                int offset = Integer.parseInt(data.getString(1));
                getMessagesHistory(limit, offset, callbackContext);
                return true;

            case "typingMessage":
                typingMessage(data.getString(0), callbackContext);
                return true;

            case "sendFile":
                String filePath = data.getString(0);
                sendFile(filePath, callbackContext);
                return true;

            case "sendSurveyAnswer":
                String surveyAnswer = data.getString(0);
                sendSurveyAnswer(surveyAnswer, callbackContext);
                return true;

            case "cancelSurvey":
                cancelSurvey(callbackContext);
                return true;

            case "sendKeyboardRequest":
                String requestMessageCurrentChatId = data.getString(0);
                String buttonID = data.getString(1);
                sendKeyboardRequest(requestMessageCurrentChatId, buttonID, callbackContext);
                return true;

            case "onMessage":
                receiveMessageCallback = callbackContext;
                return true;

            case "onDeletedMessage":
                onDeletedMessageCallback = callbackContext;
                return true;

            case "onFile":
                receiveFileCallback = callbackContext;
                return true;

            case "onTyping":
                typingMessageCallback = callbackContext;
                return true;

            case "onConfirm":
                confirmMessageCallback = callbackContext;
                return true;

            case "onDialog":
                dialogCallback = callbackContext;
                return true;

            case "onBan":
                banCallback = callbackContext;
                return true;

            case "close":
                close(callbackContext);
                return true;

            case "rateOperator":
                String id = data.getString(0);
                int rating = Integer.parseInt(data.getString(1));
                rateOperator(id, rating, null, callbackContext);
                return true;

            case "rateOperatorWithNote":
                String idWithNote = data.getString(0);
                int ratingWithNote = Integer.parseInt(data.getString(1));
                String note = data.getString(2);
                rateOperator(idWithNote, ratingWithNote, note, callbackContext);
                return true;

            case "showRateOperatorWindow":
                showRateOperatorWindowCallback = callbackContext;
                return true;

            case "sendDialogToEmailAddress":
                String emailAddress = data.getString(0);
                sendDialogToEmailAddress(emailAddress, callbackContext);
                return true;

            case "setChatRead":
                setChatRead(callbackContext);
                return true;

            case "onUnreadByVisitorMessageCount":
                onUnreadByVisitorMessageCountCallback = callbackContext;
                return true;

            case "onSurvey":
                onSurveyCallback = callbackContext;
                return true;

            case "onNextQuestion":
                onNextQuestionCallback = callbackContext;
                return true;

            case "onSurveyCancel":
                onSurveyCancelCallback = callbackContext;
                return true;

            case "getUnreadByVisitorMessageCount":
                getUnreadByVisitorMessageCount(callbackContext);
                return true;

            case "getShowEmailButton":
                getShowEmailButton(callbackContext);
                return true;

            case "onLogging":
                onLoggingCallback = callbackContext;
                return true;

            default:
                return false;
        }
    }

    private void init(final JSONObject args, final CallbackContext callbackContext)
            throws JSONException {
        if (session != null) {
            close(null);
        }
        if (!args.has("accountName")) {
            sendCallbackError(callbackContext, "{\"result\":\"Missing required parameters\"}");
            return;
        }
        accountName = args.getString("accountName");
        if (args.has("closeWithClearVisitorData")) {
            closeWithClearVisitorData = args.getBoolean("closeWithClearVisitorData");
        }
        SessionBuilder sessionBuilder = Webim.newSessionBuilder()
                .setContext(this.context)
                .setErrorHandler(new FatalErrorHandler() {
                    @Override
                    public void onError(@NonNull WebimError<FatalErrorType> error) {
                        sendCallbackError(callbackContext, "{\"result\":\"Fail: \"" + error.getErrorString() + "}");
                        switch (error.getErrorType()) {
                            case ACCOUNT_BLOCKED:
                            case VISITOR_BANNED:
                                if (banCallback != null) {
                                    sendNotificationCallbackResult(banCallback,
                                            "{\"result\":\"Visitor is banned\"}");
                                }
                                break;
                            case WRONG_PROVIDED_VISITOR_HASH:
                                if (banCallback != null) {
                                    sendNotificationCallbackResult(banCallback,
                                            "{\"result\":\"Wrong provided visitor hash\"}");
                                }
                                break;
                            default:
                                break;
                        }
                    }
                })
                .setAccountName(args.getString("accountName"))
                .setPushSystem(Webim.PushSystem.FCM)
                .setPushToken(args.has("pushToken")
                        ? args.getString("pushToken")
                        : "none")
                .setLocation(args.has("location")
                        ? args.getString("location")
                        : DEFAULT_LOCATION)
                .setStoreHistoryLocally(args.has("storeHistoryLocally")
                        && args.getBoolean("storeHistoryLocally"));

        if (args.has("visitorFields")) {
            sessionBuilder.setVisitorFieldsJson(args.getJSONObject("visitorFields").toString());
        }
        if (onLoggingCallback != null) {
            sessionBuilder.setLogger(new WebimLog() {
                        @Override
                        public void log(String log) {
                            sendNotificationCallbackResult(onLoggingCallback, "{\"log\":\"" + log + "\"}");
                        }
                    },
                    Webim.SessionBuilder.WebimLogVerbosityLevel.VERBOSE);
        }
        session = sessionBuilder.build(new WebimSession.SessionCallback() {
            @Override
            public void onSuccess() {
                sendNotificationCallbackResult(callbackContext, "{\"result\":\"Success\"}");
            }

            @Override
            public void onFailure(WebimError<SessionError> sessionError) {

            }
        });
        listController = new ListController(session.getStream());
        session.getStream().setOperatorTypingListener(new MessageStream.OperatorTypingListener() {
            @Override
            public void onOperatorTypingStateChanged(boolean isTyping) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, isTyping);
                pluginResult.setKeepCallback(true);
                typingMessageCallback.sendPluginResult(pluginResult);
            }
        });
        session.getStream().setCurrentOperatorChangeListener(
                new MessageStream.CurrentOperatorChangeListener() {
                    @Override
                    public void onOperatorChanged(@Nullable Operator oldOperator,
                                                  @Nullable Operator newOperator) {
                        sendCallbackResult(dialogCallback,
                                ru.webim.plugin.models.DialogState.dialogStateFromEmployee(newOperator));
                    }
                });
        session.getStream().setUnreadByVisitorMessageCountChangeListener(new MessageStream.UnreadByVisitorMessageCountChangeListener() {
            @Override
            public void onUnreadByVisitorMessageCountChanged(int newMessageCount) {
                sendNotificationCallbackResult(onUnreadByVisitorMessageCountCallback, "{\"unreadByVisitorMessageCount\":" + newMessageCount + "}");
            }
        });
        session.getStream().setSurveyListener(new MessageStream.SurveyListener() {
            @Override
            public void onSurvey(Survey survey) {
                sendNotificationCallbackResult(onSurveyCallback, ru.webim.plugin.models.Survey.fromWebimSurvey(survey));
            }

            @Override
            public void onNextQuestion(Survey.Question question) {
                sendNotificationCallbackResult(onNextQuestionCallback, ru.webim.plugin.models.SurveyQuestion.fromWebimSurveyQuestion(question));
            }

            @Override
            public void onSurveyCancelled() {
                sendNotificationCallbackResult(onSurveyCancelCallback, "{\"result\":\"Success\"}");
            }
        });
        session.getStream().setChatStateListener(new MessageStream.ChatStateListener() {
            @Override
            public void onStateChange(@androidx.annotation.NonNull MessageStream.ChatState oldState, @androidx.annotation.NonNull MessageStream.ChatState newState) {
                if (oldState == MessageStream.ChatState.CHATTING && newState == MessageStream.ChatState.CLOSED_BY_OPERATOR) {
                    sendNotificationCallbackResult(showRateOperatorWindowCallback, "{\"result\":\"Success\"}");
                }
            }
        });
        session.resume();
    }

    private void getMessagesHistory(int limit, int offset, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        listController.requestMore(limit, offset, callbackContext);
    }

    private void requestDialog(final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        session.getStream().startChat();
        sendNotificationCallbackResult(callbackContext, "{\"result\":\"Chat is started.\"}");
    }

    private void sendMessage(String message, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }

        String id = session.getStream().sendMessage(message).toString();
        ru.webim.plugin.models.Message msg;
        if (session.getStream().getChatState() == MessageStream.ChatState.NONE
                || session.getStream().getChatState() == MessageStream.ChatState.UNKNOWN) {
            msg = ru.webim.plugin.models.Message.fromParams(id, message, null,
                    Long.toString(System.currentTimeMillis()), null, true);
            hasFirstMessage = true;
        } else {
            msg = ru.webim.plugin.models.Message.fromParams(id, message, null,
                    Long.toString(System.currentTimeMillis()), null, false);
        }
        sendNotificationCallbackResult(callbackContext, msg);
    }

    @SuppressLint("Recycle")
    private static String getFilePath(Context context, String fileUri) {
        Uri uri = Uri.parse(fileUri);
        if ("content".equalsIgnoreCase(uri.getScheme())) {
            String[] projection = {"_data"};
            Cursor cursor;
            try {
                cursor = context.getContentResolver().query(uri, projection, null, null, null);
                int column_index = cursor.getColumnIndexOrThrow("_data");
                if (cursor.moveToFirst()) {
                    String path = cursor.getString(column_index);
                    return path == null ? fileUri : path;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }
        return fileUri;
    }

    public static String getMimeType(Context context, Uri uri) {
        String extension;
        if (uri.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
            final MimeTypeMap mime = MimeTypeMap.getSingleton();
            extension = mime.getExtensionFromMimeType(context.getContentResolver().getType(uri));
        } else {
            extension = MimeTypeMap.getFileExtensionFromUrl(Uri.fromFile(new File(uri.getPath())).toString());
        }
        return extension != null ? MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase()) : null;
    }

    private void sendFile(final String fileUri, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    final File file = new File(getFilePath(context, fileUri));
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                Uri uri = Uri.fromFile(file);
                                String mime = getMimeType(context, uri);
                                if (mime == null) {
                                    mime = "image/png";
                                }
                                if (session.getStream().getChatState() == MessageStream.ChatState.NONE
                                        || session.getStream().getChatState() == MessageStream.ChatState.UNKNOWN) {
                                    hasFirstMessage = true;
                                }
                                session.getStream().sendFile(file,
                                        file.getName(), mime, new MessageStream.SendFileCallback() {
                                            @Override
                                            public void onProgress(@NonNull Message.Id id, long sentBytes) {

                                            }

                                            @Override
                                            public void onSuccess(@NonNull Message.Id id) {
                                                file.delete();
                                                sendCallbackResult(callbackContext, id.toString());
                                            }

                                            @Override
                                            public void onFailure(@NonNull Message.Id id,
                                                                  @NonNull WebimError<SendFileError> error) {
                                                file.delete();
                                                String msg;
                                                switch (error.getErrorType()) {
                                                    case FILE_TYPE_NOT_ALLOWED:
                                                        msg = "file_type_not_allowed";
                                                        break;
                                                    case FILE_SIZE_EXCEEDED:
                                                        msg = "file_size_exceeded";
                                                        break;
                                                    case UPLOADED_FILE_NOT_FOUND:
                                                    default:
                                                        msg = "unknown_error";
                                                }
                                                sendCallbackError(callbackContext, "{\"result\":\"" + msg + "\"}");
                                            }
                                        });
                            } catch (Exception e) {
                                sendCallbackError(callbackContext, e.getMessage());
                            }
                        }
                    });
                } catch (Exception e) {
                    sendCallbackError(callbackContext, e.getMessage());
                }
            }
        }).start();
    }

    private void sendSurveyAnswer(String surveyAnswer, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        session.getStream().sendSurveyAnswer(surveyAnswer, new MessageStream.SurveyAnswerCallback() {
            @Override
            public void onSuccess() {
                sendCallbackResult(callbackContext, "{\"result\":\"Success\"}");
            }

            @Override
            public void onFailure(WebimError<SurveyAnswerError> webimError) {
                sendCallbackError(callbackContext, "{\"result\":\"Failure\"}");
            }
        });
    }

    private void cancelSurvey(final  CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        session.getStream().closeSurvey(new MessageStream.SurveyCloseCallback() {
            @Override
            public void onSuccess() {
                sendCallbackResult(callbackContext, "{\"result\":\"Success\"}");
            }

            @Override
            public void onFailure(WebimError<MessageStream.SurveyCloseCallback.SurveyCloseError> webimError) {
                sendCallbackError(callbackContext, "{\"result\":\"Failure\"}");
            }
        });
    }

    private void sendKeyboardRequest(String requestMessageCurrentChatId, String buttonID, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        session.getStream().sendKeyboardRequest(requestMessageCurrentChatId, buttonID, new MessageStream.SendKeyboardCallback() {
            @Override
            public void onSuccess(@NonNull Message.Id messageId) {
                sendCallbackResult(callbackContext, "{\"result\":\"Success\"}");
            }

            @Override
            public void onFailure(@NonNull Message.Id messageId, @NonNull WebimError<SendKeyboardError> error) {
                sendCallbackError(callbackContext, "{\"result\":\"" + error.getErrorString() + "\"}");
            }
        });
    }

    private void typingMessage(String text, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        if (text.length() == 0) {
            text = null;
        }
        session.getStream().setVisitorTyping(text);
        sendCallbackResult(callbackContext, text);
    }

    private void close(final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        receiveMessageCallback = null;
        receiveFileCallback = null;
        confirmMessageCallback = null;
        banCallback = null;
        rateOperatorCallback = null;
        showRateOperatorWindowCallback = null;
        sendDialogToEmailAddressCallback = null;
        onDeletedMessageCallback = null;
        if (callbackContext != null) {
            typingMessageCallback = null;
            onUnreadByVisitorMessageCountCallback = null;
            dialogCallback = null;
            onSurveyCallback = null;
            onSurveyCancelCallback = null;
            onNextQuestionCallback = null;
            onLoggingCallback = null;
        }

        if (closeWithClearVisitorData) {
            session.destroyWithClearVisitorData();
            closeWithClearVisitorData = false;
        } else {
            session.destroy();
        }
        session = null;
        accountName = null;
        listController = null;
        sendCallbackResult(callbackContext, "{\"result\":\"WebimSession Close\"}");

    }

    private void rateOperator(String id, int rating, String note, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        rateOperatorCallback = callbackContext;
        session.getStream().rateOperator(StringId.forOperator(id), note, rating, new MessageStream.RateOperatorCallback() {
            @Override
            public void onSuccess() {
                sendCallbackResult(rateOperatorCallback, "{\"result\":\"Rate operator successfully.\"}");
            }

            @Override
            public void onFailure(@NonNull WebimError<RateOperatorError> error) {
                switch (error.getErrorType()) {
                    case NO_CHAT:
                        sendCallbackError(rateOperatorCallback, "{\"result\":\"No chat.\"}");
                        break;
                    case OPERATOR_NOT_IN_CHAT:
                        sendCallbackError(rateOperatorCallback, "{\"result\":\"this operator does not belong to existing chat.\"}");
                        break;
                    default:
                        sendCallbackError(rateOperatorCallback, "{\"result\":\"Unknown send dialog to email address error.\"}");
                        break;
                }
            }
        });
    }

    private void sendDialogToEmailAddress(String emailAddress, final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        sendDialogToEmailAddressCallback = callbackContext;
        session.getStream().sendDialogToEmailAddress(emailAddress,
                new MessageStream.SendDialogToEmailAddressCallback() {
                    @Override
                    public void onSuccess() {
                        sendCallbackResult(sendDialogToEmailAddressCallback , "{\"result\":\"Dialog sent to email address.\"}");
                    }

                    @Override
                    public void onFailure(@NonNull WebimError<SendDialogToEmailAddressError> error) {
                        switch (error.getErrorType()) {
                            case NO_CHAT:
                                sendCallbackError(sendDialogToEmailAddressCallback, "{\"result\":\"No chat.\"}");
                                break;
                            case SENT_TOO_MANY_TIMES:
                                sendCallbackError(sendDialogToEmailAddressCallback, "{\"result\":\"Sent too many times.\"}");
                                break;
                            case UNKNOWN:
                                sendCallbackError(sendDialogToEmailAddressCallback, "{\"result\":\"Unknown send dialog to email address error.\"}");
                                break;
                        }
                    }
                });
    }

    private void setChatRead(final CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        session.getStream().setChatRead();
    }

    private void getUnreadByVisitorMessageCount(CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        int count = session.getStream().getUnreadByVisitorMessageCount();
        sendCallbackResult(callbackContext, "{\"unreadByVisitorMessageCount\":" + count + "}");
    }

    private void getShowEmailButton(CallbackContext callbackContext) {
        if (session == null) {
            sendCallbackError(callbackContext, "{\"result\":\"Session initialisation expected\"}");
            return;
        }
        String url;
        if (accountName.contains("https://") || accountName.contains("http://")) {
            if (accountName.endsWith("/")) {
                accountName = accountName.substring(0, accountName.length() - 1);
            }
            url = accountName + "/js/v/all-settings.js.php";
        } else {
            url ="https://" + accountName + ".webim.ru/js/v/all-settings.js.php";
        }
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder().url(url).build();
        try {
            Response response = client.newCall(request).execute();
            String bodyString = response.body().string();
            String jsonString = bodyString.substring(29, bodyString.length() - 2);
            JSONObject obj = new JSONObject(jsonString);
            boolean showEmailButton = obj.getJSONObject("accountConfig").getBoolean("show_visitor_send_chat_to_email_button");
            sendCallbackResult(callbackContext, "{\"showEmailButton\":" + showEmailButton + "}");
        } catch (Exception e) {
            sendCallbackError(callbackContext, e.toString());
        }
    }

    private void sendNoResult(CallbackContext callbackContext) {
        if (callbackContext == null) {
            return;
        }
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    private void sendCallbackResult(CallbackContext callbackContext, Object data) {
        if (callbackContext == null) {
            return;
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, new Gson().toJson(data));
        pluginResult.setKeepCallback(false);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void sendCallbackError(CallbackContext callbackContext, String error) {
        if (callbackContext == null) {
            return;
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, error);
        pluginResult.setKeepCallback(false);
        callbackContext.sendPluginResult(pluginResult);
    }

    private static void sendNotificationCallbackResult(CallbackContext callbackContext, Object data) {
        if (callbackContext == null) {
            return;
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, new Gson().toJson(data));
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void sendNotificationCallbackResult(CallbackContext callbackContext, String data) {
        if (callbackContext == null) {
            return;
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, data);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);

    }

    private void sendNotificationCallbackError(CallbackContext callbackContext, String data) {
        if (callbackContext == null) {
            return;
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, data);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
    }

    private class ListController implements MessageListener {
        private final MessageTracker tracker;

        ListController(MessageStream stream) {
            this.tracker = stream.newMessageTracker(this);
        }

        private void requestMore(int limit, int offset, final CallbackContext callbackContext) {
            MessageTracker.GetMessagesCallback getMessagesCallback
                    = new MessageTracker.GetMessagesCallback() {
                @Override
                public void receive(@NonNull List<? extends Message> messagesList) {
                    List<ru.webim.plugin.models.Message> messagesResult
                            = new ArrayList<ru.webim.plugin.models.Message>();
                    for (Message msg : messagesList) {
                        messagesResult.add(ru.webim.plugin.models.Message.fromWebimMessage(msg));
                    }
                    sendCallbackResult(callbackContext, messagesResult);
                }
            };
            if (offset == 0) {
                tracker.getLastMessages(limit, getMessagesCallback);
            } else {
                tracker.getNextMessages(limit, getMessagesCallback);
            }
        }

        @Override
        public void messageAdded(@Nullable Message before, @NonNull Message message) {
            ru.webim.plugin.models.Message msg = ru.webim.plugin.models.Message.fromWebimMessage(message);
            if (message.getType() != Message.Type.FILE_FROM_OPERATOR
                    && message.getType() != Message.Type.FILE_FROM_VISITOR) {
                if (receiveMessageCallback != null && message.getType() != Message.Type.VISITOR) {
                    sendNotificationCallbackResult(receiveMessageCallback, msg);
                }
            } else {
                if (receiveFileCallback != null) {
                    if (hasFirstMessage) {
                        msg.isFirst = true;
                        hasFirstMessage = false;
                    }
                    sendNotificationCallbackResult(receiveFileCallback, msg);
                }
            }
        }

        @Override
        public void messageRemoved(@NonNull Message message) {
            sendNotificationCallbackResult(onDeletedMessageCallback,
                    ru.webim.plugin.models.Message.fromWebimMessage(message));
        }

        @Override
        public void messageChanged(@NonNull Message from, @NonNull Message to) {
            ru.webim.plugin.models.Message message = ru.webim.plugin.models.Message.fromWebimMessage(to);
            if (to.getType() != Message.Type.FILE_FROM_OPERATOR
                    && to.getType() != Message.Type.FILE_FROM_VISITOR) {
                if (confirmMessageCallback != null) {
                    if (hasFirstMessage) {
                        message.isFirst = true;
                        hasFirstMessage = false;
                    }
                    sendNotificationCallbackResult(confirmMessageCallback, message);
                }
            } else {
                if (receiveFileCallback != null) {
                    sendNotificationCallbackResult(receiveFileCallback, message);
                }
            }
        }

        @Override
        public void allMessagesRemoved() {

        }
    }
}

