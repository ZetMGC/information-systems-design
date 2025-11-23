
import 'package:information_systems_design/infrastructure/db/app_db.dart';
import 'package:information_systems_design/infrastructure/db/db_client.dart';
import 'package:postgres/postgres.dart';

class PgDbClientAdapter implements DbClient {
  final AppDb _db;

  PgDbClientAdapter(this._db);

  @override
  Future<int> execute(String sql, {Map<String, dynamic>? params}) => _db.execute(sql, params: params);

  @override
  Future<List<List>> query(String sql, {Map<String, dynamic>? params}) => _db.query(sql, params: params);

  @override
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(String sql, {Map<String, dynamic>? params}) => _db.mappedQuery(sql, params: params);

  @override
  Future<R> transaction<R>(Future<R> Function(DbTx tx) action) => _db.transaction<R>(action);

  @override
  Future<int> scalarInt(String sql, {Map<String, dynamic>? params}) => _db.scalarInt(sql, params: params);
}