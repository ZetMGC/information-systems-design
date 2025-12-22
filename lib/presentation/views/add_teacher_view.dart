import 'package:information_systems_design/domain/teacher.dart';

class AddTeacherView {
  String renderForm({Map<String, String>? values, String? error}) {
    final v = values ?? const <String, String>{};
    String val(String key) => _esc(v[key] ?? '');

    final errHtml = (error == null || error.trim().isEmpty)
        ? ''
        : '<p style="color:red;">${_esc(error)}</p>';

    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Add teacher</title>
      </head>
      <body>
        <h1>Add teacher</h1>
        $errHtml
        <form method="post" action="/teachers/new">
          <label>Last name:
            <input name="last_name" value="${val('last_name')}" required>
          </label><br><br>
          <label>First name:
            <input name="first_name" value="${val('first_name')}" required>
          </label><br><br>
          <label>Middle name:
            <input name="middle_name" value="${val('middle_name')}">
          </label><br><br>
          <label>Phone:
            <input name="phone" value="${val('phone')}" required>
          </label><br><br>
          <label>Experience years:
            <input name="experience_years" type="number" min="0" max="80" value="${val('experience_years')}" required>
          </label><br><br>
          <button type="submit">Save</button>
        </form>
        <script>
          window.addEventListener('beforeunload', function () {
            if (window.opener && !window.opener.closed) {
              window.opener.location.reload();
            }
          });
        </script>
      </body>
      </html>
    ''';
  }

  String renderSuccess(Teacher t) {
    final name = _esc('${t.lastName} ${t.firstName}');
    final middle = t.middleName == null ? '' : ' ${t.middleName}';
    final fullName = _esc('$name$middle');

    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Saved</title>
      </head>
      <body>
        <h1>Saved</h1>
        <p>$fullName</p>
        <table border="1">
          <tr><th>ID</th><td>${t.id}</td></tr>
          <tr><th>Phone</th><td>${_esc(t.phone)}</td></tr>
          <tr><th>Experience</th><td>${t.experienceYears}</td></tr>
        </table>
        <p><a href="/" target="_blank">Back to list</a></p>
        <button onclick="window.close()">Close</button>
        <script>
          if (window.opener && !window.opener.closed) {
            window.opener.location.reload();
          }
          setTimeout(function () { window.close(); }, 100);
        </script>
      </body>
      </html>
    ''';
  }

  String _esc(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
