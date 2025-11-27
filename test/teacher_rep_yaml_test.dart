import 'dart:io';

import 'package:information_systems_design/domain/teacher_lib.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:test/test.dart';

void main() {
  group('TeacherRepYaml', () {
    late Directory tmp;
    late String path;
    late TeacherRepYaml repo;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('teacher_repo_yaml_');
      path = '${tmp.path}${Platform.pathSeparator}teachers.yaml';
      repo = TeacherRepYaml(path);
    });

    tearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    Future<void> writeYaml(String yaml) async {
      final f = File(path);
      await f.parent.create(recursive: true);
      await f.writeAsString(yaml, flush: true);
    }

    /// YAML с корнем-списком (— элементы)
    Future<void> writeYamlList(List<Map<String, dynamic>> rows) =>
        writeYaml(json2yaml(<String, dynamic>{'teachers': rows},
            yamlStyle: YamlStyle.pubspecYaml));

    /// YAML с корнем-объектом: {teachers: [...]}
    Future<void> writeYamlTeachers(List<Map<String, dynamic>> rows) async {
      final yaml = json2yaml(
          <String, dynamic>{'teachers': rows}); // rows == [] → "teachers: []"
      await File(path).parent.create(recursive: true);
      await File(path).writeAsString(yaml, flush: true);
    }

    Map<String, dynamic> row(
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
      // файла нет
      final all = await repo.readAll();
      expect(all, isEmpty);

      await File(path).parent.create(recursive: true);
      await File(path).writeAsString('', flush: true);
      final all2 = await repo.readAll();
      expect(all2, isEmpty);
    });

    test('(a) readAll: wrong root -> FormatException', () async {
      await writeYaml(json2yaml(<String, dynamic>{'not': 'a list'}));
      expect(repo.readAll, throwsFormatException);
    });

    test('(a/b) readAll <-> writeAll round-trip (root=list)', () async {
      final rows = [
        row(1, 'Петров', 'Пётр',
            mn: 'Сергеевич', phone: '+79990001122', exp: 7),
      ];
      await writeYamlList(rows);

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

    test('(a) readAll: supports root={teachers:[...]}', () async {
      final rows = [
        row(2, 'Иванов', 'Иван', phone: '+79990000001', exp: 3),
        row(3, 'Альтов', 'Антон', phone: '+79990000002', exp: 2),
      ];
      await writeYamlTeachers(rows);

      final list = await repo.readAll();
      expect(list.length, 2);
      expect(list.map((e) => e.id).toList(), [2, 3]);
    });

    test('(a) readAll: mixed element formats (Map, JSON-string, CSV-string)',
        () async {
      final m1 = {
        'id': 10,
        'last_name': 'А',
        'first_name': 'а',
        'phone': '+79990000003',
        'experience_years': 3,
      };

      final jsonString =
          '{"id":11,"last_name":"B","first_name":"b","phone":"+79990000004","experience_years":2}';
      final csv = 'Ivanov;Ivan;;+79990000005;5';

      await writeYaml(json2yaml(<String, dynamic>{
        'teachers': [m1, jsonString, csv]
      }, yamlStyle: YamlStyle.pubspecYaml));

      final list = await repo.readAll();
      expect(list.length, 3);

      expect(list[0].id, 10);
      expect(list[0].experienceYears, 3);

      expect(list[1].id, 11);
      expect(list[1].firstName, 'b');

      expect(list[2].id, isNull);
      expect(list[2].lastName, 'Ivanov');
      expect(list[2].experienceYears, 5);
    });

    test('(c) getById', () async {
      await writeYamlList([row(1, 'A', 'a'), row(2, 'B', 'b')]);

      expect(await repo.getById(2), isNotNull);
      expect((await repo.getById(2))!.lastName, 'B');

      expect(await repo.getById(3), isNull);
      expect(() => repo.getById(0), throwsArgumentError);
    });

    test('(d) getKthNShortList: pagination + sort by lastName ASC', () async {
      await writeYamlList([
        row(3, 'Иванов', 'Иван', mn: 'Иваныч'),
        row(1, 'Петров', 'Пётр'),
        row(2, 'Альтов', 'Антон'),
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

    test('(e) sortByLastName: returns sorted copy; persist=true writes YAML',
        () async {
      await writeYamlList([
        row(3, 'Иванов', 'Иван'),
        row(1, 'Петров', 'Пётр'),
        row(2, 'Альтов', 'Антон'),
      ]);

      final sorted = await repo.sortByLastName();
      expect(sorted.map((e) => e.lastName).toList(),
          ['Альтов', 'Иванов', 'Петров']);

      // зафиксируем порядок в файле
      await repo.sortByLastName(persist: true);
      final after = await repo.readAll();
      expect(after.map((e) => e.lastName).toList(),
          ['Альтов', 'Иванов', 'Петров']);
    });

    test('(f) add: assigns new id and saves YAML', () async {
      await writeYamlList([row(2, 'B', 'b'), row(5, 'E', 'e')]);

      final created = await repo.add(Teacher.create(
        lastName: 'A',
        firstName: 'a',
        phone: '+79990000006',
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
          phone: '+79990000007',
          experienceYears: 1,
        )),
        throwsArgumentError,
      );
    });

    test('(g) replaceById: true when replaced; false when id not found',
        () async {
      await writeYamlList(
          [row(1, 'Old', 'Name', mn: 'M', phone: '+70000000000', exp: 1)]);

      final ok = await repo.replaceById(
        1,
        Teacher.create(
          lastName: 'New',
          firstName: 'John',
          middleName: 'Q',
          phone: '+71111111111',
          experienceYears: 9,
        ),
      );
      expect(ok, isTrue);

      final after = await repo.readAll();
      expect(after.length, 1);
      expect(after.first.id, 1);
      expect(after.first.lastName, 'New');
      expect(after.first.firstName, 'John');
      expect(after.first.middleName, 'Q');
      expect(after.first.phone, '+71111111111');
      expect(after.first.experienceYears, 9);

      final miss = await repo.replaceById(
        99,
        Teacher.create(
          lastName: 'Z',
          firstName: 'z',
          phone: '+79990000008',
          experienceYears: 1,
        ),
      );
      expect(miss, isFalse);
    });

    test('(h) deleteById: true when deleted; false when absent', () async {
      await writeYamlList([row(1, 'A', 'a'), row(2, 'B', 'b')]);

      final ok = await repo.deleteById(1);
      expect(ok, isTrue);

      final all = await repo.readAll();
      expect(all.length, 1);
      expect(all.first.id, 2);

      final miss = await repo.deleteById(42);
      expect(miss, isFalse);

      expect(() => repo.deleteById(0), throwsArgumentError);
    });

    test('(i) getCount', () async {
      // 3 записи
      await writeYamlTeachers(
          [row(1, 'A', 'a'), row(2, 'B', 'b'), row(3, 'C', 'c')]);
      expect(await repo.getCount(), 3);

      // записан пустой список -> 0
      await writeYamlTeachers([]);
      expect(await repo.getCount(), 0);

      // без изменений файла остаётся 0
      expect(await repo.getCount(), 0);

      await writeYamlList([]);
      expect(await repo.getCount(), 0);
    });
  });
}
