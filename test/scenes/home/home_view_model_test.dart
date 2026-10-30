import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/home/home_coordinator.dart';
import 'package:carteira_digital/scenes/home/home_view_model.dart';
import 'package:carteira_digital/scenes/home/server_home.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeServerHome implements ServerHome {
  _FakeServerHome({this.fail});

  final AppError? fail;
  final filters = <TransactionFilter>[];
  bool cleared = false;

  static final _items = <Transaction>[
    Expense(
      id: '1',
      amount: 300,
      description: 'Aluguel',
      date: DateTime(2026, 9, 5, 10),
      account: 'Itaú',
      category: 'Moradia',
    ),
    Expense(
      id: '2',
      amount: 100,
      description: 'Mercado',
      date: DateTime(2026, 9, 6, 10),
      account: 'Nubank',
    ),
    Transfer(
      id: '3',
      amount: 50,
      description: 'Reserva',
      date: DateTime(2026, 9, 6, 12),
      account: 'Itaú',
      toAccount: 'Nubank',
    ),
  ];

  @override
  Future<Result<Summary>> fetchSummary(String month) async => fail != null
      ? Failure(fail!)
      : Ok(Summary(month: month, income: 1000, expense: 400));

  @override
  Future<Result<List<Transaction>>> fetchTransactions(
    TransactionFilter filter,
  ) async {
    filters.add(filter);
    return fail != null ? Failure(fail!) : Ok(_items);
  }

  @override
  Future<void> clearSession() async => cleared = true;
}

class _FakeHomeCoordinator implements HomeCoordinator {
  int loginCalls = 0;

  @override
  void goToLogin() => loginCalls++;

  @override
  void goToNewTransaction() {}

  @override
  Future<bool> goToTransactionDetail(String id) async => false;
}

void main() {
  test('builds months, summary, categories and day groups', () async {
    final viewModel = HomeViewModel(
      serverHome: _FakeServerHome(),
      coordinator: _FakeHomeCoordinator(),
      now: DateTime(2026, 9, 15),
    );
    await viewModel.start();

    expect(viewModel.months.first.label, 'set/2026');
    expect(viewModel.months[1].label, 'ago/2026');
    expect(viewModel.monthLabel, 'setembro de 2026');
    expect(viewModel.isLoading, isFalse);

    // Categories only count expenses; no category → "Sem categoria".
    expect(viewModel.categories.map((c) => c.label), [
      'Moradia',
      'Sem categoria',
    ]);
    expect(viewModel.categories.first.share, 0.75);

    // Newest day first.
    expect(viewModel.days.first.heading, 'domingo, 6 de setembro');
    expect(viewModel.days.first.items.first.subtitle, 'Itaú → Nubank');
    expect(viewModel.days.last.items.single.subtitle, 'Moradia · Itaú');
  });

  test('type filter goes to the API', () async {
    final server = _FakeServerHome();
    final viewModel = HomeViewModel(
      serverHome: server,
      coordinator: _FakeHomeCoordinator(),
      now: DateTime(2026, 9, 15),
    );
    await viewModel.start();
    viewModel.selectType(TransactionType.expense);
    await Future<void>.delayed(Duration.zero);

    expect(server.filters.last.type, TransactionType.expense);
    expect(server.filters.last.month, '2026-09');
  });

  test('expired token clears the session and goes to login', () async {
    final server = _FakeServerHome(fail: const UnauthorizedError());
    final coordinator = _FakeHomeCoordinator();
    final viewModel = HomeViewModel(
      serverHome: server,
      coordinator: coordinator,
      now: DateTime(2026, 9, 15),
    );
    await viewModel.start();

    expect(server.cleared, isTrue);
    expect(coordinator.loginCalls, 1);
  });
}
