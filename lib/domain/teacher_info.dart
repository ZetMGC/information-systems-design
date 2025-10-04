class TeacherInfo {
  // ---- краткие поля ----
  final int? _id;                
  final String _lastName;
  final String _firstName;
  final String? _middleName;      
  final String _phone;

  // ---- базовый конструктор ----
  const TeacherInfo._({
    required int? id,
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
  })  : _id = id,
        _lastName = lastName,
        _firstName = firstName,
        _middleName = middleName,
        _phone = phone;

  // ---- геттеры ----
  int? get id => _id;
  String get lastName => _lastName;
  String get firstName => _firstName;
  String? get middleName => _middleName;
  String get phone => _phone;

  // ---- публичные утилиты ----
  static final RegExp nameRe  = RegExp(r"^[A-Za-zА-Яа-яЁё\-'\s]{1,100}$");
  static final RegExp phoneRe = RegExp(r'^\+?[0-9]{10,15}$');

  static String norm(String s) => s.trim();
  static String? normOpt(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  static bool isValidName(String s)   => s.trim().isNotEmpty && nameRe.hasMatch(s.trim());
  static bool isValidPhone(String s)  => phoneRe.hasMatch(s.trim());

  static void require(bool cond, String message) {
    if (!cond) throw ArgumentError(message);
  }

  static void validateNameField(String? value, String label, {bool optional = false}) {
    if (optional && (value == null || value.isEmpty)) return;
    require(value != null && isValidName(value), 'Некорректное поле: $label');
  }

  // ---- краткий вывод ----
  String toShortString() {
    final f = _firstName.isNotEmpty ? '${_firstName[0]}.' : '';
    final m = (_middleName != null && _middleName!.isNotEmpty) ? '${_middleName![0]}.' : '';
    return '$_lastName $f$m, $_phone';
  }

  // ---- равенство/хэш по кратким полям ----
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeacherInfo &&
        other._id == _id &&
        other._lastName == _lastName &&
        other._firstName == _firstName &&
        other._middleName == _middleName &&
        other._phone == _phone;
  }

  @override
  int get hashCode => Object.hash(_id, _lastName, _firstName, _middleName, _phone);

  // ---- фабричные конструкторы ----
  factory TeacherInfo.brief({
    int? id,
    required String lastName,
    required String firstName,
    String? middleName,
    required String phone,
  }) {
    final ln = norm(lastName);
    final fn = norm(firstName);
    final mn = normOpt(middleName);
    final ph = norm(phone);

    validateNameField(ln, 'фамилия');
    validateNameField(fn, 'имя');
    validateNameField(mn, 'отчество', optional: true);
    require(isValidPhone(ph), 'некорректный телефон (+ и 10–15 цифр)');

    return TeacherInfo._(
      id: id,
      lastName: ln,
      firstName: fn,
      middleName: mn,
      phone: ph,
    );
  }

  @override
  String toString() => 'TeacherInfo(id=$_id, ${toShortString()})';
}
