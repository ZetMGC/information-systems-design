import 'dart:convert';
import 'dart:io';

import 'package:information_systems_design/domain/teacher_lib.dart';
import 'package:test/test.dart';

void main() {
  group('TeacherRepJson', () {
    late Directory tmp;
    late String path;
    late TeacherRepJson repo;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('teacher_repo_');
      path = '${tmp.path}${Platform.pathSeparator}teachers.json';
      repo = TeacherRepJson(path);
    });

    tearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    /// Утилита: перезаписывает файл «сырым» JSON (корень — массив).
    Future<void> writeRaw(List<dynamic> rows) async {
      final f = File(path);
      await f.parent.create(recursive: true);
      await f.writeAsString(jsonEncode(rows), flush: true);
    }

    /// Фикстура: «полный» объект Teacher в Map-формате (как after toJson()).
    Map<String, dynamic> t(
      int id,
      String ln,
      String fn, {
      String? mn,
      String phone = '+79990000000',
      int exp = 1,
    }) {
      return {
        'id': id,
        'last_name': ln,
        'first_name': fn,
        if (mn != null) 'middle_name': mn,
        'phone': phone,
        'experience_years': exp,
      };
    }

    test('(a) readAll: no file -> [], empty file -> []', () async {
      final all = await repo.readAll();
      expect(all, isEmpty);

      await File(path).parent.create(recursive: true);
      await File(path).writeAsString('', flush: true);
      final all2 = await repo.readAll();
      expect(all2, isEmpty);
    });

    test('(a) readAll: wrong root -> FormatException', () async {
      await File(path).parent.create(recursive: true);
      await File(path).writeAsString('{"not":"a list"}', flush: true);
      expect(repo.readAll, throwsFormatException);
    });

    test('(a/b) readAll <-> writeAll round-trip', () async {
      final rows = [
        t(1, 'Петров', 'Пётр', mn: 'Сергеевич', phone: '+79990001122', exp: 7)
      ];
      await writeRaw(rows);

      final list = await repo.readAll();
      expect(list.length, 1);
      expect(list.first.id, 1);
      expect(list.first.lastName, 'Петров');
      expect(list.first.firstName, 'Пётр');
      expect(list.first.middleName, 'Сергеевич');
      expect(list.first.phone, '+79990001122');
      expect(list.first.experienceYears, 7);

      await repo.writeAll(list);
      final list2 = await repo.readAll();
      expect(list2.length, 1);
      expect(list2.first.toJson(), rows.first);
    });

    test('(a) readAll: uses Teacher.from for mixed item formats', () async {
      final mapWithStrings = {
        'id': '10',
        'last_name': 'A',
        'first_name': 'a',
        'phone': '+79933295462',
        'experience_years': '3',
      };

      final jsonStringItem = jsonEncode({
        'id': 11,
        'last_name': 'B',
        'first_name': 'b',
        'phone': '+79933295462',
        'experience_years': 2,
      });

      final csvString = 'Ivanov;Ivan;;+79990000003;5';

      await writeRaw([mapWithStrings, jsonStringItem, csvString]);

      final list = await repo.readAll();
      expect(list.length, 3);

      expect(list[0].id, 10);
      expect(list[0].lastName, 'A');
      expect(list[0].firstName, 'a');
      expect(list[0].experienceYears, 3);

      expect(list[1].id, 11);
      expect(list[1].lastName, 'B');
      expect(list[1].firstName, 'b');
      expect(list[1].experienceYears, 2);

      expect(list[2].id, isNull);
      expect(list[2].lastName, 'Ivanov');
      expect(list[2].firstName, 'Ivan');
      expect(list[2].experienceYears, 5);
    });

    test('(c) getById: found / not found / bad id', () async {
      await writeRaw([t(1, 'A', 'a'), t(2, 'B', 'b')]);

      expect(await repo.getById(2), isNotNull);
      expect((await repo.getById(2))!.lastName, 'B');

      expect(await repo.getById(3), isNull);

      expect(() => repo.getById(0), throwsArgumentError);
      expect(() => repo.getById(-1), throwsArgumentError);
    });

    test('(d) getKthNShortList: pagination + sort by lastName (ASC)', () async {
      await writeRaw([
        t(3, 'Иванов', 'Иван', mn: 'Иваныч'),
        t(1, 'Петров', 'Пётр'),
        t(2, 'Альтов', 'Антон'),
      ]);
      final p1 = await repo.getKthNShortList(k: 2, n: 1);
      expect(p1.length, 2);
      expect(p1[0].lastName, 'Альтов');
      expect(p1[1].lastName, 'Иванов');
      expect(p1[1].middleName, 'Иваныч');

      final p2 = await repo.getKthNShortList(k: 2, n: 2);
      expect(p2.length, 1);
      expect(p2[0].lastName, 'Петров');

      final p3 = await repo.getKthNShortList(k: 2, n: 3);
      expect(p3, isEmpty);

      expect(() => repo.getKthNShortList(k: 0, n: 1), throwsArgumentError);
      expect(() => repo.getKthNShortList(k: 1, n: 0), throwsArgumentError);
    });

    test('(e) sortByLastName: returns sorted copy; persist=true writes file',
        () async {
      await writeRaw([
        t(3, 'Иванов', 'Иван'),
        t(1, 'Петров', 'Пётр'),
        t(2, 'Альтов', 'Антон'),
      ]);

      final sorted = await repo.sortByLastName();
      expect(sorted.map((e) => e.lastName).toList(),
          ['Альтов', 'Иванов', 'Петров']);

      final beforePersist = await repo.readAll();
      await repo.sortByLastName(persist: true);
      final afterPersist = await repo.readAll();
      expect(afterPersist.map((e) => e.lastName).toList(),
          ['Альтов', 'Иванов', 'Петров']);

      expect(afterPersist.length, beforePersist.length);
    });

    test('(f) add: assigns new id and saves', () async {
      // maxId = 5
      await writeRaw([t(2, 'B', 'b'), t(5, 'E', 'e')]);

      final created = await repo.add(Teacher.create(
        lastName: 'A',
        firstName: 'a',
        phone: '+79990001122',
        experienceYears: 3,
      ));
      expect(created.id, 6);

      final all = await repo.readAll();
      expect(all.any((x) => x.id == 6), isTrue);

      expect(
        () => repo.add(Teacher.withId(
          id: 100,
          lastName: 'X',
          firstName: 'x',
          phone: '+7999',
          experienceYears: 1,
        )),
        throwsArgumentError,
      );
    });

    test('(g) replaceById: true when replaced; false when id not found',
        () async {
      await writeRaw(
          [t(1, 'Old', 'Name', mn: 'M', phone: '+70001112233', exp: 1)]);

      final ok = await repo.replaceById(
        1,
        Teacher.create(
          lastName: 'New',
          firstName: 'John',
          middleName: 'Q',
          phone: '+71112223344',
          experienceYears: 9,
        ),
      );
      expect(ok, isTrue);

      final after = await repo.readAll();
      expect(after.length, 1);
      expect(after.first.lastName, 'New');
      expect(after.first.firstName, 'John');
      expect(after.first.middleName, 'Q');
      expect(after.first.phone, '+71112223344');
      expect(after.first.experienceYears, 9);
      expect(after.first.id, 1);

      final miss = await repo.replaceById(
        99,
        Teacher.create(
          lastName: 'Z',
          firstName: 'z',
          phone: '+70001112233',
          experienceYears: 1,
        ),
      );
      expect(miss, isFalse);
    });

    test('(h) deleteById: true when deleted; false when absent', () async {
      await writeRaw([t(1, 'A', 'a'), t(2, 'B', 'b')]);

      final ok = await repo.deleteById(1);
      expect(ok, isTrue);

      final all = await repo.readAll();
      expect(all.length, 1);
      expect(all.first.id, 2);

      final miss = await repo.deleteById(42);
      expect(miss, isFalse);

      expect(() => repo.deleteById(0), throwsArgumentError);
      expect(() => repo.deleteById(-10), throwsArgumentError);
    });

    test('(i) getCount', () async {
      await writeRaw([t(1, 'A', 'a'), t(2, 'B', 'b'), t(3, 'C', 'c')]);
      expect(await repo.getCount(), 3);

      await writeRaw([]);
      expect(await repo.getCount(), 0);
    });
  });
}
