import 'package:carteira_core/carteira_core.dart';

import '../../app/app_dependencies.dart';

/// Backend of the home scene.
abstract interface class ServerHome {
  /// Totals of [month] (`YYYY-MM`): `GET /summary`.
  Future<Result<Summary>> fetchSummary(String month);

  /// Transactions matching [filter]: `GET /transactions`.
  Future<Result<List<Transaction>>> fetchTransactions(TransactionFilter filter);

  /// Clears the saved session (used when the token is no longer valid).
  Future<void> clearSession();
}

/// Real [ServerHome], using the Core repositories.
class HomeServer implements ServerHome {
  HomeServer({TransactionRepository? transactions, AuthRepository? auth})
    : _transactions = transactions ?? AppDependencies.transactions,
      _auth = auth ?? AppDependencies.auth;

  final TransactionRepository _transactions;
  final AuthRepository _auth;

  @override
  Future<Result<Summary>> fetchSummary(String month) =>
      _transactions.summary(month);

  @override
  Future<Result<List<Transaction>>> fetchTransactions(
    TransactionFilter filter,
  ) async {
    final result = await _transactions.list(filter);
    return result.map((page) => page.items);
  }

  @override
  Future<void> clearSession() async {
    await _auth.logout();
  }
}
