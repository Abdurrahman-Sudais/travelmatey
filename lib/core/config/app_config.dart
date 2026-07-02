// Public keys only — safe to commit.
// Never add private/secret keys to this file.

/// App-wide configuration.
///
/// BACKEND: Set [baseUrl] to your staging/production server.
/// Consider loading from `--dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  AppConfig._();

  static const String mapboxPublicToken = 
    'pk.eyJ1IjoidHJhdmVsbWF0ZTIwMjYiLCJhIjoiY21wOGxxcHY2MDBhajJxc2R5Yjkzb2NlMCJ9.xOhkAs8y5HQyJvBk-cVIkQ';
    
  static const String paystackPublicKey = 
    'pk_live_a5e7b21dc32f662d5bdc1c935ae1d0f9cddb56f7';
    
  static const String baseUrl = 
    'https://travelmate-api-cdlq.onrender.com/api';

  /// Set to `true` only for offline UI development without a backend.
  static const bool useMockRepositories = true;

  static const Duration apiTimeout = Duration(seconds: 30);

  /// Web OAuth client from `android/app/google-services.json` (client_type 3).
  static const String _defaultGoogleWebClientId =
      '1859524642-71eomvpjh8mc37rk127d5qd7u8iloohe.apps.googleusercontent.com';

  static const String _googleSignInClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_CLIENT_ID',
    defaultValue: _defaultGoogleWebClientId,
  );
  static const String _googleSignInServerClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_SERVER_CLIENT_ID',
    defaultValue: _defaultGoogleWebClientId,
  );

  /// Optional OAuth client IDs for Google Sign-In.
  ///
  /// Web usually needs [googleSignInClientId]. Android can request an ID token
  /// for the backend/Firebase with [googleSignInServerClientId].
  static String? get googleSignInClientId =>
      _googleSignInClientId.isEmpty ? null : _googleSignInClientId;

  static String? get googleSignInServerClientId =>
      _googleSignInServerClientId.isEmpty
      ? googleSignInClientId
      : _googleSignInServerClientId;

  /// Whether Google OAuth client IDs are available at build time.
  static bool get isGoogleSignInConfigured =>
      googleSignInClientId != null || googleSignInServerClientId != null;
}
