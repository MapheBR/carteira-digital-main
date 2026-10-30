import 'package:carteira_core/carteira_core.dart' show TransactionType;
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../../app/theme_mode_button.dart';
import 'home_view_model.dart';

/// Home: "Lançamentos" tab (month, balance, categories, filters and list)
/// and "Perfil" tab, switched by the bottom navigation bar.
class HomeView extends StatefulWidget {
  const HomeView({required this.viewModel, required this.profile, super.key});

  final HomeViewModel viewModel;

  /// The profile scene, already assembled by its own factory.
  final Widget profile;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.start();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AppScaffold(
        title: viewModel.selectedTab == 0 ? 'Carteira' : 'Perfil',
        actions: viewModel.selectedTab == 0
            ? const [ThemeModeButton()]
            : null,
        padded: false,
        // IndexedStack keeps each tab alive (scroll, search text).
        body: IndexedStack(
          index: viewModel.selectedTab,
          children: [_TransactionsTab(viewModel: viewModel), widget.profile],
        ),
        floatingActionButton: viewModel.selectedTab == 0
            ? FloatingActionButton(
                key: const Key('home_add'),
                tooltip: 'Novo lançamento',
                onPressed: viewModel.onAddPressed,
                child: const Icon(Icons.add),
              )
            : null,
        bottom: NavigationBar(
          selectedIndex: viewModel.selectedTab,
          onDestinationSelected: viewModel.selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Lançamentos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Fixed number of children, so the search field keeps its text while
    // the sections around it change.
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _MonthChips(viewModel: viewModel),
        _padded(
          BalanceCard(
            balance: viewModel.balance,
            income: viewModel.income,
            expense: viewModel.expense,
            monthLabel: viewModel.monthLabel,
          ),
        ),
        _padded(_Categories(categories: viewModel.categories)),
        _padded(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: AppTextField(
              key: const Key('home_search'),
              label: 'Buscar por descrição',
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: viewModel.onQueryChanged,
            ),
          ),
        ),
        _padded(_TypeFilter(viewModel: viewModel)),
        _List(viewModel: viewModel),
      ],
    );
  }
}

Widget _padded(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  child: child,
);

class _MonthChips extends StatelessWidget {
  const _MonthChips({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.sm,
        ),
        itemCount: viewModel.months.length,
        separatorBuilder: (_, _) => const Gap.sm(),
        itemBuilder: (context, index) {
          final month = viewModel.months[index];
          return ChoiceChip(
            label: Text(month.label),
            selected: month.key == viewModel.selectedMonth,
            onSelected: (_) => viewModel.selectMonth(month.key),
          );
        },
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.categories});

  final List<HomeCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Por categoria'),
        for (final c in categories)
          CategoryBar(label: c.label, amount: c.amount, share: c.share),
      ],
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      // null = "Todos".
      child: SegmentedButton<TransactionType?>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: null, label: Text('Todos')),
          ButtonSegment(value: TransactionType.income, label: Text('Receita')),
          ButtonSegment(value: TransactionType.expense, label: Text('Despesa')),
          ButtonSegment(value: TransactionType.transfer, label: Text('Transf.')),
        ],
        selected: {viewModel.selectedType},
        onSelectionChanged: (selection) => viewModel.selectType(selection.first),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.errorMessage case final message?) {
      return StateView.error(message: message, onRetry: viewModel.retry);
    }
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: StateView.loading(),
      );
    }
    if (viewModel.days.isEmpty) {
      return const StateView.empty(message: 'Nenhum lançamento encontrado.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in viewModel.days) ...[
          _padded(SectionHeader(title: day.heading)),
          for (final item in day.items)
            TransactionTile(
              kind: switch (item.kind) {
                HomeItemKind.income => TransactionKind.income,
                HomeItemKind.expense => TransactionKind.expense,
                HomeItemKind.transfer => TransactionKind.transfer,
              },
              title: item.title,
              subtitle: item.subtitle,
              amount: item.amount,
              onTap: () => viewModel.onTransactionTapped(item.id),
            ),
        ],
      ],
    );
  }
}
