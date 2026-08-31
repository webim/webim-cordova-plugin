package ru.webim.plugin.models;

public class AccountConfig {
    private String hintsEndpoint;
    private boolean rateOperator = true;
    private boolean disablingMessageInputField = false;
    private boolean checkVisitorAuth = false;
    private boolean quotingEnable = true;
    private int maxVisitorUploadFileSize;
    private String allowedUploadFileTypes;
    private String rateForm;
    private String ratedEntity;
    private String visitorSegment;
    private boolean messagesTranslator;
    private boolean visitorMessageEditing;
    private boolean showRateOperator;
    private boolean showProcessingPersonalDataCheckbox;
    private boolean personalDataAgreementConfirmationMandatory;
    private String processingPersonalDataUrl;
    private boolean visitorUploadFile;
    private String logo;
    private boolean multilang;
    private int visitorEnablingProbability;
    private boolean rateOperatorByClickOnAvatar;
    private boolean forceVisitorDisable;
    private String defaultPhoneNumber;
    private boolean visitorTracking;
    private int operatorCheckStatusOnline;
    private boolean visitorWebsockets;
    private String defaultPrompterId;
    private boolean offlineChatProcessing;
    private String clientPhpUrl;
    private boolean operatorStatusTimer;
    private boolean openChatInNewTabForMobile;
    private int defaultSurveyId;
    private boolean teleport;
    private int fileUrlExpiringTimeout;
    private boolean hideReferrer;
    private boolean surveys;
    private boolean trackVisitorTyping;
    private boolean chattingTimer;
    private String defaultLang;
    private boolean useEmojiAnnotations;
    private String privacyPolicyUrl;
    public static AccountConfig accountConfigFromAccountConfigItem(ru.webim.android.sdk.impl.items.AccountConfigItem item) {
        AccountConfig resultState = new AccountConfig();
        resultState.hintsEndpoint = item.getHintsEndpoint();
        resultState.rateOperator = item.getAllowedRateOperator();
        resultState.disablingMessageInputField = item.isDisablingMessageInputField();
        resultState.checkVisitorAuth = item.isCheckVisitorAuth();
        resultState.quotingEnable = item.isQuotingEnable();
        resultState.maxVisitorUploadFileSize = item.getMaxVisitorUploadFileSize();
        resultState.allowedUploadFileTypes = item.getAllowedUploadFileTypes();
        if (item.getRateForm() != null) {
            switch (item.getRateForm()) {
                case STANDARD:
                    resultState.rateForm = "standard";
                    break;
                case RESOLUTION:
                    resultState.rateForm = "resolution";
                    break;
                case COMBINED:
                    resultState.rateForm = "combined";
                    break;
            }
        }
        if (item.getRatedEntity() != null) {
            switch (item.getRatedEntity()) {
                case BOT_ONLY:
                    resultState.ratedEntity = "bot_only";
                    break;
                case OPERATOR_ONLY:
                    resultState.ratedEntity = "operator_only";
                    break;
                case BOTH:
                    resultState.ratedEntity = "both";
                    break;
            }
        }
        if (item.getVisitorSegment() != null) {
            switch (item.getVisitorSegment()) {
                case VIP_SEGMENT:
                    resultState.visitorSegment = "vip_segment";
                    break;
                case MASS_SEGMENT:
                    resultState.visitorSegment = "mass_segment";
                    break;
                case BOTH:
                    resultState.visitorSegment = "both";
                    break;
            }
        }
        resultState.messagesTranslator = item.getMessagesTranslator();
        resultState.visitorMessageEditing = item.getVisitorMessageEditing();
        resultState.showRateOperator = item.getShowRateOperator();
        resultState.showProcessingPersonalDataCheckbox = item.getShowProcessingPersonalDataCheckbox();
        resultState.personalDataAgreementConfirmationMandatory = item.getPersonalDataAgreementConfirmationMandatory();
        resultState.processingPersonalDataUrl = item.getProcessingPersonalDataUrl();
        resultState.visitorUploadFile = item.getVisitorUploadFile();
        resultState.logo = item.getLogo();
        resultState.multilang = item.getMultilang();
        resultState.visitorEnablingProbability = item.getVisitorEnablingProbability();
        resultState.rateOperatorByClickOnAvatar = item.getRateOperatorByClickOnAvatar();
        resultState.forceVisitorDisable = item.getForceVisitorDisable();
        resultState.defaultPhoneNumber = item.getDefaultPhoneNumber();
        resultState.visitorTracking = item.getVisitorTracking();
        resultState.operatorCheckStatusOnline = item.getOperatorCheckStatusOnline();
        resultState.visitorWebsockets = item.getVisitorWebsockets();
        resultState.defaultPrompterId = item.getDefaultPrompterId();
        resultState.offlineChatProcessing = item.getOfflineChatProcessing();
        resultState.clientPhpUrl = item.getClientPhpUrl();
        resultState.operatorStatusTimer = item.getOperatorStatusTimer();
        resultState.openChatInNewTabForMobile = item.getOpenChatInNewTabForMobile();
        resultState.defaultSurveyId = item.getDefaultSurveyId();
        resultState.teleport = item.getTeleport();
        resultState.fileUrlExpiringTimeout = item.getFileUrlExpiringTimeout();
        resultState.hideReferrer = item.getHideReferrer();
        resultState.surveys = item.getSurveys();
        resultState.trackVisitorTyping = item.getTrackVisitorTyping();
        resultState.chattingTimer = item.getChattingTimer();
        resultState.defaultLang = item.getDefaultLang();
        resultState.useEmojiAnnotations = item.getUseEmojiAnnotations();
        resultState.privacyPolicyUrl = item.getPrivacyPolicyUrl();

        return resultState;
    }
}
