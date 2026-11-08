/// Where the app sends its HTTP requests.
///
/// Mirrors `Environment.kt` in the Kotlin app: the team's deployed backend is
/// the default. Pass `--dart-define=MUYU_API_URL=...` to point the app at a
/// local backend without code changes.
class Environment {
  const Environment._();

  static const String backendBaseUrl = 'https://muyu-backend-production.up.railway.app/api/v1/';

  static const String baseUrl = String.fromEnvironment(
    'MUYU_API_URL',
    defaultValue: backendBaseUrl,
  );

  /// Same limit the Kotlin app gives its HTTP client.
  static const Duration requestTimeout = Duration(seconds: 90);
}
