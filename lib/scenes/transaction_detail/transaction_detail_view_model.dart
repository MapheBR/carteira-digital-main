import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'server_transaction_detail.dart';
import 'transaction_detail_coordinator.dart';

/// Kind of the transaction shown. Mirrors the design system's TransactionKind
/// so the ViewModel does not depend on Flutter widgets.
enum DetailKind { income, expense, transfer }

/// One "label → value" line ("Data", "Conta"...). [isPlaceholder] marks a
/// value the user did not fill in, like "Sem observação".
typedef DetailRow = ({String label, String value, bool isPlaceholder});

/// State and actions of the transaction detail scene.
class TransactionDetailViewModel extends ChangeNotifier {
  TransactionDetailViewModel({
    required this.transactionId,
    required this._serverDetail,
    required this._coordinator,
  });

  final String transactionId;
  final ServerTransactionDetail _serverDetail;
  final TransactionDetailCoordinator _coordinator;
  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  Transaction? _transaction;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  /// The trash button only works once the transaction is on screen.
  bool get canDelete => _transaction != null && !_isDeleting;

  DetailKind get kind => switch (_transaction) {
    Income() => DetailKind.income,
    Transfer() => DetailKind.transfer,
    _ => DetailKind.expense,
  };

  String get title => _transaction?.description ?? '';

  String get typeLabel => switch (_transaction) {
    Income() => 'Receita',
    Expense() => 'Despesa',
    Transfer() => 'Transferência',
    null => '',
  };

  String get amount => _money.format(_transaction?.amount ?? 0);

  String get idLabel => 'ID $transactionId';

  List<DetailRow> get rows {
    final t = _transaction;
    if (t == null) return const [];
    return [
      (label: 'Data', value: formatDateTime(t.date), isPlaceholder: false),
      (label: 'Conta', value: t.account, isPlaceholder: false),
      if (t case Transfer(:final toAccount))
        (label: 'Destino', value: toAccount, isPlaceholder: false),
      _optional('Categoria', t.category, 'Sem categoria'),
      _optional('Observação', t.note, 'Sem observação'),
    ];
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> start() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _serverDetail.fetchTransaction(transactionId);
    _isLoading = false;
    switch (result) {
      case Ok(:final value):
        _transaction = value;
      case Failure(:final error):
        _errorMessage = error.message;
    }
    notifyListeners();
  }

  /// Trash button: deletes and goes back to the list.
  Future<void> delete() async {
    if (!canDelete) return;
    _isDeleting = true;
    notifyListeners();

    final result = await _serverDetail.deleteTransaction(transactionId);
    _isDeleting = false;
    switch (result) {
      case Ok():
        _coordinator.close(deleted: true);
        _coordinator.showMessage('Lançamento excluído.');
      case Failure(:final error):
        notifyListeners();
        _coordinator.showMessage(error.message);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static DetailRow _optional(String label, String? value, String empty) {
    final text = value?.trim() ?? '';
    return text.isEmpty
        ? (label: label, value: empty, isPlaceholder: true)
        : (label: label, value: text, isPlaceholder: false);
  }

  /// Answers can arrive after the screen closed; ignore them then.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
