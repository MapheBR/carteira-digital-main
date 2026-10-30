import 'package:flutter/widgets.dart';

import 'server_transaction_detail.dart';
import 'transaction_detail_coordinator.dart';
import 'transaction_detail_view.dart';
import 'transaction_detail_view_model.dart';

/// Assembles the transaction detail scene for the transaction [id].
abstract final class TransactionDetailFactory {
  static Widget make(String id) {
    final viewModel = TransactionDetailViewModel(
      transactionId: id,
      serverDetail: TransactionDetailServer(),
      coordinator: DefaultTransactionDetailCoordinator(),
    );
    return TransactionDetailView(viewModel: viewModel);
  }
}
