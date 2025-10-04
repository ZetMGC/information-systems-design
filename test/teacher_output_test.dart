import 'package:test/test.dart';
import 'package:information_systems_design/domain/teacher.dart';

void main() {
  test('toString полное представление', () {
    final t = Teacher.from((
        id: 1,
        lastName: 'Иванов',
        firstName: 'Иван',
        middleName: 'Иванович',
        phone: '+79990001122',
        experienceYears: 10,
      )
    );
    expect(t.toString(), contains('Teacher('));
    expect(t.toString(), contains('Иванов'));
  });

  test('toShortString краткое представление', () {
    final t = Teacher.from((
        lastName: 'Петров',
        firstName: 'Пётр',
        middleName: 'Сергеевич',
        phone: '+79993334455',
        experienceYears: 7,
      )
    );
    expect(t.toShortString(), 'Петров П.С. (7 лет стаж)');
  });

  test('сравнение объектов == и hashCode', () {
    final a = Teacher.from(
      (lastName: 'Сидоров',
      firstName: 'Сидор',
      middleName: 'Сидорович',
      phone: '+79995556677',
      experienceYears: 5,)
    );
    final b = Teacher.from(
      (lastName: 'Сидоров',
      firstName: 'Сидор',
      middleName: 'Сидорович',
      phone: '+79995556677',
      experienceYears: 5,)
    );
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });
}
