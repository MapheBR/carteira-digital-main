import '../../app/app_navigator.dart';
import '../home/home_factory.dart';
import '../login/login_factory.dart';

/// Navigation out of the splash scene.
abstract interface class SplashCoordinator {
  void goToLogin();
  void goToHome();
}

class DefaultSplashCoordinator implements SplashCoordinator {
  @override
  void goToLogin() => replaceRoot(LoginFactory.make());

  @override
  void goToHome() => replaceRoot(HomeFactory.make());
}
