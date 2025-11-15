import 'dart:io';
import 'package:postgres/postgres.dart';

class AppDb {
  // ---- Singleton ----
  AppDb._();
  static final AppDb _instance = AppDb._();
  static AppDb get I => _instance;

  PostgreSQLConnection? _conn;
  bool get isOpen => _conn != null && _conn!.isClosed == false;
  PostgreSQLConnection get conn {
    if (!isOpen) {
      throw StateError('DB is not open. Call AppDb.I.open(...) first.');
    }
    return _conn!;
  }

  /// Открытие подключения
  Future<void> open({
    required String host,
    required int port,
    required String database,
    required String user,
    required String password,
    bool useSSL = false,
    bool acceptBadCert = false
  }) async {
    if (isOpen) return;
    _conn = PostgreSQLConnection(
      host,
      port,
      database,
      username: user,
      password: password,
      useSSL: useSSL,
    );
    await _conn!.open();
  }

  Future<void> openFromENV({
    String defaultHost = '127.0.0.1',
    int defaultPort = 5432,
    String defaultDb = 'postgres',
    String defaultUser = 'postgres',
    String defaultPass = 'postgres',
    bool useSSL = false,
    bool acceptBadCert = false
  }) async {
    await open(
      host: Platform.environment['PGHOST'] ?? defaultHost,
      port: int.tryParse(Platform.environment['PGPORT'] ?? '') ?? defaultPort,
      database: Platform.environment['PGDATABASE'] ?? defaultDb,
      user: Platform.environment['PGUSER'] ?? defaultUser,
      password: Platform.environment['PGPASSWORD'] ?? defaultPass,
      useSSL: useSSL,
      acceptBadCert: acceptBadCert
    );
  }

  Future<void> close() async {
    if(isOpen) {
      await _conn!.close();
      _conn = null;
    }
  }

  Future<List<List<dynamic>>> query(
    String sql, {Map<String, dynamic>? params}
  ) => conn.query(sql, substitutionValues: params);

  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(
    String sql, {Map<String, dynamic>? params}
  ) => conn.mappedResultsQuery(sql, substitutionValues: params);

  Future<int> execute(
    String sql, {Map<String, dynamic>? params}
  ) => conn.execute(sql, substitutionValues: params);

  Future<T> transaction<T>(
    Future<T> Function(PostgreSQLExecutionContext tx) fn
  ) async {
    final dynamic res = await conn.transaction((ctx) => fn(ctx));
    return res as T;
  }

  Future<int> scalarInt(String sql, {Map<String, dynamic>? params}) async {
    final r = await query(sql, params: params);
    final v = r.first.first;
    return v is int ? v : int.parse(v.toString());
  }
}
