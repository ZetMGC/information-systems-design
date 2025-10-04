part of teacher_lib;

/// Доменная модель преподавателя. </br>
class Teacher extends TeacherInfo {
  // --- private fields ---
  final int _experienceYears;
  
  // --- base constructor ---
  const Teacher._({
    required int? id,
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  })  : _experienceYears = experienceYears,
        super._(
          id: id,
          lastName: lastName,
          firstName: firstName,
          middleName: middleName,
          phone: phone,
        );

  // --- getter ---
  int get experienceYears => _experienceYears;

  static bool isValidExperience(int years) => years >= 0 && years <= 80;

  /// Валидирует все поля преподавателя.
  static void validateAll({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    TeacherInfo.validateNameField(lastName, 'Фамилия');
    TeacherInfo.validateNameField(firstName, 'Имя');
    TeacherInfo.validateNameField(middleName, 'Отчество', optional: true);
    TeacherInfo.require(TeacherInfo.isValidPhone(phone), 'Некорректный телефон');
    TeacherInfo.require(isValidExperience(experienceYears), 'Некорректный стаж');
  }

  // --- factory ---
  /// Универсальная фабрика: принимает разные источники и создаёт Teacher.
  /// Поддержка: Teacher | String (JSON или "a;b;c;...") | Map | List/Iterable | Record с именованными полями.
  /// [separator] — разделитель для строкового формата без JSON.
  factory Teacher.from(
    Object source, {
    String separator = ';',
  }) {
    switch (source) {
      case Teacher t:
        return t;

      case String s: {
        final t = s.trim();
        if (t.isEmpty) {
          throw FormatException('Пустая строка не поддерживается');
        }

        if ((t.startsWith('{') && t.endsWith('}')) ||
            (t.startsWith('[') && t.endsWith(']'))) {
          final decoded = jsonDecode(t);
          return Teacher.from(decoded); 
        }
        return Teacher.fromString(t, separator: separator);
      }

      case Map<String, dynamic> m:
        return Teacher.fromJson(m);

      case Map otherMap: {
        final m = <String, dynamic>{};
        for (final e in otherMap.entries) {
          final key = e.key.toString();
          m[key] = e.value;
        }
        return Teacher.fromJson(m);
      }

      case List l:
        return _fromList(l);

      case Iterable it:
        return _fromList(it.toList());

      case ({
        int id,
        String lastName,
        String firstName,
        String? middleName,
        String phone,
        int experienceYears,
      }) recWithId:
        return Teacher.withId(
          id: recWithId.id,
          lastName: recWithId.lastName,
          firstName: recWithId.firstName,
          middleName: recWithId.middleName,
          phone: recWithId.phone,
          experienceYears: recWithId.experienceYears,
        );

      case ({
        String lastName,
        String firstName,
        String? middleName,
        String phone,
        int experienceYears,
      }) recNoId:
        return Teacher.create(
          lastName: recNoId.lastName,
          firstName: recNoId.firstName,
          middleName: recNoId.middleName,
          phone: recNoId.phone,
          experienceYears: recNoId.experienceYears,
        );

      default:
        throw ArgumentError('неизвестный тип source: ${source.runtimeType}');
    }
  }

  /// Фабрика создания преподавателя с валидацией.
  factory Teacher.create({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    final ln = TeacherInfo.norm(lastName);
    final fn = TeacherInfo.norm(firstName);
    final mn = TeacherInfo.normOpt(middleName);
    final ph = TeacherInfo.norm(phone);

    validateAll(
      lastName: ln,
      firstName: fn,
      middleName: mn,
      phone: ph,
      experienceYears: experienceYears,
    );

    return Teacher._(
      id: null,
      lastName: ln,
      firstName: fn,
      middleName: mn,
      phone: ph,
      experienceYears: experienceYears,
    );
  }

  /// Фабрика создания преподавателя с валидацией и указанием id (может быть из БД).
  factory Teacher.withId({
    required int id,
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    if (id <= 0) {
      throw ArgumentError('id должен быть положительным');
    }

    final t = Teacher.create(
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      phone: phone,
      experienceYears: experienceYears,
    );
    return t.copyWithId(id);
  }

  Teacher copyWithId(int id) {
    if (id <= 0) throw ArgumentError('id должен быть положительным');
    return Teacher._(
      id: id,
      lastName: _lastName,
      firstName: _firstName,
      middleName: _middleName,
      phone: _phone,
      experienceYears: _experienceYears,
    );
  }

  /// Создаёт экземпляр из строки [line], разделённой [separator].
  /// Ожидается 5 полей (без id) или 6 полей.
  factory Teacher.fromString(
    String line, {
    String separator = ';',
  }) {
    final parts = line.split(separator).map((e) => e.trim()).toList();
    if (parts.length == 5) {
      final lastName = parts[0];
      final firstName = parts[1];
      final middleName = parts[2].isEmpty ? null : parts[2];
      final phone = parts[3];
      final experienceYears = int.tryParse(parts[4]);
      if (experienceYears == null) {
        throw FormatException('Некорректный стаж: ${parts[4]}');
      }
      return Teacher.create(
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        phone: phone,
        experienceYears: experienceYears,
      );
    } else if (parts.length == 6) {
      final id = int.tryParse(parts[0]);
      if (id == null || id <= 0) {
        throw FormatException('Некорректный id: ${parts[0]}');
      }
      final lastName = parts[1];
      final firstName = parts[2];
      final middleName = parts[3].isEmpty ? null : parts[3];
      final phone = parts[4];
      final experienceYears = int.tryParse(parts[5]);
      if (experienceYears == null) {
        throw FormatException('Некорректный стаж: ${parts[5]}');
      }
      return Teacher.withId(
        id: id,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        phone: phone,
        experienceYears: experienceYears,
      );
    } else {
      throw FormatException('Неверное количество полей: ${parts.length}, ожидалось 5 или 6');
    }
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    T? _read<T>(List<String> keys, {T? defaultValue, bool required = false}) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final v = json[k];
          if (v is T) return v;
          if (T == int && v is String) {
            final parsed = int.tryParse(v);
            if (parsed != null) return parsed as T;
          }
        }
      }
      if (required) {
        throw FormatException('Отсутствует обязательное поле: ${keys.join("|")}');
      }
      return defaultValue;
    }

    final int? id = _read<int>(['id', 'teacherId']);
    final String lastName = _read<String>(['lastName', 'last_name'], required: true)!;
    final String firstName = _read<String>(['firstName', 'first_name'], required: true)!;
    final String? middleName = _read<String?>(['middleName', 'middle_name'], defaultValue: null);
    final String phone = _read<String>(['phone', 'phoneNumber', 'phone_number'], required: true)!;
    final int experienceYears = _read<int>(['experienceYears', 'experience_years'], required: true)!;

    return (id == null)
        ? Teacher.create(
            lastName: lastName,
            firstName: firstName,
            middleName: middleName,
            phone: phone,
            experienceYears: experienceYears,
          )
        : Teacher.withId(
            id: id,
            lastName: lastName,
            firstName: firstName,
            middleName: middleName,
            phone: phone,
            experienceYears: experienceYears,
          );
  }
  
  static Teacher _fromList(List list) {
    if (list.length == 5) {
      final ln = list[0]?.toString() ?? '';
      final fn = list[1]?.toString() ?? '';
      final mnRaw = list[2];
      final phone = list[3]?.toString() ?? '';
      final exp = (list[4] is int) ? list[4] as int : int.tryParse(list[4].toString());
      if (exp == null) {
        throw FormatException('Стаж должен быть числом: ${list[4]}');
      }
      final mn = (mnRaw == null) ? null : (mnRaw.toString().trim().isEmpty ? null : mnRaw.toString());
      return Teacher.create(
        lastName: ln,
        firstName: fn,
        middleName: mn,
        phone: phone,
        experienceYears: exp,
      );
    } else if (list.length == 6) {
      final id = (list[0] is int) ? list[0] as int : int.tryParse(list[0].toString());
      if (id == null || id <= 0) {
        throw FormatException('Некорректный id: ${list[0]}');
      }
      final ln = list[1]?.toString() ?? '';
      final fn = list[2]?.toString() ?? '';
      final mnRaw = list[3];
      final phone = list[4]?.toString() ?? '';
      final exp = (list[5] is int) ? list[5] as int : int.tryParse(list[5].toString());
      if (exp == null) {
        throw FormatException('Стаж должен быть числом: ${list[5]}');
      }
      final mn = (mnRaw == null) ? null : (mnRaw.toString().trim().isEmpty ? null : mnRaw.toString());
      return Teacher.withId(
        id: id,
        lastName: ln,
        firstName: fn,
        middleName: mn,
        phone: phone,
        experienceYears: exp,
      );
    } else {
      throw FormatException('Ожидалось 5 или 6 элементов, получено: ${list.length}');
    }
  }

  // --- Вывод ---
  /// Текстовое представление класса.
  @override
  String toString() => 'Teacher(${toShortString()}, experienceYears: $_experienceYears)';

  /// Перегрузка оператора равенства для сравнения объектов.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Teacher &&
          super == other &&
          other._experienceYears == _experienceYears;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _experienceYears);
}
