import 'package:test/test.dart';
import 'package:information_systems_design/domain/teacher.dart';

void main() {
  group('Teacher.fromString', () {
    test('без id: парсится корректно, id == null', () {
      final t = Teacher.from('Иванов;Иван;;+79990001122;12');
      expect(t.id, isNull);
      expect(t.lastName, 'Иванов');
      expect(t.firstName, 'Иван');
      expect(t.middleName, isNull);
      expect(t.phone, '+79990001122');
      expect(t.experienceYears, 12);
    });

    test('c id: парсится корректно, id > 0', () {
      final t = Teacher.from('42;Петров;Пётр;Сергеевич;+4917612345678;7');
      expect(t.id, 42);
      expect(t.lastName, 'Петров');
      expect(t.firstName, 'Пётр');
      expect(t.middleName, 'Сергеевич');
      expect(t.experienceYears, 7);
    });

    test('неверный стаж (не число) -> FormatException', () {
      expect(
        () => Teacher.from('Иванов;Иван;;+79990001122;двенадцать'),
        throwsA(isA<FormatException>()),
      );
    });

    test('неверный телефон -> ArgumentError из валидации', () {
      expect(
        () => Teacher.from('Иванов;Иван;;12345;12'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Teacher.fromJson', () {
    test('camelCase без id', () {
      final t = Teacher.from({
        'lastName': 'Сидоров',
        'firstName': 'Сидор',
        'middleName': null,
        'phone': '+380501112233',
        'experienceYears': 5,
      });
      expect(t.id, isNull);
      expect(t.lastName, 'Сидоров');
      expect(t.firstName, 'Сидор');
      expect(t.middleName, isNull);
      expect(t.experienceYears, 5);
    });

    test('snake_case с id', () {
      final t = Teacher.from({
        'id': 99,
        'last_name': 'Кузнецов',
        'first_name': 'Кузьма',
        'middle_name': '',
        'phone': '+77071112233',
        'experience_years': 10,
      });
      expect(t.id, 99);
      expect(t.lastName, 'Кузнецов');
      expect(t.firstName, 'Кузьма');
      expect(t.middleName, isNull);
      expect(t.phone, '+77071112233');
      expect(t.experienceYears, 10);
    });

    test('отсутствует обязательное поле -> FormatException', () {
      expect(
        () => Teacher.from({
          // 'lastName' отсутствует
          'firstName': 'Иван',
          'phone': '+79990001122',
          'experienceYears': 1,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('невалидный телефон -> ArgumentError из валидации', () {
      expect(
        () => Teacher.from({
          'lastName': 'Лебедев',
          'firstName': 'Лев',
          'phone': '12-34',
          'experienceYears': 3,
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
