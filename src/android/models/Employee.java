package ru.webim.plugin.models;

public class Employee {
    public String id;
    public String firstname;
    public String avatar;

    public static Employee getEmployee(com.webimapp.android.sdk.Operator operator) {
        Employee resultEmployee = new Employee();
        if (operator != null) {
            resultEmployee.id = operator.getId().toString();
            resultEmployee.firstname = operator.getName();
            resultEmployee.avatar = operator.getAvatarUrl();
        }

        return resultEmployee;
    }

}