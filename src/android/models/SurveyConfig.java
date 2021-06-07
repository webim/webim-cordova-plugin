package ru.webim.plugin.models;

public class SurveyConfig {
    public String id;
    public String version;

    public static SurveyConfig fromParams(String id,
                                          String version) {
        SurveyConfig resultSurveyConfig = new SurveyConfig();
        resultSurveyConfig.id = id;
        resultSurveyConfig.version = version;

        return resultSurveyConfig;
    }

    public static SurveyConfig fromWebimSurveyConfig(ru.webim.android.sdk.Survey.Config surveyConfig) {
        SurveyConfig resultSurveyConfig = new SurveyConfig();
        resultSurveyConfig.id = Integer.toString(surveyConfig.getId());
        resultSurveyConfig.version = surveyConfig.getVersion();

        return resultSurveyConfig;
    }
}