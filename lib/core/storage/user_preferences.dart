import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main()` with the instance loaded before the app starts.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Settings stored per user, keyed by email, like `UserPreferences.kt`.
/// New users start with nothing saved: no demo data is ever seeded here.
class UserPreferences {
  UserPreferences(this._prefs);

  static const String keyLastRole = 'last_role';

  final SharedPreferences _prefs;

  String _key(String email, String key) => 'user:${email.toLowerCase()}:$key';

  String? loadString(String email, String key) => _prefs.getString(_key(email, key));

  Future<void> saveString(String email, String key, String value) =>
      _prefs.setString(_key(email, key), value);
}

final userPreferencesProvider = Provider<UserPreferences>(
  (ref) => UserPreferences(ref.watch(sharedPreferencesProvider)),
);
