import 'dart:io';

import 'package:information_systems_design/domain/teacher_lib.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/controllers/main_page_controller.dart';

void main() async {
  final baseRepo = TeacherRepJson('./data/teachers.json');
  final repo = ObservableTeacherRepo(baseRepo);

  final controller = MainPageController(repo);
  repo.addObserver(controller);

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Listening on http://${server.address.host}:${server.port}');

  await for (final req in server) {
    await controller.handle(req);
  }
}