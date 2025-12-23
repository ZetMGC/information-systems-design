import 'dart:io';

import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/views/delete_teacher_view.dart';

class DeleteTeacherController {
  final ObservableTeacherRepo _repo;
  final _view = DeleteTeacherView();

  DeleteTeacherController(this._repo);

  Future<void> handle(HttpRequest req, int id) async {
    try {
      if (id <= 0) {
        req.response.statusCode = HttpStatus.badRequest;
      } else if (req.method == 'GET') {
        await _handleGet(req.response, id);
      } else if (req.method == 'POST') {
        await _handlePost(req.response, id);
      } else {
        req.response.statusCode = HttpStatus.methodNotAllowed;
      }
    } catch (e) {
      req.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error: $e');
    } finally {
      await req.response.close();
    }
  }

  Future<void> _handleGet(HttpResponse res, int id) async {
    final teacher = await _repo.getById(id);
    if (teacher == null) {
      res.statusCode = HttpStatus.notFound;
      return;
    }
    _writeHtml(res, _view.renderConfirm(teacher));
  }

  Future<void> _handlePost(HttpResponse res, int id) async {
    final ok = await _repo.deleteById(id);
    if (!ok) {
      res.statusCode = HttpStatus.notFound;
      return;
    }
    _writeHtml(res, _view.renderSuccess(id));
  }

  void _writeHtml(HttpResponse res, String html) {
    res
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html);
  }
}
