import '../../app/app_navigator.dart';

/// Navigation out of the transaction detail scene.
abstract interface class TransactionDetailCoordinator {
  /// Back to the list. [deleted] tells the list to reload.
  void close({bool deleted = false});

  void showMessage(String message);
}

class DefaultTransactionDetailCoordinator
    implements TransactionDetailCoordinator {
  @override
  void close({bool deleted = false}) =>
      appNavigatorKey.currentState?.pop(deleted);

  @override
  void showMessage(String message) => showAppMessage(message);
}
