import 'dart:convert';
import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/presentation/views/add_teacher_view.dart';

class AddTeacherController {
  final ObservableTeacherRepo _repo;
  final _view = AddTeacherView();

  AddTeacherController(this._repo);

  Future<void> handle(HttpRequest req) async {
    try {
      if (req.method == 'GET') {
        _writeHtml(req.response, _view.renderForm());
      } else if (req.method == 'POST') {
        final form = await _readForm(req);
        await _handlePost(req.response, form);
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

  Future<void> _handlePost(
      HttpResponse res, Map<String, String> form) async {
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
          values: form,
          error: 'experience_years must be an integer',
        ),
      );
      return;
    }

    try {
      final created = await _repo.add(Teacher.create(
        lastName: lastName,
        firstName: firstName,
        middleName: middleName.isEmpty ? null : middleName,
        phone: phone,
        experienceYears: exp,
      ));
      _writeHtml(res, _view.renderSuccess(created));
    } catch (e) {
      _writeHtml(
        res,
        _view.renderForm(values: form, error: _errorMessage(e)),
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
