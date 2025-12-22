import 'dart:io';

import 'package:information_systems_design/domain/teacher_lib.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/controllers/add_teacher_controller.dart';
import 'package:information_systems_design/presentation/controllers/edit_teacher_controller.dart';
import 'package:information_systems_design/presentation/controllers/main_page_controller.dart';

void main() async {
  final baseRepo = TeacherRepJson('./data/teachers.json');
  final repo = ObservableTeacherRepo(baseRepo);

  final mainController = MainPageController(repo);
  final addController = AddTeacherController(repo);
  final editController = EditTeacherController(repo);
  repo.addObserver(mainController);

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Listening on http://${server.address.host}:${server.port}');

  await for (final req in server) {
    final path = req.uri.path;
    if (path == '/teachers/new') {
      await addController.handle(req);
    } else if (path.startsWith('/teachers/') && path.endsWith('/edit')) {
      final parts = path.split('/');
      if (parts.length >= 4) {
        final id = int.tryParse(parts[2]);
        if (id == null) {
          req.response.statusCode = HttpStatus.badRequest;
          await req.response.close();
        } else {
          await editController.handle(req, id);
        }
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    } else {
      await mainController.handle(req);
    }
  }
}
