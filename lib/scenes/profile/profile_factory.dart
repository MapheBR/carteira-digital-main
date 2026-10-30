import 'package:flutter/widgets.dart';

import 'profile_coordinator.dart';
import 'profile_view.dart';
import 'profile_view_model.dart';
import 'server_profile.dart';

/// Assembles the profile scene, injecting its dependencies into the ViewModel.
abstract final class ProfileFactory {
  static Widget make() {
    final viewModel = ProfileViewModel(
      serverProfile: ProfileServer(),
      coordinator: DefaultProfileCoordinator(),
    );
    return ProfileView(viewModel: viewModel);
  }
}
