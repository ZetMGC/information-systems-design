/// ### Контекст транзакции 
/// Позволяет работать с БД через единый контракт с `DbClient.transaction()`.
/// Выполняются в рамках одной транзакции. Не зависят от конкретного драйвера БД. 
abstract class DbTx {
  Future<int> execute(String sql, {Map<String, dynamic>? params});
  Future<List<List<dynamic>>> query(String sql, {Map<String, dynamic>? params});
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(String sql,
      {Map<String, dynamic>? params});
}

/// ### Абстрактный клиент БД
/// Базовые операции `query`, `mappedQuery`, `execute`, 
/// запуск транзакции `transaction` и получение скалярного int `scalarInt`
abstract class DbClient {
  Future<List<List<dynamic>>> query(String sql, {Map<String, dynamic>? params});
  Future<List<Map<String, Map<String, dynamic>>>> mappedQuery(String sql,
      {Map<String, dynamic>? params});
  Future<int> execute(String sql, {Map<String, dynamic>? params});

  Future<R> transaction<R>(Future<R> Function(DbTx tx) action);
  Future<int> scalarInt(String sql, {Map<String, dynamic>? params});
}
