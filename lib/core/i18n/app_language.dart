import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/user_preferences.dart';

/// Languages offered by Muyu: English (default) and Latin American Spanish.
enum AppLanguage {
  english(Locale('en')),
  spanishLatin(Locale.fromSubtags(languageCode: 'es', countryCode: '419'));

  const AppLanguage(this.locale);

  final Locale locale;

  AppLanguage get toggled =>
      this == AppLanguage.english ? AppLanguage.spanishLatin : AppLanguage.english;

  static AppLanguage fromName(String? name) => AppLanguage.values.firstWhere(
    (language) => language.name == name,
    orElse: () => AppLanguage.english,
  );
}

/// Current app language, remembered between launches.
class AppLanguageController extends Notifier<AppLanguage> {
  static const String _key = 'app_language';

  @override
  AppLanguage build() => AppLanguage.fromName(ref.watch(sharedPreferencesProvider).getString(_key));

  void toggle() {
    state = state.toggled;
    ref.read(sharedPreferencesProvider).setString(_key, state.name);
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageController, AppLanguage>(
  AppLanguageController.new,
);
