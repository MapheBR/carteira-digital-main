import '../../app/app_navigator.dart';
import '../home/home_factory.dart';

/// Navigation out of the login scene.
abstract interface class LoginCoordinator {
  void goToHome();
}

class DefaultLoginCoordinator implements LoginCoordinator {
  @override
  void goToHome() => replaceRoot(HomeFactory.make());
}
