import 'package:carteira_core/carteira_core.dart';

import '../../app/app_dependencies.dart';

/// Backend of the profile scene.
abstract interface class ServerProfile {
  /// Signed-in user: `GET /me`.
  Future<Result<User>> fetchProfile();

  /// Saves name and photo: `PUT /me`.
  Future<Result<User>> updateProfile({required String name, String? avatarUrl});

  /// Ends the session on the server and clears the storage.
  Future<void> logout();
}

/// Real [ServerProfile], using the Core repositories.
class ProfileServer implements ServerProfile {
  ProfileServer({UserRepository? users, AuthRepository? auth})
    : _users = users ?? AppDependencies.users,
      _auth = auth ?? AppDependencies.auth;

  final UserRepository _users;
  final AuthRepository _auth;

  @override
  Future<Result<User>> fetchProfile() => _users.getProfile();

  @override
  Future<Result<User>> updateProfile({
    required String name,
    String? avatarUrl,
  }) => _users.updateProfile(name: name, avatarUrl: avatarUrl);

  @override
  Future<void> logout() async {
    await _auth.logout();
  }
}
