/// Доменная модель преподавателя.
/// Шаг 3: инкапсуляция всех полей, приватный базовый конструктор, геттеры.
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

}
