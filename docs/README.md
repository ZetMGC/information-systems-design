# Teacher domain & repositories

## Архитектура каталогов

- `lib/domain/teacher_info.dart` — базовый value object TeacherInfo: хранение id/ФИО/телефона, валидация, `toJson`/`fromJson`.
- `lib/domain/teacher.dart` — агрегат Teacher с опытом работы и множеством фабрик для импорта/экспорта.
- `lib/domain/teacher_rep_base.dart` — абстрактное хранилище с общими CRUD-операциями и пагинацией.
- `lib/domain/teacher_lib.dart` — фасадная библиотека, экспортирующая все доменные сущности и реализации репозиториев.
- `lib/infrastructure/file/teacher_rep_json.dart` — файловый репозиторий, работающий с JSON-массивом.
- `lib/infrastructure/file/teacher_rep_yaml.dart` — файловый репозиторий на YAML (корень-список или объект с полем `teachers`).
- `lib/infrastructure/db/teacher_rep_db.dart` — репозиторий поверх PostgreSQL (`postgres` package).
- `test/*.dart` — модульные и интеграционные тесты, фиксирующие контракт слоёв.

## Доменные классы

### TeacherInfo

- Иммутабельное значение с полями `id`, `lastName`, `firstName`, `middleName`, `phone`.
- `TeacherInfo.brief(...)` нормализует пробелы и валидирует ФИО/телефон через `validateNameField`, `isValidPhone`, `require`.
- `TeacherInfo.fromJson(Map)` поддерживает camelCase и snake_case ключи, преобразует строковые числа к int.
- `toJson()` всегда пишет snake_case (совместимо с JSON и YAML репозиториями).
- `toShortString()`, переопределённые `==/hashCode` и `toString()` используются в отображении и тестах.

### Teacher

- Наследует TeacherInfo и добавляет `experienceYears` с проверками `isValidExperience` и `validateAll`.
- `Teacher.from(Object source)` принимает Teacher, JSON или CSV строку, Map/Iterable, а также dart records; парсинг делегирует в соответствующие фабрики.
- `Teacher.create(...)` и `Teacher.withId(...)` используются для создания/обновления записей; `copyWithId` помогает переиспользовать экземпляры.
- `Teacher.fromString(line, separator: ';')` разбирает CSV (5 или 6 столбцов), `Teacher.fromJson(Map)` — гибко читает ключи и числа.
- `toJson()` возвращает map со snake_case и `experience_years`, что делает экземпляры сериализуемыми без дополнительного DTO.

### TeacherRepBase

- Определяет асинхронные `readAll()`/`writeAll()` — единственные абстрактные методы, которые реализуют конкретные репозитории.
- Общие операции (`getById`, `add`, `replaceById`, `deleteById`, `getCount`) работают поверх `readAll`/`writeAll` и гарантируют корректную работу с `id`.
- `getKthNShortList(k, n)` возвращает страницу из `TeacherInfo.brief`, отсортированную по фамилии, имени и id; выбрасывает `ArgumentError` при некорректных параметрах.
- `sortByLastName({bool persist = false})` выдаёт отсортированную копию списка и, при необходимости, возвращает результат в хранилище.

## Реализации репозиториев

### TeacherRepJson (`lib/infrastructure/file/teacher_rep_json.dart`)

- Работает с путём до файла; при отсутствии или пустом файле возвращает пустой список.
- `readAll()` требует, чтобы корень JSON был списком, и прогоняет каждый элемент через `Teacher.from`, поэтому поддерживаются `Map`, JSON-строки и CSV-строки.
- `writeAll()` кодирует `List<Teacher>` в массив объектов `toJson()`, создаёт директории и сохраняет файл атомарно.

### TeacherRepYaml (`lib/infrastructure/file/teacher_rep_yaml.dart`)

- Поддерживает два формата корня: список или `{teachers: [...]}`; YAML AST приводится к обычным Dart-типам при помощи `_toDart`.
- `readAll()` также использует `Teacher.from`, поэтому YAML может содержать mix из Map/строк.
- `writeAll()` сериализует данные через `json2yaml` (стиль `YamlStyle.pubspecYaml`), всегда пишет структуру `teachers: [...]`.

### TeacherRepDb (`lib/infrastructure/db/teacher_rep_db.dart`)

- Конструируется из `PostgreSQLConnection`, поле `path` всегда `'db:postgres'`.
- `readAll()` и `writeAll()` сознательно не поддерживаются (выбрасывают `UnsupportedError`) — хранилище работает точечно.
- Реализованы операции `getById`, `getKthNShortList`, `add`, `replaceById` (включая вспомогательный `replaceByIdReturning`), `deleteById`, `getCount`, все запросы параметризованы и сортируют по `lower(last_name), lower(first_name), id`.

## Форматы хранения

### JSON

Корневой элемент — массив объектов со snake_case-ключами. `Teacher.fromJson` понимает camelCase, поэтому внешние клиенты могут отдавать оба варианта.

```json
[
  {
    "id": 1,
    "last_name": "Ivanov",
    "first_name": "Ivan",
    "middle_name": null,
    "phone": "+79990001122",
    "experience_years": 10
  }
]
```

### YAML

Допустимы как чистый список, так и объект с полем `teachers`. Репозиторий записывает второй вариант.

```yaml
teachers:
  - id: 1
    last_name: Ivanov
    first_name: Ivan
    middle_name: null
    phone: "+79990001122"
    experience_years: 10
```

## Пример использования

```dart
import 'package:information_systems_design/domain/teacher_lib.dart';

Future<void> main() async {
  final repo = TeacherRepYaml('data/teachers.yaml');

  await repo.writeAll([
    Teacher.create(
      lastName: 'Ivanov',
      firstName: 'Ivan',
      phone: '+79990001122',
      experienceYears: 7,
    ),
    Teacher.create(
      lastName: 'Petrova',
      firstName: 'Anna',
      middleName: 'Igorevna',
      phone: '+79990001123',
      experienceYears: 5,
    ),
  ]);

  final teachers = await repo.readAll();
  final created = await repo.add(Teacher.create(
    lastName: 'Sidorov',
    firstName: 'Petr',
    phone: '+79990001124',
    experienceYears: 3,
  ));

  await repo.replaceById(
    created.id!,
    Teacher.create(
      lastName: 'Sidorov',
      firstName: 'Pavel',
      phone: created.phone,
      experienceYears: created.experienceYears + 1,
    ),
  );

  final page = await repo.getKthNShortList(k: 2, n: 1);
  await repo.sortByLastName(persist: true);

  // Для работы с БД:
  // final conn = PostgreSQLConnection(host, port, database, username: user, password: pass);
  // await conn.open();
  // final dbRepo = TeacherRepDb(conn);
  // final total = await dbRepo.getCount();
}
```

## Тесты

- `test/teacher_info_test.dart` — проверка нормализации/валидации `TeacherInfo`.
- `test/teacher_parsing_test.dart`, `test/teacher_output_test.dart`, `test/teacher_smoke_test.dart` — покрытие фабрик `Teacher.from*`, `toJson`, `toShortString`.
- `test/teacher_rep_json_test.dart` и `test/teacher_rep_yaml_test.dart` — контракт файловых репозиториев (CRUD, сортировка, пагинация, форматирование).
- `test/db_test.dart` — интеграционные сценарии для `TeacherRepDb` (требует запущенного PostgreSQL).
