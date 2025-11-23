abstract class DbTx {
  Future<int> execute(String sql, {Map<String, dynamic>? params});
  Future<List<List<dynamic>>> query(String sql, {Map<String, dynamic>? params});
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(sql, {Map<String,dynamic>? params});
}

abstract class DbClient {
  Future<List<List<dynamic>>> query(String sql, {Map<String, dynamic>? params});
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(String sql, {Map<String, dynamic>? params});
  Future<int> execute(String sql, {Map<String, dynamic>? params});

  Future<R> transaction<R>(Future<R> Function(DbTx tx) action);
  Future<int> scalarInt(String sql, {Map<String, dynamic>? params});
}