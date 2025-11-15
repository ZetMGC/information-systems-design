import 'package:test/test.dart';
import 'package:postgres/postgres.dart';
import 'package:information_systems_design/domain/teacher_lib.dart';

import 'dart:io';


void main() {
  late PostgreSQLConnection conn; 
  late TeacherRepDb repo;

  final host = Platform.environment['PGHOST'] ?? '127.0.0.1';
  final port = int.parse(Platform.environment['PGPORT'] ?? '5432');
  final db   = Platform.environment['PGDATABASE'] ?? 'postgres';
  final user = Platform.environment['PGUSER'] ?? 'postgres';
  final pass = Platform.environment['PGPASSWORD'] ?? 'secret';

  setUpAll(() async {
    conn = PostgreSQLConnection(host, port, db, username: user, password: pass);
    await conn.open();

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS teachers (
        id               SERIAL PRIMARY KEY,
        last_name        TEXT      NOT NULL,
        first_name       TEXT      NOT NULL,
        middle_name      TEXT,
        phone            TEXT      NOT NULL,
        experience_years INT       NOT NULL
      );
    ''');

    await conn.execute(r'''
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_indexes
          WHERE schemaname = ANY(current_schemas(true))
            AND indexname = 'ux_teachers_phone'
        ) THEN
          CREATE UNIQUE INDEX ux_teachers_phone ON teachers(phone);
        END IF;
      END $$;
    ''');

    repo = TeacherRepDb(conn);
  });

  setUp(() async {
    await conn.execute('TRUNCATE TABLE teachers RESTART IDENTITY CASCADE;');
  });

  tearDownAll(() async {
    await conn.close();
  });

  Future<int> _seed({ 
    required String ln,
    required String fn,
    String? mn,
    required String phone,
    required int exp,
  }) async {
    final rows = await conn.query(
      '''
      INSERT INTO teachers (last_name, first_name, middle_name, phone, experience_years)
      VALUES (@ln, @fn, @mn, @ph, @exp)
      RETURNING id
      ''',
      substitutionValues: {'ln': ln, 'fn': fn, 'mn': mn, 'ph': phone, 'exp': exp},
    );
    return rows.first.first as int;
  }

  group('TeacherRepDB', () {
    test('(a) getById: returns Teacher or null; invalid id throws', () async {
      final id1 = await _seed(ln: 'Иванов', fn: 'Иван', mn: 'Иваныч', phone: '+79990000001', exp: 5);
      final id2 = await _seed(ln: 'Петров', fn: 'Пётр', phone: '+79990000002', exp: 3);

      final t2 = await repo.getById(id2);
      expect(t2, isNotNull);
      expect(t2!.id, id2);
      expect(t2.lastName, 'Петров');
      expect(t2.firstName, 'Пётр');
      expect(t2.middleName, isNull);
      expect(t2.phone, '+79990000002');
      expect(t2.experienceYears, 3);

      final miss = await repo.getById(99999);
      expect(miss, isNull);

      expect(() => repo.getById(0), throwsArgumentError);
      expect(() => repo.getById(-7), throwsArgumentError);

      final t1 = await repo.getById(id1);
      expect(t1!.middleName, 'Иваныч');
    });

    test('(b) getKthNShortList: sorted by lastName/firstName/id with pagination', () async {
      // Разброс по алфавиту и id
      await _seed(ln: 'Иванов', fn: 'Иван', mn: 'Иваныч', phone: '+79990000001', exp: 5);
      await _seed(ln: 'Петров', fn: 'Пётр', phone: '+79990000002', exp: 3);              
      await _seed(ln: 'Альтов', fn: 'Антон', phone: '+79990000003', exp: 2);             

      // Ожидаемый алфавит: Альтов(3), Иванов(1), Петров(2)
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

    test('(c) add: assigns new id and persists', () async {
      final created = await repo.add(Teacher.create(
        lastName: 'Сидоров',
        firstName: 'Семён',
        middleName: 'Сергеевич',
        phone: '+79990000010',
        experienceYears: 4,
      ));
      expect(created.id, isNotNull);

      final back = await repo.getById(created.id!);
      expect(back, isNotNull);
      expect(back!.lastName, 'Сидоров');
      expect(back.firstName, 'Семён');
      expect(back.middleName, 'Сергеевич');
      expect(back.phone, '+79990000010');
      expect(back.experienceYears, 4);

      expect(
        () => repo.add(Teacher.withId(
          id: 123,
          lastName: 'X',
          firstName: 'Y',
          phone: '+79990000011',
          experienceYears: 1,
        )),
        throwsArgumentError,
      );

      await expectLater(
        () => repo.add(Teacher.create(
          lastName: 'Другой',
          firstName: 'Чел',
          phone: '+79990000010', 
          experienceYears: 1,
        )),
        throwsA(anything), 
      );
    });

    test('(d) replaceById: true if updated, false if not found', () async {
      final id = await _seed(ln: 'Old', fn: 'Name', mn: 'M', phone: '+79990000020', exp: 1);

      final ok = await repo.replaceById(
        id,
        Teacher.create(
          lastName: 'New',
          firstName: 'John',
          middleName: 'Q',
          phone: '+79990000021',
          experienceYears: 9,
        ),
      );
      expect(ok, isTrue);

      final after = await repo.getById(id);
      expect(after, isNotNull);
      expect(after!.lastName, 'New');
      expect(after.firstName, 'John');
      expect(after.middleName, 'Q');
      expect(after.phone, '+79990000021');
      expect(after.experienceYears, 9);

      final miss = await repo.replaceById(
        99999,
        Teacher.create(
          lastName: 'Z',
          firstName: 'z',
          phone: '+79990000022',
          experienceYears: 2,
        ),
      );
      expect(miss, isFalse);

      expect(() => repo.replaceById(0, Teacher.create(lastName: 'A', firstName: 'a', phone: '+79990000023', experienceYears: 1)),
          throwsArgumentError);
    });

    test('(e) deleteById: true if deleted, false if absent; invalid id throws', () async {
      final id1 = await _seed(ln: 'A', fn: 'a', phone: '+79990000030', exp: 1);
      final id2 = await _seed(ln: 'B', fn: 'b', phone: '+79990000031', exp: 2);

      final ok = await repo.deleteById(id1);
      expect(ok, isTrue);

      final still = await repo.getById(id2);
      expect(still, isNotNull);
      expect(still!.id, id2);

      final miss = await repo.deleteById(99999);
      expect(miss, isFalse);

      expect(() => repo.deleteById(0), throwsArgumentError);
    });

    test('(f) getCount', () async {
      expect(await repo.getCount(), 0);

      await _seed(ln: 'A', fn: 'a', phone: '+79990000040', exp: 1);
      await _seed(ln: 'B', fn: 'b', phone: '+79990000041', exp: 2);
      await _seed(ln: 'C', fn: 'c', phone: '+79990000042', exp: 3);

      expect(await repo.getCount(), 3);

      await conn.execute('TRUNCATE TABLE teachers RESTART IDENTITY CASCADE;');
      expect(await repo.getCount(), 0);
    });
  });
}
