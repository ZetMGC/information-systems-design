import 'package:information_systems_design/domain/teacher_lib.dart';
import 'package:information_systems_design/infrastructure/db/db_client.dart';
import 'package:information_systems_design/infrastructure/db/query_spec.dart';

class TeacherRepDbDecor extends TeacherRepBase {
  final TeacherRepBase inner;
  final DbClient db;
  final QueryFilter filter;
  final QuerySort? sort;

  TeacherRepDbDecor(
      {required this.inner,
      required this.db,
      this.filter = QueryFilter.none,
      this.sort});

  @override
  String get path => inner.path;

  @override
  Future<Teacher?> getById(int id) => inner.getById(id);

  @override
  Future<Teacher> add(Teacher item) => inner.add(item);

  @override
  Future<bool> deleteById(int id) => inner.deleteById(id);

  @override
  Future<bool> replaceById(int id, Teacher item) => inner.replaceById(id, item);

  @override
  Future<List<Teacher>> readAll() => inner.readAll();

  @override
  Future<void> writeAll(List<Teacher> items) => inner.writeAll(items);

  @override
  Future<List<Teacher>> sortByLastName({bool persist = false}) =>
      inner.sortByLastName(persist: persist);

  @override
  Future<List<TeacherInfo>> getKthNShortList(
      {required int k, required int n}) async {
    final offset = (n - 1) * k;
    final whereSql = filter.where.trim().isEmpty ? '' : 'WHERE ${filter.where}';
    final orderSql = sort == null
        ? 'ORDER BY lower(last_name), lower(first_name), id'
        : 'ORDER BY ${sort!.toOrderBySql()}';

    final rows = await db.mappedQuery('''
      SELECT id, last_name, first_name, middle_name, phone
      FROM teachers
      $whereSql
      $orderSql
      LIMIT @k OFFSET @off
    ''', params: {...filter.params, 'k': k, 'off': offset});

    return rows.map((r) {
      final m = r.values.first;
      return TeacherInfo.brief(
          id: m['id'] as int?,
          lastName: m['last_name'] as String,
          firstName: m['first_name'] as String,
          middleName: m['middle_name'] as String?,
          phone: m['phone'] as String);
    }).toList();
  }

  @override
  Future<int> getCount() async {
    final whereSql = filter.where.trim().isEmpty ? '' : 'WHERE ${filter.where}';
    return db.scalarInt('SELECT COUNT(*)::int FROM teachers $whereSql',
        params: filter.params);
  }
}
