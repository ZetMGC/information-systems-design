import 'package:test/test.dart';
import 'package:information_systems_design/domain/teacher.dart';

void main() {
  test('Teacher.create — телефон валидный', () {
    final t = Teacher.create(
      lastName: 'Иванов',
      firstName: 'Иван',
      phone: '+79990001122',
      experienceYears: 12,
    );
    expect(t.id, isNull);
  });

  test('Teacher.create — неверный телефон', () {
    expect(
      () => Teacher.create(
        lastName: 'Петров',
        firstName: 'Пётр',
        phone: '12345',
        experienceYears: 5,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
