import 'package:carteira_core/carteira_core.dart';

import '../../app/app_dependencies.dart';

/// Backend of the splash scene: is there a saved session?
abstract interface class ServerSplash {
  Future<bool> hasSession();
}

/// Real [ServerSplash]: reads the session from the storage through the Core.
class SplashServer implements ServerSplash {
  SplashServer({AuthRepository? auth}) : _auth = auth ?? AppDependencies.auth;

  final AuthRepository _auth;

  @override
  Future<bool> hasSession() async {
    final result = await _auth.restore();
    return result.valueOrNull != null;
  }
}
