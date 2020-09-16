package ru.webim.plugin.models;

public class SurveyQuestion {
    public String type;
    public String text;

    public static SurveyQuestion fromParams(String type,
                                            String text) {
        SurveyQuestion resultSurveyQuestion = new SurveyQuestion();
        resultSurveyQuestion.type = type;
        resultSurveyQuestion.text = text;

        return resultSurveyQuestion;
    }

    public static SurveyQuestion fromWebimSurveyQuestion(com.webimapp.android.sdk.Survey.Question surveyQuestion) {
        SurveyQuestion resultSurveyQuestion = new SurveyQuestion();
        switch (surveyQuestion.getType()) {
            case RADIO:
                resultSurveyQuestion.type = "radio";
                break;
            case COMMENT:
                resultSurveyQuestion.type = "comment";
                break;
            case STARS:
                resultSurveyQuestion.type = "stars";
                break;
        }
        resultSurveyQuestion.text = surveyQuestion.getText();

        return resultSurveyQuestion;
    }
}