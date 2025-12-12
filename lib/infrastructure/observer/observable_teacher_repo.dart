import 'package:information_systems_design/domain/teacher_lib.dart';

abstract class TeacherObserver {
  void onChanged(List<Teacher> items);
}

class ObservableTeacherRepo extends TeacherRepBase {
  final TeacherRepBase _inner;
  final _observers = <TeacherObserver>[];

  ObservableTeacherRepo(this._inner);

  void addObserver(TeacherObserver obs) => _observers.add(obs);
  void removeObserver(TeacherObserver obs) => _observers.remove(obs);

  void _notify(List<Teacher> data) {
    for (final obs in _observers) {
      obs.onChanged(data);
    }
  }

  @override
  String get path => _inner.path;

  @override
  Future<void> writeAll(List<Teacher> items) async {
    await _inner.writeAll(items);
    _notify(items);
  }

  @override
  Future<Teacher> add(Teacher item) async {
    final newItem = await _inner.add(item);
    final fresh = await _inner.readAll();
    _notify(fresh);
    return newItem;
  }

  @override
  Future<List<Teacher>> readAll() => _inner.readAll();
}
