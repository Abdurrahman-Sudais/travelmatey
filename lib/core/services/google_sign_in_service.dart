import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travelmateeee/core/config/app_config.dart';

/// Result from the native Google account picker — sent to [AuthService.signInWithGoogle].
class GoogleSignInResult {
  final String credential;
  final Map<String, dynamic> userInfo;

  const GoogleSignInResult({
    required this.credential,
    required this.userInfo,
  });
}

/// Google Sign-In via the `google_sign_in` package.
///
/// Does **not** use Firebase Auth. The ID token is verified by your backend at
/// `POST /auth/google`.
class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignInService instance = GoogleSignInService._();

  GoogleSignIn? _client;

  GoogleSignIn get _googleSignIn {
    _client ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      // Web needs the Web OAuth client ID.
      clientId: kIsWeb ? AppConfig.googleSignInClientId : null,
      // Android/iOS need the Web client ID here to obtain an ID token for the API.
      // Web does not support serverClientId, so it must be null on Web.
      serverClientId: kIsWeb ? null : AppConfig.googleSignInServerClientId,
    );
    return _client!;
  }

  /// True when the minimum client IDs are set for the current platform.
  bool get isConfigured {
    if (kIsWeb) {
      return AppConfig.googleSignInClientId != null;
    }
    return AppConfig.googleSignInServerClientId != null;
  }

  /// Opens the Google account picker. Returns `null` if the user cancels.
  Future<GoogleSignInResult?> signIn() async {
    if (!isConfigured) {
      throw StateError(
        'Google Sign-In is not configured. Pass '
        '--dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=... (Android/iOS) or '
        '--dart-define=GOOGLE_SIGN_IN_CLIENT_ID=... (Web).',
      );
    }

    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final credential = auth.idToken ?? auth.accessToken;
    if (credential == null || credential.isEmpty) {
      throw StateError(
        'Google did not return a token. On Android, ensure SHA-1 is registered '
        'in Google Cloud / Firebase and GOOGLE_SIGN_IN_SERVER_CLIENT_ID is the '
        'Web OAuth client ID.',
      );
    }

    return GoogleSignInResult(
      credential: credential,
      userInfo: _userInfoFromAccount(account),
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Map<String, dynamic> _userInfoFromAccount(GoogleSignInAccount account) {
    final displayName = account.displayName ?? '';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final givenName = parts.isNotEmpty ? parts.first : '';
    final familyName =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return {
      'sub': account.id,
      'email': account.email,
      'name': displayName,
      'given_name': givenName,
      'family_name': familyName,
      'picture': account.photoUrl,
    };
  }
}
