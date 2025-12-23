import 'dart:convert';
import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/views/teacher_form_view.dart';

class EditTeacherController {
  final ObservableTeacherRepo _repo;
  final _view = TeacherFormView();

  EditTeacherController(this._repo);

  Future<void> handle(HttpRequest req, int id) async {
    try {
      if (id <= 0) {
        req.response.statusCode = HttpStatus.badRequest;
      } else if (req.method == 'GET') {
        await _handleGet(req.response, id);
      } else if (req.method == 'POST') {
        final form = await _readForm(req);
        await _handlePost(req.response, id, form);
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

    final values = <String, String>{
      'last_name': teacher.lastName,
      'first_name': teacher.firstName,
      'middle_name': teacher.middleName ?? '',
      'phone': teacher.phone,
      'experience_years': teacher.experienceYears.toString(),
    };

    _writeHtml(
      res,
      _view.renderForm(
        title: 'Edit teacher #$id',
        action: '/teachers/$id/edit',
        values: values,
      ),
    );
  }

  Future<void> _handlePost(
      HttpResponse res, int id, Map<String, String> form) async {
    final lastName = (form['last_name'] ?? '').trim();
    final firstName = (form['first_name'] ?? '').trim();
    final middleName = (form['middle_name'] ?? '').trim();
    final phone = (form['phone'] ?? '').trim();
    final expRaw = (form['experience_years'] ?? '').trim();

    final exp = int.tryParse(expRaw);
    if (exp == null) {
      _writeHtml(
        res,
        _view.renderForm(
          title: 'Edit teacher #$id',
          action: '/teachers/$id/edit',
          values: form,
          error: 'experience_years must be an integer',
        ),
      );
      return;
    }

    try {
      final updated = Teacher.withId(
        id: id,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName.isEmpty ? null : middleName,
        phone: phone,
        experienceYears: exp,
      );

      final ok = await _repo.replaceById(id, updated);
      if (!ok) {
        res.statusCode = HttpStatus.notFound;
        return;
      }

      _writeHtml(
        res,
        _view.renderSuccess(
          teacher: updated,
          backLink: '/teachers/$id',
          backLabel: 'Open details',
        ),
      );
    } catch (e) {
      _writeHtml(
        res,
        _view.renderForm(
          title: 'Edit teacher #$id',
          action: '/teachers/$id/edit',
          values: form,
          error: _errorMessage(e),
        ),
      );
    }
  }

  Future<Map<String, String>> _readForm(HttpRequest req) async {
    final body = await utf8.decoder.bind(req).join();
    if (body.trim().isEmpty) return <String, String>{};
    return Uri.splitQueryString(body);
  }

  String _errorMessage(Object e) {
    if (e is ArgumentError) {
      final m = e.message;
      if (m != null) return m.toString();
    }
    if (e is FormatException) {
      return e.message;
    }
    return e.toString();
  }

  void _writeHtml(HttpResponse res, String html) {
    res
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html);
  }
}
