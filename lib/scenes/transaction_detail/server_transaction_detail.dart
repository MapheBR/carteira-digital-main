import 'package:carteira_core/carteira_core.dart';

import '../../app/app_dependencies.dart';

/// Backend of the transaction detail scene.
abstract interface class ServerTransactionDetail {
  /// One transaction: `GET /transactions/:id`.
  Future<Result<Transaction>> fetchTransaction(String id);

  /// Removes the transaction: `DELETE /transactions/:id`.
  Future<Result<void>> deleteTransaction(String id);
}

/// Real [ServerTransactionDetail], using the Core repositories.
class TransactionDetailServer implements ServerTransactionDetail {
  TransactionDetailServer({TransactionRepository? transactions})
    : _transactions = transactions ?? AppDependencies.transactions;

  final TransactionRepository _transactions;

  @override
  Future<Result<Transaction>> fetchTransaction(String id) =>
      _transactions.getById(id);

  @override
  Future<Result<void>> deleteTransaction(String id) =>
      _transactions.delete(id);
}
