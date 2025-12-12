import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/views/main_page_view.dart';

class MainPageController implements TeacherObserver {
  final ObservableTeacherRepo _repo;

  MainPageController(this._repo);
  final _view = MainPageView();

  Future<void> handle(HttpRequest req) async {
    final path = req.uri.path;
    try {
      if (path == '/' || path.isEmpty) {
        final k = int.tryParse(req.uri.queryParameters['k'] ?? '10') ?? 10;
        final n = int.tryParse(req.uri.queryParameters['n'] ?? '1') ?? 1;
        final data = await _repo.getKthNShortList(k: k, n: n);
        final html = _view.renderMainPage(data);
        _writeHtml(req.response, html);
      } else if (path.startsWith('/teachers/')) {
        final id = int.tryParse(path.split('/').last);
        if (id == null) {
          req.response.statusCode = HttpStatus.badRequest;
        } else {
          final teacher = await _repo.getById(id);
          if (teacher == null) {
            req.response.statusCode = HttpStatus.notFound;
          } else {
            final html = _view.renderDetails(teacher);
            _writeHtml(req.response, html);
          }
        }
      } else {
        req.response.statusCode = HttpStatus.notFound;
      }
    } catch (e) {
      req.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error: $e');
    } finally {
      await req.response.close();
    }
  }

  void _writeHtml(HttpResponse res, String html) {
    res 
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html);
  }

  @override
  void onChanged(List<Teacher> items) {
  }
}