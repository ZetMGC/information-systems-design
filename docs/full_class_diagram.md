# full class diagram

``` mermaid

    classDiagram
    direction TB

    class TeacherInfo {
    - int? _id
    - String _lastName
    - String _firstName
    - String? _middleName
    - String _phone

    <<constructor>> TeacherInfo._(id: int?, lastName: String, firstName: String, middleName: String?, phone: String)

    + int? get id
    + String get lastName
    + String get firstName
    + String? get middleName
    + String get phone

    %% --- статические утилиты/валидация ---
    <<static>> + RegExp nameRe
    <<static>> + RegExp phoneRe
    <<static>> + String norm(s: String)
    <<static>> + String? normOpt(s: String?)
    <<static>> + bool isValidName(s: String)
    <<static>> + bool isValidPhone(s: String)
    <<static>> + void require(cond: bool, message: String)
    <<static>> + void validateNameField(value: String?, label: String, optional: bool=false)

    %% --- поведение/вывод/равенство ---
    + String toShortString()
    + String toString()
    + bool operator ==(other: Object)
    + int get hashCode

    %% --- фабрики ---
    <<factory>> + TeacherInfo brief(id: int?, lastName: String, firstName: String, middleName: String?, phone: String)
    }

    class Teacher {
    - int _experienceYears

    <<constructor>> Teacher._(id: int?, lastName: String, firstName: String, middleName: String?, phone: String, experienceYears: int)

    + int get experienceYears

    %% --- статическая валидация специфики Teacher ---
    <<static>> + bool isValidExperience(years: int)
    <<static>> + void validateAll(lastName: String, firstName: String, middleName: String?, phone: String, experienceYears: int)

    %% --- фабрики/создание из разных источников ---
    <<factory>> + Teacher from(source: Object, separator: String=";")
    <<factory>> + Teacher create(lastName: String, firstName: String, middleName: String?, phone: String, experienceYears: int)
    <<factory>> + Teacher withId(id: int, lastName: String, firstName: String, middleName: String?, phone: String, experienceYears: int)
    <<factory>> + Teacher fromString(line: String, separator: String=";")
    <<factory>> + Teacher fromJson(json: Map~String,dynamic~)
    <<static>> - Teacher _fromList(list: List)

    %% --- копирование/вывод/равенство ---
    + Teacher copyWithId(id: int)
    + String toString()
    + bool operator ==(other: Object)
    + int get hashCode
    }

    TeacherInfo <|-- Teacher

    note for Teacher "Наследует все краткие поля/поведение от TeacherInfo.</br>Добавляет стаж + фабрики из разных форматов."
```
