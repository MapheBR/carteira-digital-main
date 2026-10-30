import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'home_coordinator.dart';
import 'server_home.dart';

/// Kind of a row in the list. Mirrors the design system's TransactionKind
/// so the ViewModel does not depend on Flutter widgets.
enum HomeItemKind { income, expense, transfer }

/// One month chip: `out/2026`.
typedef HomeMonth = ({String key, String label});

/// One "Por categoria" bar.
typedef HomeCategory = ({String label, String amount, double share});

/// One transaction row, already formatted for the screen.
typedef HomeItem = ({
  String id,
  HomeItemKind kind,
  String title,
  String subtitle,
  String amount,
});

/// Transactions of one day under a heading like "domingo, 27 de setembro".
typedef HomeDay = ({String heading, List<HomeItem> items});

/// State and actions of the home scene ("Lançamentos" tab).
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._serverHome,
    required this._coordinator,
    DateTime? now,
  }) : months = _lastMonths(now ?? DateTime.now(), count: 6) {
    _selectedMonth = months.first.key;
  }

  final ServerHome _serverHome;
  final HomeCoordinator _coordinator;
  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  /// Chips from the current month backwards.
  final List<HomeMonth> months;

  late String _selectedMonth;
  TransactionType? _type;
  String _query = '';
  int _tab = 0;

  bool _isLoading = false;
  String? _errorMessage;
  Summary? _summary;
  List<HomeCategory> _categories = const [];
  List<HomeDay> _days = const [];

  Timer? _searchDebounce;
  int _requestId = 0;
  bool _disposed = false;

  String get selectedMonth => _selectedMonth;
  TransactionType? get selectedType => _type;
  int get selectedTab => _tab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HomeCategory> get categories => _categories;
  List<HomeDay> get days => _days;

  String get monthLabel => formatMonthKey(_selectedMonth);
  String get balance => _money.format(_summary?.balance ?? 0);
  String get income => _money.format(_summary?.income ?? 0);
  String get expense => _money.format(_summary?.expense ?? 0);

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> start() => _loadMonth();

  Future<void> retry() => _loadMonth();

  void selectTab(int index) {
    _tab = index;
    notifyListeners();
  }

  void selectMonth(String key) {
    if (key == _selectedMonth) return;
    _selectedMonth = key;
    _loadMonth();
  }

  void selectType(TransactionType? type) {
    _type = type;
    _loadList();
  }

  void onQueryChanged(String value) {
    _query = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadList);
  }

  void onAddPressed() => _coordinator.goToNewTransaction();

  /// Row tapped: opens the detail. If it was deleted there, reload the month
  /// (list, balance and categories all change).
  Future<void> onTransactionTapped(String id) async {
    final deleted = await _coordinator.goToTransactionDetail(id);
    if (deleted) await _loadMonth();
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Month changed: summary + categories + list.
  Future<void> _loadMonth() async {
    final id = _begin();
    _summary = null;
    _categories = const [];
    _days = const [];
    notifyListeners();

    // The three calls run in parallel.
    final (summary, monthItems, listItems) = await (
      _serverHome.fetchSummary(_selectedMonth),
      // All transactions of the month, to build the categories.
      _serverHome.fetchTransactions(
        TransactionFilter(month: _selectedMonth, pageSize: 100),
      ),
      // The list below, with the type and search filters.
      _serverHome.fetchTransactions(_listFilter()),
    ).wait;
    if (id != _requestId) return; // a newer request already started

    final error =
        summary.errorOrNull ?? monthItems.errorOrNull ?? listItems.errorOrNull;
    if (error != null) return _fail(error);

    _summary = summary.valueOrNull;
    _categories = _buildCategories(monthItems.valueOrNull!);
    _days = _buildDays(listItems.valueOrNull!);
    _finish();
  }

  /// Type or search changed: only the list.
  Future<void> _loadList() async {
    final id = _begin();
    notifyListeners();

    final result = await _serverHome.fetchTransactions(_listFilter());
    if (id != _requestId) return;

    switch (result) {
      case Ok(:final value):
        _days = _buildDays(value);
        _finish();
      case Failure(:final error):
        _fail(error);
    }
  }

  TransactionFilter _listFilter() => TransactionFilter(
    month: _selectedMonth,
    type: _type,
    query: _query.isEmpty ? null : _query,
    pageSize: 100,
  );

  int _begin() {
    _isLoading = true;
    _errorMessage = null;
    return ++_requestId;
  }

  void _finish() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fail(AppError error) async {
    _isLoading = false;
    if (error is UnauthorizedError) {
      // Token saved but no longer valid (e.g. the server restarted).
      await _serverHome.clearSession();
      _coordinator.goToLogin();
      return;
    }
    _errorMessage = error.message;
    notifyListeners();
  }

  // ── Mapping Core models → screen data ────────────────────────────────────

  List<HomeCategory> _buildCategories(List<Transaction> items) {
    final expenses = items.whereType<Expense>().toList();
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    if (total == 0) return const [];

    final groups = groupBy(expenses, (t) => t.category ?? 'Sem categoria');
    final totals = [
      for (final entry in groups.entries)
        (
          label: entry.key,
          value: entry.value.fold<double>(0, (sum, t) => sum + t.amount),
        ),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final c in totals)
        (label: c.label, amount: _money.format(c.value), share: c.value / total),
    ];
  }

  List<HomeDay> _buildDays(List<Transaction> items) {
    final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));
    final groups = groupBy(sorted, (t) => t.date.dayStart);
    return [
      for (final entry in groups.entries)
        (
          heading: formatDayHeading(entry.key),
          items: [for (final t in entry.value) _item(t)],
        ),
    ];
  }

  HomeItem _item(Transaction t) => (
    id: t.id,
    kind: switch (t) {
      Income() => HomeItemKind.income,
      Expense() => HomeItemKind.expense,
      Transfer() => HomeItemKind.transfer,
    },
    title: t.description,
    subtitle: switch (t) {
      Transfer(:final account, :final toAccount) => '$account → $toAccount',
      _ => [?t.category, t.account].join(' · '),
    },
    amount: _money.format(t.amount),
  );

  static List<HomeMonth> _lastMonths(DateTime now, {required int count}) {
    return [
      for (var i = 0; i < count; i++)
        _month(DateTime(now.year, now.month - i).monthKey),
    ];
  }

  /// `2026-10` → (key: `2026-10`, label: `out/2026`).
  static HomeMonth _month(String key) {
    final name = formatMonthKey(key); // "outubro de 2026"
    return (key: key, label: '${name.substring(0, 3)}/${key.substring(0, 4)}');
  }

  /// Answers can arrive after the screen closed; ignore them then.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounce?.cancel();
    super.dispose();
  }
}
