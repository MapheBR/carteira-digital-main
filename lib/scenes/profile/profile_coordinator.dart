import '../../app/app_navigator.dart';
import '../login/login_factory.dart';

/// Navigation out of the profile scene.
abstract interface class ProfileCoordinator {
  void goToLogin();

  void showMessage(String message);
}

class DefaultProfileCoordinator implements ProfileCoordinator {
  @override
  void goToLogin() => replaceRoot(LoginFactory.make());

  @override
  void showMessage(String message) => showAppMessage(message);
}
