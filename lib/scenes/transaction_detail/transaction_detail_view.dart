import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'transaction_detail_view_model.dart';

/// "Lançamento": every field of one transaction, with a trash button that
/// deletes it and goes back to the list.
class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({required this.viewModel, super.key});

  final TransactionDetailViewModel viewModel;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
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
        title: 'Lançamento',
        actions: [
          IconButton(
            key: const Key('detail_delete'),
            tooltip: 'Excluir lançamento',
            onPressed: viewModel.canDelete ? viewModel.delete : null,
            icon: viewModel.isDeleting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
        body: _body(context, viewModel),
      ),
    );
  }

  Widget _body(BuildContext context, TransactionDetailViewModel viewModel) {
    if (viewModel.isLoading) return const StateView.loading();
    if (viewModel.errorMessage case final message?) {
      return StateView.error(message: message, onRetry: viewModel.start);
    }

    final (kind, tone) = switch (viewModel.kind) {
      DetailKind.income => (TransactionKind.income, MoneyTone.income),
      DetailKind.expense => (TransactionKind.expense, MoneyTone.expense),
      DetailKind.transfer => (TransactionKind.transfer, MoneyTone.neutral),
    };
    final muted = context.semanticColors.muted;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        const Gap.xl(),
        TransactionTile(
          kind: kind,
          title: viewModel.title,
          subtitle: viewModel.typeLabel,
          amount: viewModel.amount,
        ),
        const Gap.lg(),
        MoneyText(
          viewModel.amount,
          tone: tone,
          size: MoneySize.display,
          signed: true,
        ),
        const Gap.xl(),
        for (final row in viewModel.rows) _DetailRowView(row: row),
        const Gap.xl(),
        Text(
          viewModel.idLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _DetailRowView extends StatelessWidget {
  const _DetailRowView({required this.row});

  final DetailRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = context.semanticColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              row.label,
              style: textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          Expanded(
            child: Text(
              row.value,
              style: row.isPlaceholder
                  ? textTheme.bodyLarge?.copyWith(
                      color: muted,
                      fontStyle: FontStyle.italic,
                    )
                  : textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
