import 'package:information_systems_design/domain/teacher_lib.dart';

class MainPageView {
  String renderMainPage(List<TeacherInfo> items) {
    final rows = items.map((t) => '''
      <tr>
        <td>${t.id}</td>
        <td>${t.lastName} ${t.firstName}</td>
        <td><a href="/teachers/${t.id}" target="_blank">Подробнее</a></td>
      </tr>
    ''').join();

    return '''
      <!DOCTYPE html>
      <html lang="ru">
      <head>
        <meta charset="UTF-8">
        <title>Учителя</title>
      </head>
      <body>
        <p><a href="/teachers/new" target="_blank">Add teacher</a></p>
        <h1>Список преподавателей</h1>
        <table border="1">
          <tr>
            <th>ID</th>
            <th>ФИО</th>
            <th>Детали</th>
          </tr>
          $rows
        </table>
      </body>
      </html>
    ''';
  }

  String renderDetails(Teacher t) {
    final fullName = '${t.lastName} ${t.firstName} ${t.middleName != null ? ' ${t.middleName}' : ''}';
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>$fullName — карточка преподавателя</title>
      </head>
      <body>
        <h1>$fullName</h1>

        <table border="1">
          <tr><th>ID</th><td>${t.id}</td></tr>
          <tr><th>Телефон</th><td>${t.phone}</td></tr>
          <tr><th>Стаж</th><td>${t.experienceYears} лет</td></tr>
        </table>
        <br><br>
        <a href="/teachers/${t.id}/edit" target="_blank">Edit</a>
        <br><br>
        <a href="/">← Назад к списку</a>
      </body>
      </html>
    ''';
  }
}
