import 'package:carteira_core/carteira_core.dart';

import '../../app/app_dependencies.dart';

/// Authentication backend used by the login scene.
abstract interface class ServerLogin {
  Future<Result<void>> fetchLogin({
    required String email,
    required String password,
  });
}

/// Offline [ServerLogin] for development and previews.
class LoginMockServer implements ServerLogin {
  static const email = 'ana@carteira.dev';
  static const password = '123456';
  final Duration delay;

  const LoginMockServer({this.delay = const Duration(milliseconds: 2000)});

  @override
  Future<Result<void>> fetchLogin({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);

    if (email.isEmpty || password.isEmpty) {
      return const Failure(ValidationError({}, detail: 'Campos vazios'));
    }

    if (email != LoginMockServer.email ||
        password != LoginMockServer.password) {
      return const Failure(UnauthorizedError(invalidCredentials: true));
    }
    return const Ok(null);
  }
}

/// Real [ServerLogin]: uses the Core's [AuthRepository], which calls
/// `POST /auth/login` and saves the session (token) in the storage.
class LoginServer implements ServerLogin {
  LoginServer({AuthRepository? auth}) : _auth = auth ?? AppDependencies.auth;

  final AuthRepository _auth;

  @override
  Future<Result<void>> fetchLogin({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const Failure(
        ValidationError({}, detail: 'Preencha e-mail e senha.'),
      );
    }

    final result = await _auth.login(email: email, password: password);
    return result.map((_) {});
  }
}
