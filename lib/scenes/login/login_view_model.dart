import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'login_coordinator.dart';
import 'server_login.dart';

/// State and actions of the login scene.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._serverLogin, required this._coordinator});

  final ServerLogin _serverLogin;
  final LoginCoordinator _coordinator;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;

  /// Message shown on the screen when the login fails; null hides it.
  String? get errorMessage => _errorMessage;

  void onEmailChanged(String value) {
    _email = value;
    _clearError();
  }

  void onPasswordChanged(String value) {
    _password = value;
    _clearError();
  }

  Future<void> submit() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _serverLogin.fetchLogin(
      email: _email,
      password: _password,
    );

    _isLoading = false;
    switch (result) {
      case Ok():
        notifyListeners();
        _coordinator.goToHome();
      case Failure(:final error):
        _errorMessage = error.message;
        notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
