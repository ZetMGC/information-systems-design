import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/domain/teacher_info.dart';
import 'package:information_systems_design/domain/teacher_rep_base.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

class TeacherRepDb extends TeacherRepBase {
  final PostgreSQLConnection db;
  TeacherRepDb(this.db);  

  @override
  String get path => 'db:postgres';

  @override
  Future<List<Teacher>> readAll() async =>
      throw UnsupportedError('DB repo: readAll() is not supported!');

  @override
  Future<void> writeAll(List<Teacher> items) async =>
      throw UnsupportedError('DB repo: writeAll() is not supported!');

  @override
  Future<Teacher?> getById(int id) async {
    if (id <= 0) throw ArgumentError.value(id , "id", "id must be > 0");

    const sql = '''
      SELECT id, last_name, first_name, middle_name, phone, experience_years
      FROM teachers
      WHERE id = @id
      LIMIT 1
    ''';

    final rows = await db.mappedResultsQuery(sql, substitutionValues: {'id': id});
    if (rows.isEmpty) return null;

    final m = rows.first['teachers']!;

    return Teacher.from(
    <String, dynamic>{
      'id': m['id'],
      'first_name': m['first_name'],
      'last_name': m['last_name'],
      'middle_name': m['middle_name'],
      'phone': m['phone'],
      'experience_years': m['experience_years']
    });
  }

  @override
  Future<List<TeacherInfo>> getKthNShortList ({
    required int k, 
    required int n
  }) async {
    if (k <= 0) throw ArgumentError.value(k, 'k', 'k must be > 0');
    if (n <= 0) throw ArgumentError.value(n, 'n', 'n must be > 0');

    final offset = (n - 1) * k;

    const sql = '''
      SELECT id, last_name, first_name, middle_name, phone, experience_years
      FROM teachers
      ORDER BY lower(last_name), lower(first_name), id
      LIMIT @k OFFSET @offset 
    ''';

    final rows = await db.mappedResultsQuery(sql, substitutionValues: {'k': k, 'offset': offset});

    return rows.map((r) {
      final m = r['teachers']!;
      return TeacherInfo.brief(
        id: m['id'] as int?, 
        lastName: m['last_name'] as String, 
        firstName: m['first_name'] as String, 
        middleName: m['middle_name'] as String?, 
        phone: m['phone'] as String
      );
    }).toList();
  }
  
  @override
  Future<Teacher> add(Teacher item) async {
    if (item.id != null) {
      throw ArgumentError("id must be null to add the new item!");
    }

    const sql = '''
      INSERT INTO teachers(last_name, first_name, middle_name, phone, experience_years)
      VALUES (@ln, @fn, @mn, @ph, @exp)
      RETURNING id, last_name, first_name, middle_name, phone, experience_years
    ''';

    final rows = await db.mappedResultsQuery(sql, substitutionValues: {
      'ln': item.lastName,
      'fn': item.firstName,
      'mn': item.middleName,
      'ph': item.phone,
      'exp': item.experienceYears
    });

    final m = rows.first['teachers']!;

    return Teacher.withId(
      id: m['id'] as int, 
      lastName: m['last_name'] as String, 
      firstName: m['first_name'] as String, 
      middleName: m['middle_name'] as String?, 
      phone: m['phone'] as String, 
      experienceYears: m['experience_years'] as int
    );
  }

  @override
  Future<bool> replaceById(int id, Teacher item) async {
    if (id <= 0) throw ArgumentError.value(id , "id", "id must be > 0");

    const sql = '''
      UPDATE teachers
      SET last_name = @ln, first_name = @fn, middle_name = @mn, phone = @ph, experience_years = @exp
      WHERE id = @id
    ''';

    final res = await db.execute(sql, substitutionValues: {
      'ln': item.lastName,
      'fn': item.firstName,
      'mn': item.middleName,
      'ph': item.phone,
      'exp': item.experienceYears,
      'id': id
    });

    final check = await db.query('SELECT 1 FROM teachers WHERE id=@id', substitutionValues: {'id': id});
    return check.isNotEmpty;
  }

  Future<bool> replaceByIdReturning(int id, Teacher item) async {
    if (id <= 0) throw ArgumentError.value(id , "id", "id must be > 0");

    const sql = '''
      UPDATE teachers
      SET last_name=@ln, first_name=@fn, middle_name=@mn, phone=@ph, experience_years=@exp
      WHERE id=@id
      RETURNING id
    ''';

    final rows = await db.query(sql, substitutionValues: {
      'ln': item.lastName, 
      'fn': item.firstName, 
      'mn': item.middleName,
      'ph': item.phone, 
      'exp': item.experienceYears, 
      'id': id,
    });

    return rows.isNotEmpty;
  }
  
  @override
  Future<bool> deleteById(int id) async {
    if (id <= 0) throw ArgumentError.value(id , "id", "id must be > 0");

    const sql = '''
      DELETE FROM teachers WHERE id=@id RETURNING id
    ''';

    final rows = await db.query(sql, substitutionValues: {'id': id});
    return rows.isNotEmpty;
  }

  @override
  Future<int> getCount() async {
    const sql = '''SELECT COUNT(*) FROM teachers''';
    final rows = await db.query(sql);

    return rows.first.first as int;
  }  
}

