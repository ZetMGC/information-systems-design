import 'dart:io';

import 'package:information_systems_design/domain/teacher.dart';
import 'package:information_systems_design/infrastructure/observer/observable_teacher_repo.dart';
import 'package:information_systems_design/infrastructure/file/teacher_rep_file_decor.dart';
import 'package:information_systems_design/presentation/views/main_page_view.dart';

class MainPageController implements TeacherObserver {
  final ObservableTeacherRepo _repo;

  MainPageController(this._repo);
  final _view = MainPageView();

  Future<void> handle(HttpRequest req) async {
    final path = req.uri.path;
    try {
      if (path == '/' || path.isEmpty) {
        final qp = req.uri.queryParameters;
        final k = int.tryParse(qp['k'] ?? '10') ?? 10;
        final n = int.tryParse(qp['n'] ?? '1') ?? 1;
        final prefix = qp['last_name_prefix']?.trim() ?? '';
        final minExpRaw = qp['min_exp']?.trim() ?? '';
        final sortByRaw = qp['sort_by']?.trim() ?? '';
        final sortDirRaw = qp['sort_dir']?.trim().toLowerCase() ?? 'asc';

        String? error;
        int? minExp;
        if (minExpRaw.isNotEmpty) {
          minExp = int.tryParse(minExpRaw);
          if (minExp == null) {
            error = 'min_exp must be an integer';
          }
        }

        String sortBy = '';
        switch (sortByRaw) {
          case '':
          case 'last_name':
          case 'first_name':
          case 'id':
          case 'experience':
            sortBy = sortByRaw;
          default:
            error = (error == null)
                ? 'sort_by is invalid'
                : '$error; sort_by is invalid';
            sortBy = '';
        }

        final sortDir =
            (sortDirRaw == 'desc' || sortDirRaw == 'asc') ? sortDirRaw : 'asc';

        final hasFilterOrSort =
            prefix.isNotEmpty || minExp != null || sortBy.isNotEmpty;
        final repoToUse = hasFilterOrSort
            ? TeacherRepFileDecor(
                inner: _repo,
                filter: (t) {
                  if (prefix.isNotEmpty &&
                      !t.lastName.toLowerCase().startsWith(prefix.toLowerCase())) {
                    return false;
                  }
                  if (minExp != null && t.experienceYears < minExp) return false;
                  return true;
                },
                sort: sortBy.isEmpty
                    ? null
                    : (a, b) {
                        int cmpStr(String x, String y) => x
                            .toLowerCase()
                            .trim()
                            .compareTo(y.toLowerCase().trim());

                        int cmp;
                        switch (sortBy) {
                          case 'first_name':
                            cmp = cmpStr(a.firstName, b.firstName);
                            break;
                          case 'id':
                            final idA = a.id ?? 1 << 30;
                            final idB = b.id ?? 1 << 30;
                            cmp = idA.compareTo(idB);
                            break;
                          case 'experience':
                            cmp = a.experienceYears.compareTo(b.experienceYears);
                            break;
                          case 'last_name':
                          default:
                            cmp = cmpStr(a.lastName, b.lastName);
                        }
                        return sortDir == 'desc' ? -cmp : cmp;
                      },
              )
            : _repo;

        final data = await repoToUse.getKthNShortList(k: k, n: n);
        final html = _view.renderMainPage(
          data,
          filters: {
            'last_name_prefix': prefix,
            'min_exp': minExpRaw,
            'k': k.toString(),
            'n': n.toString(),
            'sort_by': sortBy,
            'sort_dir': sortDir,
          },
          error: error,
        );
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
