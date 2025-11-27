import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/domain/teacher_rep_base.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class TeacherRepYaml extends TeacherRepBase {
  @override
  final String path;

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

  @override
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
        throw const FormatException(
            'YAML root must be a List or {teachers: [...]}');
      }
    } else {
      throw const FormatException(
          'YAML root must be a List or {teachers: [...]}');
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

  @override
  Future<void> writeAll(List<Teacher> items) async {
    final data = items.map((e) => e.toJson()).toList();
    final yamlText = json2yaml(
      <String, dynamic>{'teachers': data},
      yamlStyle: YamlStyle.pubspecYaml,
    );

    final file = File(path);
    await file.parent.create(recursive: true);

    await file.writeAsString(yamlText, flush: true);
  }
}
