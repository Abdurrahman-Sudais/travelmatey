/// App-wide configuration.
///
/// BACKEND: Set [apiBaseUrl] to your staging/production server.
/// Consider loading from `--dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.travelmate.app/v1',
  );

  /// Flip to `false` once the real API is wired up.
  static const bool useMockRepositories = true;

  static const Duration apiTimeout = Duration(seconds: 30);
}
