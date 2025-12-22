import 'package:information_systems_design/domain/teacher.dart';

class EditTeacherView {
  String renderForm({
    required int id,
    required Map<String, String> values,
    String? error,
  }) {
    String val(String key) => _esc(values[key] ?? '');

    final errHtml = (error == null || error.trim().isEmpty)
        ? ''
        : '<p style="color:red;">${_esc(error)}</p>';

    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Edit teacher</title>
      </head>
      <body>
        <h1>Edit teacher #$id</h1>
        $errHtml
        <form method="post" action="/teachers/$id/edit">
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
        <p><a href="/teachers/${t.id}" target="_blank">Open details</a></p>
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
