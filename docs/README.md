# Domain Module (lib/domain)

## Обзор

- Назначение: модель предметной области и простой JSON‑репозиторий.
- Состав: `TeacherInfo` (базовая сущность), `Teacher` (расширение с опытом), `TeacherRepJson` (чтение/запись списка в файл).
- Точка входа: `lib/domain/teacher_lib.dart` — объявляет библиотеку и подключает части.

## Классы

- `TeacherInfo` — базовые поля: `id`, `lastName`, `firstName`, `middleName`, `phone`.
  - Валидация: `validateNameField`, `isValidPhone`, `require`.
  - Утилиты: `toShortString()`, `==/hashCode`.
- `Teacher` — наследник `TeacherInfo` с `experienceYears`.
  - Создание: `Teacher.create(...)`, `Teacher.withId(...)`.
  - Нормализация/валидация входа в фабриках.
  - Парсинг: `Teacher.from(...)` — принимает `Teacher`, `String` (строка или JSON), `Map`, `List/Iterable`, записи (records).
  - Парсинг из строки: `Teacher.fromString(line, separator: ';')`.
  - Парсинг из JSON‑объекта: `Teacher.fromJson(Map<String, dynamic>)` (понимает camelCase и snake_case ключи).
- `TeacherRepJson` — репозиторий для списка преподавателей в JSON‑файле.
  - `readAll()` — читает `List<Teacher>`; пустой/отсутствующий файл → `[]`; корень JSON должен быть массивом.
  - `writeAll(List<Teacher>)` — записывает список как JSON.

## Формат JSON

Корень — массив объектов. Пример:

```json
[
  {
    "id": 1,
    "lastName": "Ivanov",
    "firstName": "Ivan",
    "middleName": null,
    "phone": "+79990001122",
    "experienceYears": 10
  }
]
```

Ключи на запись — camelCase. На чтение поддерживаются как camelCase, так и snake_case (см. `Teacher.fromJson`).

## Использование

```dart
import 'package:information_systems_design/domain/teacher_lib.dart';

Future<void> example() async {
  final repo = TeacherRepJson('data/teachers.json');

  final items = <Teacher>[
    Teacher.withId(
      id: 1,
      lastName: 'Ivanov',
      firstName: 'Ivan',
      middleName: null,
      phone: '+79990001122',
      experienceYears: 10,
    ),
  ];

  await repo.writeAll(items);
  final loaded = await repo.readAll();
  print(loaded.first.toShortString());
}
```

## Структура файлов

- `lib/domain/teacher_lib.dart` — объявление библиотеки и импорты.
- `lib/domain/teacher_info.dart` — базовый класс и валидации.
- `lib/domain/teacher.dart` — расширение модели и фабрики парсинга.
- `lib/domain/teacher_rep_json.dart` — JSON‑репозиторий.
- Тесты: `test/teacher_*.dart`.

## Дизайн‑заметки

- Конструкторы/фабрики не наследуются, поэтому `fromJson` — в конкретном классе (`Teacher`).
- Общая сериализация `toJson()` уместна в базовом типе (`TeacherInfo`), а `Teacher` может её дополнять.
- При росте проекта можно ввести интерфейс репозитория (`TeacherRepository`) и вынести реализацию JSON в слой данных.
