import 'dart:convert';
import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/domain/teacher_rep_base.dart';

class TeacherRepJson extends TeacherRepBase {
  @override
  final String path;
  TeacherRepJson(this.path);

  @override
  Future<List<Teacher>> readAll() async {
    final file = File(path);
    if (!await file.exists()) return <Teacher>[];

    final text = await file.readAsString();
    if (text.trim().isEmpty) return <Teacher>[];

    final dynamic raw = jsonDecode(text);
    if (raw is! List) {
      throw const FormatException('JSON root must be a List!');
    }

    final list = (raw).asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      try {
        return Teacher.from(e);
      } catch (err) {
        throw FormatException('Bad item #$i in $path: $err');
      }
    }).toList();

    return list;
  }

  @override
  Future<void> writeAll(List<Teacher> items) async {
    ensureUniquePhones(items);
    final jsonText = jsonEncode(items.map((t) => t.toJson()).toList());
    await File(path).parent.create(recursive: true);
    await File(path).writeAsString(jsonText, flush: true);
  }
}
