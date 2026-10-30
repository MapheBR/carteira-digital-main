import 'package:flutter/widgets.dart';

import '../profile/profile_factory.dart';
import 'home_coordinator.dart';
import 'home_view.dart';
import 'home_view_model.dart';
import 'server_home.dart';

/// Assembles the home scene, injecting its dependencies into the ViewModel.
/// The "Perfil" tab is its own scene, built by [ProfileFactory].
abstract final class HomeFactory {
  static Widget make() {
    final viewModel = HomeViewModel(
      serverHome: HomeServer(),
      coordinator: DefaultHomeCoordinator(),
    );
    return HomeView(viewModel: viewModel, profile: ProfileFactory.make());
  }
}
