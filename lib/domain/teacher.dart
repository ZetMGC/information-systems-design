/// Доменная модель преподавателя. </br>
class Teacher {
  // --- private fields ---
  final int? _id;                 
  final String _lastName;
  final String _firstName;
  final String? _middleName;      
  final String _phone;
  final int _experienceYears;

  // --- base constructor ---
  const Teacher._({
    required int? id,
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  })  : _id = id,
        _lastName = lastName,
        _firstName = firstName,
        _middleName = middleName,
        _phone = phone,
        _experienceYears = experienceYears;

  // --- getter ---
  int? get id => _id;
  String get lastName => _lastName;
  String get firstName => _firstName;
  String? get middleName => _middleName;
  String get phone => _phone;
  int get experienceYears => _experienceYears;

  // --- Static validation ---
  static final RegExp _nameRe = RegExp(r"^[A-Za-zА-Яа-яЁё\-'\s]{1,100}$");
  static final RegExp _phoneRe = RegExp(r'^\+?[0-9]{10,15}$');

  static bool isValidName(String s) => s.trim().isNotEmpty && _nameRe.hasMatch(s.trim());
  static bool isValidPhone(String s) => _phoneRe.hasMatch(s.trim());
  static bool isValidExperience(int years) => years >= 0 && years <= 80;

  /// Проверяет условие [cond], если не выполняется, кидает [ArgumentError] с сообщением [message].
  static void _require(bool cond, String message) {
    if (!cond) throw ArgumentError(message);
  }

  /// Валидирует поле имени [value] с меткой [label]. Если [optional] и значение пустое, не валидирует.
  static void _validateNameField(String? value, String label, {bool optional = false}) {
    if (optional && (value == null || value.isEmpty)) return;
    _require(value != null && isValidName(value), 'Некорректное значение поля $label');
  }

  /// Валидирует все поля преподавателя.
  static void validateAll({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    _validateNameField(lastName, 'Фамилия');
    _validateNameField(firstName, 'Имя');
    _validateNameField(middleName, 'Отчество', optional: true);
    _require(isValidPhone(phone), 'Некорректный телефон');
    _require(isValidExperience(experienceYears), 'Некорректный стаж');
  }

  // --- нормализаця ввода ---
  static String _norm(String s) => s.trim();
  static String? _normOpt(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

  // --- factory ---
  /// Фабрика создания преподавателя с валидацией.
  factory Teacher.create({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    final ln = _norm(lastName);
    final fn = _norm(firstName);
    final mn = _normOpt(middleName);
    final ph = _norm(phone);

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
}
