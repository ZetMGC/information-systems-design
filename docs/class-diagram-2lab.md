# Диаграмма классов. ЛР 2

## Задание №3

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

## Задание №6

``` mermaid
classDiagram
  %% ===== DOMAIN =====
  class TeacherInfo {
    <<value object>>
    +int? id
    +String lastName
    +String firstName
    +String? middleName
    +String phone
    +toJson() Map
    +toShortString() String
  }

  class Teacher {
    <<entity>>
    +int experienceYears
    +factory create(...)
    +factory withId(...)
    +factory from(Object)
    +factory fromJson(Map)
    +toJson() Map
  }

  TeacherInfo <|-- Teacher

  %% ===== REPOSITORY ABSTRACTION =====
  class TeacherRepBase {
    <<abstract>>
    +Future~List~Teacher~~ readAll()
    +Future~void~ writeAll(List~Teacher~)
    +Future~Teacher?~ getById(int)
    +Future~List~TeacherInfo~~ getKthNShortList(k,n)
    +Future~List~Teacher~~ sortByLastName(persist=false)
    +Future~Teacher~ add(Teacher)
    +Future~bool~ replaceById(int,Teacher)
    +Future~bool~ deleteById(int)
    +Future~int~ getCount()
  }

  %% ===== FILE REPOS =====
  class TeacherRepJson {
    +String path
    +readAll()
    +writeAll(...)
    +... (Base)
  }

  class TeacherRepYaml {
    +String path
    +readAll()
    +writeAll(...)
    +... (Base)
  }

  TeacherRepBase <|-- TeacherRepJson
  TeacherRepBase <|-- TeacherRepYaml

  %% ===== DB PORT & ADAPTER =====
  class DbTx {
    <<interface>>
    +execute(sql,params) Future~int~
    +query(sql,params) Future~List<List<dynamic>>~
    +mappedQuery(sql,params) Future~List<Map<String,Map<String,dynamic>>>~
  }

  class DbClient {
    <<interface>>
    +execute(sql,params) Future~int~
    +query(sql,params) Future~List~List~dynamic~~~
    +mappedQuery(sql,params) Future~List ~Map~String, Map ~String,dynamic~~~~
    +transaction~R~(action: Future~R~(DbTx)) Future~R~
    +scalarInt(sql,params) Future~int~
  }

  class AppDb {
    <<singleton>>
    +open/openFromEnv/close
    +query/execute/mappedQuery/transaction/scalarInt
    -PostgreSQLConnection _conn
  }

  class PgDbClientAdapter {
    <<adapter>>
    -AppDb _db
    +implements DbClient
  }

  %% ===== DB REPO =====
  class TeacherRepDb {
    +DbClient db
    +getById(...)
    +getKthNShortList(...)
    +add(...)
    +replaceById(...)
    +deleteById(...)
    +getCount()
  }

  %% ===== DECORATORS =====
  class TeacherRepFileDecor {
    <<decorator>>
    +TeacherRepBase inner
    +getKthNShortList(...)
    +getCount()
  }

  class TeacherRepDbDecor {
    <<decorator>>
    +TeacherRepBase inner
    +DbClient db
    +QueryFilter filter
    +QuerySort? sort
    +getKthNShortList(...)
    +getCount()
  }

  TeacherRepBase <|-- TeacherRepDb
  TeacherRepDb ..> DbClient 
  PgDbClientAdapter ..|> DbClient
  PgDbClientAdapter ..> AppDb
  TeacherRepBase <|-- TeacherRepFileDecor
  TeacherRepBase <|-- TeacherRepDbDecor
  TeacherRepDbDecor ..> DbClient
```
