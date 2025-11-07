part of teacher_lib;

class TeacherRepYaml {
  final String path;
  List<Teacher>? _cache;
  bool _emptyTeachersToggle = false;
  String? _lastText;

  TeacherRepYaml(this.path);

  dynamic _toDart(dynamic v) {
    if (v is YamlMap) {
      return Map<String, dynamic>.fromEntries(
        v.entries.map((e) => MapEntry(e.key.toString(), _toDart(e.value))),
      );
    }

    if (v is YamlList) {
      return v.map(_toDart).toList();
    } 
    return v;
  }

  Future<List<Teacher>> readAll() async {
    final file = File(path);
    if (!await file.exists()) return const <Teacher>[];

    final text = await file.readAsString();
    if (text.trim().isEmpty) return const <Teacher>[];

    final root = _toDart(loadYaml(text)); 

    List<dynamic>? list;
    if (root is List) {
      list = root;
    } else if (root is Map) {
      if (root.containsKey('teachers')) {
        final t = root['teachers'];
        if (t == null) return const <Teacher>[];          
        if (t is List) {
          list = t;
        } else {
          throw const FormatException('Field "teachers" must be a list.');
        }
      } else {
        throw const FormatException('YAML root must be a List or {teachers: [...]}');
      }
    } else {
      throw const FormatException('YAML root must be a List or {teachers: [...]}');
    }

    final out = <Teacher>[];
    for (var i = 0; i < list.length; i++) {
      try {
        out.add(Teacher.from(list[i]));
      } catch (err) {
        throw FormatException('Bad item #$i in $path: $err');
      }
    }
    return out;
  }


  Future<void> writeAll(List<Teacher> items) async {
    final data = items.map((e) => e.toJson()).toList();
    final yamlText = json2yaml(
      <String, dynamic>{'teachers': data},
      yamlStyle: YamlStyle.pubspecYaml, 
    ); 

    final file = File(path);
    await file.parent.create(recursive: true);

    await file.writeAsString(yamlText, flush: true);
    _cache = List<Teacher>.from(items);
  }

  Future<Teacher?> getById(int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'id must be > 0');

    final list = await readAll();
    for (final t in list) {
      final tid = t.id;
      if (tid != null && tid == id) {
        return t;
      }
    }
    return null;
  }

  int _compareByLastName(Teacher a, Teacher b) {
    int cmp(String x, String y) => x.toLowerCase().trim().compareTo(y.toLowerCase().trim());

    final c1 = cmp(a.lastName, b.lastName);
    if (c1 != 0) return c1;

    final c2 = cmp(a.firstName, b.firstName);
    if (c2 != 0) return c2;

    final idA = a.id ?? 1 << 30;
    final idB = b.id ?? 1 << 30;
    return idA.compareTo(idB);
  }

  /// Получить список [k] по счету [n] объектов класса [TeacherInfo] (например, вторые 20 элементов, чтобы в дальнейшем можно было листать длинный список)
  Future<List<TeacherInfo>> getKthNShortList({
    required int k,
    required int n
  }) async {
    if (k <= 0) throw ArgumentError.value(k, 'k', 'k must be > 0');
    if (n <= 0) throw ArgumentError.value(n, 'n', 'n must be > 0');

    final all = await readAll();

    if (all.isEmpty) return const <TeacherInfo>[];

    all.sort(_compareByLastName);

    final start = (n - 1) * k;
    if (start >= all.length) return const <TeacherInfo>[];

    final end = (start + k <= all.length) ? start + k : all.length; 
    final page = all.getRange(start, end).toList();

    List<TeacherInfo> toShort(List<Teacher> list) => list.map((t){
      return TeacherInfo.brief(
        id: t.id, 
        lastName: t.lastName, 
        firstName: t.firstName, 
        middleName: t.middleName,
        phone: t.phone
      );
    }).toList();

    return toShort(page);
  }

  /// Отсортирует по выбранному полю (фамилия). </br>
  /// Возвращает новый список; если persist=true — переписывает файл в отсортированном виде.
  Future <List<Teacher>> sortByLastName({bool persist = false}) async {
    final list = await readAll();
    if (list.isEmpty) return const <Teacher>[];

    list.sort(_compareByLastName);

    if (persist) {
      await writeAll(list);
    }
    return List<Teacher>.from(list);
  }

  Future<Teacher> add(Teacher item) async {
    if(item.id != null) throw ArgumentError('id must be null to add a new item to a list!');

    final list = await readAll();

    int maxId = 0;
    for (final t in list) {
      final tid = t.id;
      if (tid != null && tid > maxId) maxId = tid;
    }
    final newId = maxId + 1;

    final newItem = Teacher.withId(
      id: newId, 
      lastName: item.lastName, 
      middleName: item.middleName,
      firstName: item.firstName, 
      phone: item.phone, 
      experienceYears: item.experienceYears
    );

    list.add(newItem);
    await writeAll(list);

    return newItem;
  }

  Future<bool> replaceById(int id, Teacher item) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'id must be > 0');

    final list = await readAll();
    if (list.isEmpty) return false;

    final idx = list.indexWhere((t) => t.id == id);
    if (idx < 0) return false;

    final updated = Teacher.withId(
      id: id, 
      lastName: item.lastName, 
      middleName: item.middleName,
      firstName: item.firstName, 
      phone: item.phone, 
      experienceYears: item.experienceYears
    );

    list[idx] = updated;
    await writeAll(list);
    return true;
  }

  Future<bool> deleteById(int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'id must be > 0');

    final list = await readAll();
    if (list.isEmpty) return false;

    final idx = list.indexWhere((t) => t.id == id);
    if (idx < 0) return false;

    list.removeAt(idx);
    await writeAll(list);
    return true;
  }

  Future<int> getCount() async {
    final list = await readAll();
    return list.length;
  }
}
