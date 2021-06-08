package ru.webim.plugin.models;

public class Survey {
    public String id;
    public SurveyConfig config;
    public SurveyCurrentQuestionInfo currentQuestionInfo;

    public static Survey fromParams(String id,
                                    SurveyConfig config,
                                    SurveyCurrentQuestionInfo currentQuestionInfo) {
        Survey resultSurvey = new Survey();
        resultSurvey.id = id;
        resultSurvey.config = config;
        resultSurvey.currentQuestionInfo = currentQuestionInfo;

        return resultSurvey;
    }

    public static Survey fromWebimSurvey(ru.webim.android.sdk.Survey survey) {
        Survey resultSurvey = new Survey();
        resultSurvey.id = survey.getId();
        resultSurvey.config = SurveyConfig.fromWebimSurveyConfig(survey.getConfig());
        resultSurvey.currentQuestionInfo = SurveyCurrentQuestionInfo.fromWebimSurveyCurrentQuestionInfo(survey.getCurrentQuestionInfo());

        return resultSurvey;
    }
}