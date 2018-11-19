package ru.webim.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;
import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.webkit.MimeTypeMap;


import com.google.gson.Gson;

import com.webimapp.android.sdk.FatalErrorHandler;
import com.webimapp.android.sdk.Message;
import com.webimapp.android.sdk.MessageListener;
import com.webimapp.android.sdk.MessageStream;
import com.webimapp.android.sdk.MessageTracker;
import com.webimapp.android.sdk.Operator;
import com.webimapp.android.sdk.Webim;
import com.webimapp.android.sdk.WebimSession;
import com.webimapp.android.sdk.WebimError;
import com.webimapp.android.sdk.WebimLog;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class WebimSDK extends CordovaPlugin {
    public static final String DEFAULT_ACCOUNT_NAME = "demo";
    public static final String DEFAULT_LOCATION = "mobile";

    private Context context;
    private WebimSession session;
    private Handler handler;
    private ListController listController;

    private CallbackContext receiveMessageCallback;
    private CallbackContext receiveFileCallback;
    private CallbackContext typingMessageCallback;
    private CallbackContext confirmMessageCallback;
    private CallbackContext dialogCallback;
    private CallbackContext banCallback;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.context = cordova.getActivity().getApplicationContext();
        this.handler = new Handler();
    }

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {

        if (action.equals("init")) {
            init(data.getString(0), callbackContext);
            sendNoResult(callbackContext);
            return true;

        } else if (action.equals("sendMessage")) {
            String message = data.getString(0);
            sendMessage(message, callbackContext);
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("requestDialog")) {
            requestDialog(callbackContext);
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("getMessagesHistory")) {
            int limit = Integer.parseInt(data.getString(0));
            int offset = Integer.parseInt(data.getString(1));
            getMessagesHistory(limit, offset, callbackContext);
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("typingMessage")) {
            String message = data.getString(0);
            typingMessage(message, callbackContext);
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("sendFile")) {
            String filePath = data.getString(0);
            sendFile(filePath, callbackContext);
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onMessage")) {
            receiveMessageCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onFile")) {
            receiveFileCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onTyping")) {
            typingMessageCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onConfirm")) {
            confirmMessageCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onDialog")) {
            dialogCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("onBan")) {
            banCallback = callbackContext;
            sendNoResult(callbackContext);
            return true;
        } else if (action.equals("close")) {
            close(callbackContext);
            return true;
        } else {
            return false;
        }
    }

    private void init(final String args, final CallbackContext callbackContext)
            throws JSONException {
        session = Webim.newSessionBuilder()
                .setContext(this.context)
                .setErrorHandler(new FatalErrorHandler() {
                    @Override
                    public void onError(@NonNull WebimError<FatalErrorType> error) {
                        sendCallbackError(callbackContext, "Fail");
                        switch (error.getErrorType()) {
                            case ACCOUNT_BLOCKED:
                            case VISITOR_BANNED:
                                if (banCallback != null) {
                                    sendNotificationCallbackResult(banCallback,
                                            "Visitor is banned");
                                }
                                break;
                            default:
                                break;
                        }
                    }
                })
                .setAccountName(DEFAULT_ACCOUNT_NAME)
                .setLocation(DEFAULT_LOCATION)
                .setLogger(new WebimLog() {
                               @Override
                               public void log(String log) {
                                   Log.i("WEBIM LOG", log);
                               }
                           },
                        Webim.SessionBuilder.WebimLogVerbosityLevel.VERBOSE)
                .build();
        listController = new ListController(session.getStream());
        session.getStream().setOperatorTypingListener(new MessageStream.OperatorTypingListener() {
            @Override
            public void onOperatorTypingStateChanged(boolean isTyping) {
                sendNotificationCallbackResult(typingMessageCallback, "");
            }
        });
        session.getStream().setCurrentOperatorChangeListener(new MessageStream.CurrentOperatorChangeListener() {
            @Override
            public void onOperatorChanged(@Nullable Operator oldOperator,
                                   @Nullable Operator newOperator) {
                sendCallbackResult(dialogCallback,
                        ru.webim.plugin.models.DialogState.dialogStateFromEmployee(newOperator));
            }
        });
        session.resume();
        sendNotificationCallbackResult(callbackContext, "Success");
    }

    private void getMessagesHistory(int limit, int offset, final CallbackContext callbackContext) {
        if (session == null) {
            return;
        }
        listController.requestMore(limit, offset, callbackContext);
    }

    private void requestDialog(final CallbackContext callbackContext) {
        if (session == null) {
            return;
        }
        session.getStream().startChat();
    }

    private void sendMessage(String message, final CallbackContext callbackContext) {
        if (session == null) {
            return;
        }

        session.getStream().sendMessage(message);
    }

    private void sendFile(final String fileUri, final CallbackContext callbackContext) {
        if (session == null) {
            return;
        }

        Uri uri = Uri.parse(fileUri);
        String mime = context.getContentResolver().getType(uri);
        String extension = mime == null
                ? null
                : MimeTypeMap.getSingleton().getExtensionFromMimeType(mime);
        String name = extension == null
                ? null
                : uri.getLastPathSegment() + "." + extension;
        File file = null;
        try {
            InputStream inp = context.getContentResolver().openInputStream(uri);
            if (inp == null) {
                file = null;
            } else {
                file = File.createTempFile("webim",
                        extension, context.getCacheDir());
                writeFully(file, inp);
            }
        } catch (IOException e) {
            Log.e("WEBIM", "failed to copy selected file", e);
            file.delete();
            file = null;
        }

        if (file != null && name != null) {
            final File fileToUpload = file;
            session.getStream().sendFile(fileToUpload,
                    name, mime, new MessageStream.SendFileCallback() {
                        @Override
                        public void onProgress(@NonNull Message.Id id, long sentBytes) {

                        }

                        @Override
                        public void onSuccess(@NonNull Message.Id id) {
                            fileToUpload.delete();
                            sendCallbackResult(callbackContext, true);
                        }

                        @Override
                        public void onFailure(@NonNull Message.Id id,
                                              @NonNull WebimError<SendFileError> error) {
                            fileToUpload.delete();
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
                                    msg = "unkown_error";
                            }
                            sendCallbackError(callbackContext, msg);
                        }
                    });
        }
    }

    private static void writeFully(@NonNull File to, @NonNull InputStream from) throws IOException {
        byte[] buffer = new byte[4096];
        OutputStream out = null;
        try {
            out = new FileOutputStream(to);
            for (int read; (read = from.read(buffer)) != -1; ) {
                out.write(buffer, 0, read);
            }
        } finally {
            from.close();
            if (out != null) {
                out.close();
            }
        }
    }

    private void typingMessage(String text, final CallbackContext callbackContext) {
        if (session == null) {
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
            return;
        }
        receiveMessageCallback = null;
        receiveFileCallback = null;
        typingMessageCallback = null;

        session.destroy();
        session = null;
        sendCallbackResult(callbackContext, "WebimSession Close");

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

        private boolean requestingMessages;

        public ListController(MessageStream stream) {
            this.tracker = stream.newMessageTracker(this);
        }

        private void requestMore(int limit, int offset, final CallbackContext callbackContext) {
            MessageTracker.GetMessagesCallback getMessagesCallback
                    = new MessageTracker.GetMessagesCallback() {
                @Override
                public void receive(@NonNull List<? extends Message> messagesList) {
                    if (messagesList != null) {
                        ArrayList<ru.webim.plugin.models.Message> messagesResult
                                = new ArrayList<ru.webim.plugin.models.Message>();
                        for (Message msg : messagesList) {
                            messagesResult.add(ru.webim.plugin.models.Message.fromWebimMessage(msg));
                        }
                        sendCallbackResult(callbackContext, messagesResult);
                    }
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
            if (message.getType() != Message.Type.FILE_FROM_OPERATOR
                    && message.getType() != Message.Type.FILE_FROM_VISITOR) {
                if (receiveMessageCallback != null) {
                    sendNotificationCallbackResult(receiveMessageCallback,
                            ru.webim.plugin.models.Message.fromWebimMessage(message));
                }
            } else {
                if (receiveFileCallback != null) {
                    sendNotificationCallbackResult(receiveFileCallback,
                            ru.webim.plugin.models.Message.fromWebimMessage(message));
                }
            }
        }

        @Override
        public void messageRemoved(@NonNull Message message) {

        }

        @Override
        public void messageChanged(@NonNull Message from, @NonNull Message to) {
            if (to.getType() != Message.Type.FILE_FROM_OPERATOR
                    && to.getType() != Message.Type.FILE_FROM_VISITOR) {
                /*if (receiveMessageCallback != null) {
                    sendNotificationCallbackResult(receiveMessageCallback,
                            ru.webim.plugin.models.Message.fromWebimMessage(to));
                }*/
            } else {
                if (receiveFileCallback != null) {
                    sendNotificationCallbackResult(receiveFileCallback,
                            ru.webim.plugin.models.Message.fromWebimMessage(to));
                }
            }
        }

        @Override
        public void allMessagesRemoved() {

        }
    }
}

