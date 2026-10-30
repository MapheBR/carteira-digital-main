import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'profile_coordinator.dart';
import 'server_profile.dart';

/// State and actions of the profile scene ("Perfil" tab).
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this._serverProfile, required this._coordinator});

  final ServerProfile _serverProfile;
  final ProfileCoordinator _coordinator;

  User? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoggingOut = false;
  String? _errorMessage;
  bool _disposed = false;

  // What the user is typing in the "Dados" form.
  String _nameInput = '';
  String _avatarUrlInput = '';
  String? _nameError;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _user != null;

  // Header: shows what is saved, not what is being typed.
  String get name => _user?.name ?? '';
  String get email => _user?.email ?? '';
  String? get avatarUrl => _user?.avatarUrl;
  String get memberSince => _user == null
      ? ''
      : 'Na Carteira desde ${formatDate(_user!.createdAt)}';

  // Form.
  String get nameInput => _nameInput;
  String get avatarUrlInput => _avatarUrlInput;
  String? get nameError => _nameError;

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> start() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _serverProfile.fetchProfile();
    _isLoading = false;
    switch (result) {
      case Ok(:final value):
        _setUser(value);
        notifyListeners();
      case Failure(error: UnauthorizedError()):
        await logout();
      case Failure(:final error):
        _errorMessage = error.message;
        notifyListeners();
    }
  }

  void onNameChanged(String value) {
    _nameInput = value;
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  void onAvatarUrlChanged(String value) => _avatarUrlInput = value;

  /// "Salvar": validates the name and sends name + photo to the server.
  Future<void> save() async {
    if (_isSaving) return;
    _nameError = validateRequired(_nameInput, field: 'O nome');
    if (_nameError != null) {
      notifyListeners();
      return;
    }

    _isSaving = true;
    notifyListeners();

    final avatar = _avatarUrlInput.trim();
    final result = await _serverProfile.updateProfile(
      name: _nameInput.trim(),
      avatarUrl: avatar.isEmpty ? null : avatar,
    );
    _isSaving = false;
    switch (result) {
      case Ok(:final value):
        _setUser(value);
        notifyListeners();
        _coordinator.showMessage('Perfil atualizado.');
      case Failure(error: UnauthorizedError()):
        await logout();
      case Failure(:final error):
        notifyListeners();
        _coordinator.showMessage(error.message);
    }
  }

  /// "Sair da conta".
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    notifyListeners();
    await _serverProfile.logout();
    _coordinator.goToLogin();
  }

  void _setUser(User user) {
    _user = user;
    _nameInput = user.name;
    _avatarUrlInput = user.avatarUrl ?? '';
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
