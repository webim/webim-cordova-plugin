package ru.webim.plugin.models;

public class SurveyCurrentQuestionInfo {
    public String formId;
    public String questionId;

    public static SurveyCurrentQuestionInfo fromParams(String formId,
                                                       String questionId) {
        SurveyCurrentQuestionInfo resultSurveyCurrentQuestionInfo = new SurveyCurrentQuestionInfo();
        resultSurveyCurrentQuestionInfo.formId = formId;
        resultSurveyCurrentQuestionInfo.questionId = questionId;

        return resultSurveyCurrentQuestionInfo;
    }

    public static SurveyCurrentQuestionInfo fromWebimSurveyCurrentQuestionInfo(com.webimapp.android.sdk.Survey.CurrentQuestionInfo surveyCurrentQuestionInfo) {
        SurveyCurrentQuestionInfo resultSurveyCurrentQuestionInfo = new SurveyCurrentQuestionInfo();
        resultSurveyCurrentQuestionInfo.formId = Integer.toString(surveyCurrentQuestionInfo.getFormId());
        resultSurveyCurrentQuestionInfo.questionId = Integer.toString(surveyCurrentQuestionInfo.getQuestionId());

        return resultSurveyCurrentQuestionInfo;
    }
}