import 'package:information_systems_design/domain/teacher_lib.dart';

typedef TeacherPredicate = bool Function(Teacher t);
typedef TeacherComparator = int Function(Teacher a, Teacher b);

int _defaultComp(Teacher a, Teacher b) {
  int cmpStr(String x, String y) => x.toLowerCase().trim().compareTo(y.toLowerCase().trim());

  final c1 = cmpStr(a.lastName, b.lastName);
  if(c1 != 0) return c1;

  final c2 = cmpStr(a.firstName, b.firstName);
  if(c2 != 0) return c2;

  final idA = a.id ?? 1 << 30;
  final idB = b.id ?? 1 << 30;
  return idA.compareTo(idB);
}

class TeacherRepFileDecor extends TeacherRepBase {
  final TeacherRepBase inner;
  final TeacherPredicate predicate;
  final TeacherComparator comparator;

  TeacherRepFileDecor({
    required this.inner,
    TeacherPredicate? filter,
    TeacherComparator? sort
  }) : predicate = filter ?? ((_) => true),
        comparator = sort ?? _defaultComp;

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
  Future<List<Teacher>> sortByLastName({bool persist = false}) => inner.sortByLastName(persist: persist);

  @override
  Future<List<TeacherInfo>> getKthNShortList({required int k, required int n}) async {
    if (k <= 0) throw ArgumentError.value(k, 'k', 'must be > 0');
    if (n <= 0) throw ArgumentError.value(n, 'n', 'must be > 0');

    final all = await inner.readAll();
    final filtered = all.where(predicate).toList();
    if (filtered.isEmpty) return const <TeacherInfo>[];

    filtered.sort(comparator);

    final start = (n - 1) * k;
    if(start >= filtered.length) return const <TeacherInfo>[];
    final end = (start + k <= filtered.length) ? start + k : filtered.length;

    final page = filtered.getRange(start, end).map((t) => TeacherInfo.brief(id: t.id, lastName: t.lastName, middleName: t.middleName, firstName: t.firstName, phone: t.phone)).toList();

    return page;
  }

  @override
  Future<int> getCount() async {
    final all = await inner.readAll();
    return all.where(predicate).length;
  }
}