import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/domain/teacher_rep_base.dart';
import 'package:information_systems_design/infrastructure/file/teacher_rep_file_decor.dart';
import 'package:test/test.dart';

class _FakeTeacherRepo extends TeacherRepBase {
  List<Teacher> _items;
  _FakeTeacherRepo(this._items);

  @override
  String get path => 'memory://teachers';

  @override
  Future<List<Teacher>> readAll() async => List<Teacher>.from(_items);

  @override
  Future<void> writeAll(List<Teacher> items) async {
    _items = List<Teacher>.from(items);
  }
}

Teacher _t({
  required int id,
  required String last,
  required String first,
  String? middle,
  required String phone,
  required int exp,
}) =>
    Teacher.withId(
      id: id,
      lastName: last,
      firstName: first,
      middleName: middle,
      phone: phone,
      experienceYears: exp,
    );

void main() {
  group('TeacherRepFileDecor', () {
    late _FakeTeacherRepo base;

    setUp(() {
      base = _FakeTeacherRepo([
        _t(
            id: 1,
            last: 'Ivanov',
            first: 'Sergey',
            middle: 'Petrovich',
            phone: '+100',
            exp: 2),
        _t(
            id: 2,
            last: 'Sidorov',
            first: 'Alex',
            middle: 'Ivanovich',
            phone: '+101',
            exp: 7),
        _t(
            id: 3,
            last: 'Petrov',
            first: 'Boris',
            middle: 'Alekseevich',
            phone: '+102',
            exp: 5),
        _t(
            id: 4,
            last: 'Orlov',
            first: 'Anton',
            middle: null,
            phone: '+103',
            exp: 10),
      ]);
    });

    test('applies predicate, pagination, and preserves middle names', () async {
      final decor = TeacherRepFileDecor(
        inner: base,
        filter: (t) => t.experienceYears >= 5,
      );

      final page1 = await decor.getKthNShortList(k: 2, n: 1);
      expect(page1.map((t) => t.lastName), ['Orlov', 'Petrov']);
      expect(page1[0].middleName, isNull);
      expect(page1[1].middleName, 'Alekseevich');

      final page2 = await decor.getKthNShortList(k: 2, n: 2);
      expect(page2.length, 1);
      expect(page2.first.lastName, 'Sidorov');
    });

    test('custom comparator and getCount reflect filter', () async {
      final decor = TeacherRepFileDecor(
        inner: base,
        filter: (t) => t.phone != '+100',
        sort: (a, b) => b.experienceYears.compareTo(a.experienceYears),
      );

      final list = await decor.getKthNShortList(k: 3, n: 1);
      expect(list.map((t) => t.id), [4, 2, 3]);

      final count = await decor.getCount();
      expect(count, 3);
    });
  });
}
