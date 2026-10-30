import 'package:flutter/widgets.dart';

import 'server_splash.dart';
import 'splash_coordinator.dart';
import 'splash_view.dart';
import 'splash_view_model.dart';

/// Assembles the splash scene, injecting its dependencies into the ViewModel.
abstract final class SplashFactory {
  static Widget make() {
    final viewModel = SplashViewModel(
      serverSplash: SplashServer(),
      coordinator: DefaultSplashCoordinator(),
    );
    return SplashView(viewModel: viewModel);
  }
}
