import 'package:travelmateeee/core/services/auth_service.dart';

/// Backend response after `POST /auth/google`.
class GoogleAuthResult {
  final AuthUser user;
  final String token;
  final String refreshToken;
  final bool isNewUser;
  final bool needsOnboarding;

  const GoogleAuthResult({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.isNewUser,
    required this.needsOnboarding,
  });
}
