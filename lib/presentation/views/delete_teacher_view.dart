import 'package:information_systems_design/domain/teacher.dart';

class DeleteTeacherView {
  String renderConfirm(Teacher t) {
    final name = _esc('${t.lastName} ${t.firstName}');
    final middle = t.middleName == null ? '' : ' ${t.middleName}';
    final fullName = _esc('$name$middle');

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Delete teacher</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card center">
      <h1>Delete teacher</h1>

      <p class="muted">Are you sure you want to delete:</p>
      <p><strong>$fullName</strong></p>

      <form method="post" action="/teachers/${t.id}/delete">
        <div class="actions" style="justify-content:center; margin-top:20px;">
          <button class="btn danger" type="submit">🗑 Delete</button>
          <a class="btn secondary" href="/teachers/${t.id}" target="_blank">
            Cancel
          </a>
        </div>
      </form>
    </div>

  </div>
</body>
</html>
''';
  }

  String renderSuccess(int id) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Deleted</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card center">
      <h1>Deleted</h1>
      <p class="muted">Teacher #$id was successfully deleted.</p>

      <div class="actions" style="justify-content:center; margin-top:20px;">
        <a class="btn" href="/" target="_blank">Back to list</a>
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
