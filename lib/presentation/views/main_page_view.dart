import 'package:information_systems_design/domain/teacher_lib.dart';

class MainPageView {
  String renderMainPage(
    List<TeacherInfo> items, {
    Map<String, String>? filters,
    String? error,
  }) {
    final f = filters ?? const <String, String>{};
    String val(String key, String fallback) => f[key] ?? fallback;
    String selected(String value, String current) =>
        value == current ? ' selected' : '';

    final errHtml = (error == null || error.trim().isEmpty)
        ? ''
        : '<div class="error">${_esc(error)}</div>';

    final rows = items.map((t) => '''
      <tr>
        <td>${t.id}</td>
        <td>${_esc(t.lastName)} ${_esc(t.firstName)}</td>
        <td>
          <a href="/teachers/${t.id}" target="_blank">Подробнее</a>
        </td>
      </tr>
    ''').join();

    return '''
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>Учителя</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card actions">
      <a class="btn" href="/teachers/new" target="_blank">➕ Add teacher</a>
    </div>

    $errHtml

    <div class="card">
      <form method="get" action="/">
        <label>
          Last name starts with
          <input name="last_name_prefix" value="${_esc(val('last_name_prefix', ''))}">
        </label>

        <label>
          Min experience
          <input name="min_exp" type="number" min="0" max="80"
                 value="${_esc(val('min_exp', ''))}">
        </label>

        <label>
          K
          <input name="k" type="number" min="1"
                 value="${_esc(val('k', '10'))}">
        </label>

        <label>
          N
          <input name="n" type="number" min="1"
                 value="${_esc(val('n', '1'))}">
        </label>

        <label>
          Sort by
          <select name="sort_by">
            <option value=""${selected('', val('sort_by', ''))}>Default</option>
            <option value="last_name"${selected('last_name', val('sort_by', ''))}>Last name</option>
            <option value="first_name"${selected('first_name', val('sort_by', ''))}>First name</option>
            <option value="id"${selected('id', val('sort_by', ''))}>ID</option>
            <option value="experience"${selected('experience', val('sort_by', ''))}>Experience</option>
          </select>
        </label>

        <label>
          Direction
          <select name="sort_dir">
            <option value="asc"${selected('asc', val('sort_dir', 'asc'))}>ASC</option>
            <option value="desc"${selected('desc', val('sort_dir', 'asc'))}>DESC</option>
          </select>
        </label>

        <button class="btn" type="submit">Apply</button>
      </form>
    </div>

    <div class="card">
      <h1>Список преподавателей</h1>

      <table>
        <tr>
          <th>ID</th>
          <th>ФИО</th>
          <th>Детали</th>
        </tr>
        $rows
      </table>
    </div>

  </div>
</body>
</html>
''';
  }

  String renderDetails(Teacher t) {
    final fullName =
        '${t.lastName} ${t.firstName}${t.middleName != null ? ' ${t.middleName}' : ''}';

    return '''
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>$fullName</title>
  <link rel="stylesheet" href="/styles.css">
</head>

<body>
  <div class="container">

    <div class="card">
      <h1>$fullName</h1>

      <table>
        <tr><th>ID</th><td>${t.id}</td></tr>
        <tr><th>Телефон</th><td>${_esc(t.phone)}</td></tr>
        <tr><th>Стаж</th><td>${t.experienceYears} лет</td></tr>
      </table>
    </div>

    <div class="card actions">
      <a class="btn" href="/teachers/${t.id}/edit" target="_blank">✏ Edit</a>
      <a class="btn secondary" href="/teachers/${t.id}/delete" target="_blank">🗑 Delete</a>
      <a class="btn secondary" href="/">← Back</a>
    </div>

  </div>
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


