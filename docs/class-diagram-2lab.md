# Диаграмма классов. ЛР 2

``` mermaid
classDiagram
    class TeacherInfo {
      +int? id
      +String lastName
      +String firstName
      +String? middleName
      +String phone
      +toJson() Map
      +fromJson(Map) TeacherInfo
    }

    class Teacher {
      <<extends TeacherInfo>>
      -int _experienceYears
      +int experienceYears
      +static from(Object): Teacher
      +create(...)
      +withId(...)
      +copyWithId(id)
      +fromJson(Map)
      +fromString(String)
      +toJson() Map
    }

    class TeacherRepBase {
      <<abstract>>
      +String path
      +readAll() Future *abstract*
      +writeAll(ListTe) Future *abstract*
      +getById(int) Future~Teacher?~
      +getKthNShortList(k,n) Future~List~Teacher~~
      +sortByLastName(persist) Future~List~Teacher~~
      +add(Teacher) Future~Teacher~
      +replaceById(int,Teacher) Future~bool~
      +deleteById(int) Future~bool~
      +getCount() Future~int~
    }

    class TeacherRepJson {
      +String path
      +readAll() Future~List~Teacher~~ *override*
      +writeAll(List) Future~void~ *override*
    }

    class TeacherRepYaml {
      +String path
      +readAll() Future~List~Teacher~~ *override*
      +writeAll(List) Future~void~ *override* 
    }

    TeacherInfo <|-- Teacher
    TeacherRepBase <|-- TeacherRepJson
    TeacherRepBase <|-- TeacherRepYaml
```
