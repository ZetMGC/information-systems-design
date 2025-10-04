import 'package:test/test.dart';
import 'package:information_systems_design/domain/teacher_lib.dart';

void main() {
  group('TeacherInfo.brief', () {
    test('валидные данные: создаётся, нормализует и формирует краткий вывод', () {
      final info = TeacherInfo.brief(
        id: 7,
        lastName: '  Орлов  ',
        firstName: '  Олег ',
        middleName: ' Олегович ',
        phone: ' +4917612345678 ',
      );

      expect(info.id, 7);
      expect(info.lastName, 'Орлов');
      expect(info.firstName, 'Олег');
      expect(info.middleName, 'Олегович');
      expect(info.phone, '+4917612345678');

      expect(info.toShortString(), 'Орлов О.О., +4917612345678');

      expect(info.toString(), contains('TeacherInfo('));
      expect(info.toString(), contains('Орлов'));
    });

    test('невалидный телефон -> ArgumentError', () {
      expect(
        () => TeacherInfo.brief(
          lastName: 'Иванов',
          firstName: 'Иван',
          middleName: null,
          phone: '12345', 
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('пустое отчество допустимо (optional), в инициал не попадает', () {
      final info = TeacherInfo.brief(
        lastName: 'Петров',
        firstName: 'Пётр',
        middleName: '',
        phone: '+79993334455',
      );
      expect(info.middleName, isNull);
      expect(info.toShortString(), 'Петров П., +79993334455');
    });
  });

  group('Сравнение и hash TeacherInfo', () {
    test('равные по полям экземпляры равны и имеют одинаковый hash', () {
      final a = TeacherInfo.brief(
        id: 1,
        lastName: 'Сидоров',
        firstName: 'Сидор',
        middleName: 'Сидорович',
        phone: '+79995556677',
      );
      final b = TeacherInfo.brief(
        id: 1,
        lastName: 'Сидоров',
        firstName: 'Сидор',
        middleName: 'Сидорович',
        phone: '+79995556677',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final set = {a, b};
      expect(set.length, 1);
    });
  });

  group('Совместимость с Teacher (наследование)', () {
    test('Teacher — это TeacherInfo, short-строка одинаковая', () {
      final t = Teacher.create(
        lastName: 'Кузнецов',
        firstName: 'Кузьма',
        middleName: null,
        phone: '+77071112233',
        experienceYears: 10,
      );

      expect(t is TeacherInfo, isTrue);

      expect(t.toShortString(), 'Кузнецов К., +77071112233');

      final TeacherInfo baseRef = t;
      expect(baseRef.toShortString(), 'Кузнецов К., +77071112233');
    });
  });
}
