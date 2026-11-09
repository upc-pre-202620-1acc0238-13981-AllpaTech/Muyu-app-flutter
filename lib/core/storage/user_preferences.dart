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
  static const String keyAlertChannel = 'alert_channel';
  static const String keyCompanyLegalName = 'company_legal_name';
  static const String keyCompanyActivity = 'company_activity';
  static const String keyCompanyRuc = 'company_ruc';
  static const String keyCompanyLocation = 'company_location';
  static const String keyCompanyEmail = 'company_email';
  static const String keyMerchantBankCard = 'merchant_bank_card';
  static const String keyMerchantWallet = 'merchant_wallet';
  static const String keyYapeAccount = 'yape_account';
  static const String keyPlinAccount = 'plin_account';
  static const String keyContactPhone = 'contact_phone';
  static const String keyContactEmail = 'contact_email';
  static const String keySyncWifiOnly = 'sync_wifi_only';

  final SharedPreferences _prefs;

  String _key(String email, String key) => 'user:${email.toLowerCase()}:$key';

  String? loadString(String email, String key) => _prefs.getString(_key(email, key));

  Future<void> saveString(String email, String key, String value) =>
      _prefs.setString(_key(email, key), value);

  Future<void> remove(String email, String key) => _prefs.remove(_key(email, key));

  bool? loadBool(String email, String key) => _prefs.getBool(_key(email, key));

  Future<void> saveBool(String email, String key, bool value) =>
      _prefs.setBool(_key(email, key), value);
}

final userPreferencesProvider = Provider<UserPreferences>(
  (ref) => UserPreferences(ref.watch(sharedPreferencesProvider)),
);
