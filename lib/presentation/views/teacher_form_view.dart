import 'package:information_systems_design/domain/teacher.dart';

class TeacherFormView {
  String renderForm({
    required String title,
    required String action,
    required Map<String, String> values,
    String? error,
  }) {
    String val(String key) => _esc(values[key] ?? '');

    final errHtml = (error == null || error.trim().isEmpty)
        ? ''
        : '<div class="error">${_esc(error)}</div>';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>$title</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card">
      <h1>$title</h1>

      $errHtml

      <form method="post" action="$action">

        <label>
          Last name
          <input name="last_name" value="${val('last_name')}" required>
        </label>

        <label>
          First name
          <input name="first_name" value="${val('first_name')}" required>
        </label>

        <label>
          Middle name
          <input name="middle_name" value="${val('middle_name')}">
        </label>

        <label>
          Phone
          <input name="phone" value="${val('phone')}" required>
        </label>

        <label>
          Experience years
          <input
            name="experience_years"
            type="number"
            min="0"
            max="80"
            value="${val('experience_years')}"
            required
          >
        </label>

        <div class="actions" style="margin-top:20px;">
          <button class="btn" type="submit">💾 Save</button>
          <button
            type="button"
            class="btn secondary"
            onclick="window.close()"
          >
            Cancel
          </button>
        </div>

      </form>
    </div>

  </div>

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

  String renderSuccess({
    required Teacher teacher,
    required String backLink,
    required String backLabel,
  }) {
    final name = _esc('${teacher.lastName} ${teacher.firstName}');
    final middle =
        teacher.middleName == null ? '' : ' ${teacher.middleName}';
    final fullName = _esc('$name$middle');

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Saved</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card center">
      <h1>Saved</h1>
      <p><strong>$fullName</strong></p>

      <table>
        <tr><th>ID</th><td>${teacher.id}</td></tr>
        <tr><th>Phone</th><td>${_esc(teacher.phone)}</td></tr>
        <tr><th>Experience</th><td>${teacher.experienceYears}</td></tr>
      </table>

      <div class="actions" style="justify-content:center; margin-top:20px;">
        <a class="btn" href="$backLink" target="_blank">$backLabel</a>
        <button class="btn secondary" onclick="window.close()">Close</button>
      </div>
    </div>

  </div>

  <script>
    if (window.opener && !window.opener.closed) {
      window.opener.location.reload();
    }
    setTimeout(function () { window.close(); }, 150);
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
