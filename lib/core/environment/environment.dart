/// Where the app sends its HTTP requests.
///
/// Mirrors `Environment.kt` in the Kotlin app: the deployed Fake API on Render
/// is the default. Pass `--dart-define=MUYU_API_URL=...` to point the app at
/// another backend (for example the team's .NET API) without code changes.
class Environment {
  const Environment._();

  static const String fakeApiBaseUrl = 'https://muyu-fake-api.onrender.com/api/';

  static const String baseUrl = String.fromEnvironment(
    'MUYU_API_URL',
    defaultValue: fakeApiBaseUrl,
  );

  /// Render puts the free Fake API to sleep, so the first request can take
  /// close to a minute while it wakes up.
  static const Duration requestTimeout = Duration(seconds: 75);
}
