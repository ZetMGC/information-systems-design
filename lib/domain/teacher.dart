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

  static void validateAll({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    if (!isValidName(lastName)) {
      throw ArgumentError('Некорректная фамилия');
    }
    if (!isValidName(firstName)) {
      throw ArgumentError('Некорректное имя');
    }
    if (middleName != null && middleName.isNotEmpty && !isValidName(middleName)) {
      throw ArgumentError('Некорректное отчество');
    }
    if (!isValidPhone(phone)) {
      throw ArgumentError('Некорректный телефон (ожидается +XXXXXXXXXXX, 10–15 цифр)');
    }
    if (!isValidExperience(experienceYears)) {
      throw ArgumentError('Некорректный стаж (0..80 лет)');
    }
  }

  // --- factory ---
  /// Фабрика создания преподавателя с валидацией.
  factory Teacher.create({
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
    required int experienceYears,
  }) {
    validateAll(
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      phone: phone,
      experienceYears: experienceYears,
    );

    return Teacher._(
      id: null,
      lastName: lastName.trim(),
      firstName: firstName.trim(),
      middleName: middleName?.trim(),
      phone: phone.trim(),
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

    validateAll(
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      phone: phone,
      experienceYears: experienceYears,
    );

    return Teacher._(
      id: id,
      lastName: lastName.trim(),
      firstName: firstName.trim(),
      middleName: (middleName == null || middleName.trim().isEmpty) ? null : middleName.trim(),
      phone: phone.trim(),
      experienceYears: experienceYears,
    );
  }
}
