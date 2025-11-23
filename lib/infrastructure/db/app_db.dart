import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:information_systems_design/infrastructure/db/db_client.dart';

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

  Future<R> transaction<R>(Future<R> Function(DbTx tx) action) async {
    final R res = await conn.transaction(
      (PostgreSQLExecutionContext ctx) => action(_PgTx(ctx)),
    );
    return res;
  }

  Future<int> scalarInt(String sql, {Map<String, dynamic>? params}) async {
    final r = await query(sql, params: params);
    final v = r.first.first;
    return v is int ? v : int.parse(v.toString());
  }
}

class _PgTx implements DbTx {
  final PostgreSQLExecutionContext _ctx;
  _PgTx(this._ctx);

  @override
  Future<int> execute(String sql, {Map<String, dynamic>? params}) => _ctx.execute(sql, substitutionValues: params);

  @override
  Future<List<List>> query(String sql, {Map<String, dynamic>? params}) => _ctx.query(sql, substitutionValues: params);

  @override
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(sql, {Map<String, dynamic>? params}) => _ctx.mappedResultsQuery(sql, substitutionValues: params);  
}
