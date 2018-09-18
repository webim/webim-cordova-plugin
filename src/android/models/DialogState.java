package ru.webim.plugin.models;

public class DialogState {
    public Employee employee;

    public static DialogState dialogStateFromEmployee(com.webimapp.android.sdk.Operator operator) {
        DialogState resultState = new DialogState();
        resultState.employee = Employee.getEmployee(operator);

        return resultState;
    }
}