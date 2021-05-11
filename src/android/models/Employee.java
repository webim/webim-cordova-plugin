package ru.webim.plugin.models;

public class Employee {
    public String id;
    public String firstname;
    public String avatar;

    public static Employee getEmployee(ru.webim.android.sdk.Operator operator) {
        Employee resultEmployee = new Employee();
        if (operator != null) {
            resultEmployee.id = operator.getId().toString();
            resultEmployee.firstname = operator.getName();
            resultEmployee.avatar = operator.getAvatarUrl();
        }

        return resultEmployee;
    }

    public static Employee getEmployeeFromParams(String firstname, String avatar) {
        Employee resultEmployee = new Employee();
        resultEmployee.firstname = firstname;
        resultEmployee.avatar = avatar;

        return resultEmployee;
    }

}