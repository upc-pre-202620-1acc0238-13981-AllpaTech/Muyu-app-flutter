/// Registration rules, ported 1:1 from `RegisterScreen.kt`.
enum RegistrationError {
  name,
  email,
  phone,
  birthdateRequired,
  birthdateInvalid,
  password,
  passwordMismatch,
  terms,
}

enum PasswordRule { length, uppercase, lowercase, number, special, noSpaces }

abstract final class RegistrationValidator {
  static const int minimumAge = 18;
  static const int maximumAge = 90;

  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9._%+-]{0,62}[A-Za-z0-9])?@'
    r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z]{2,})+$',
  );
  static final RegExp _name = RegExp(r"^\p{L}[\p{L} .'-]{1,59}$", unicode: true);

  /// Peruvian mobile numbers: 9 digits starting with 9.
  static final RegExp _phone = RegExp(r'^9\d{8}$');

  /// The same rules drive validation and the checklist under the password.
  static Map<PasswordRule, bool> passwordRules(String password) => {
    PasswordRule.length: password.length >= 8,
    PasswordRule.uppercase: password.contains(RegExp(r'\p{Lu}', unicode: true)),
    PasswordRule.lowercase: password.contains(RegExp(r'\p{Ll}', unicode: true)),
    PasswordRule.number: password.contains(RegExp(r'\d')),
    PasswordRule.special: password.contains(RegExp(r'[^\p{L}\p{N}\s]', unicode: true)),
    PasswordRule.noSpaces: password.isNotEmpty && !password.contains(RegExp(r'\s')),
  };

  /// Latest and earliest birthdates allowed on [today].
  static DateTime latestBirthdate(DateTime today) =>
      DateTime(today.year - minimumAge, today.month, today.day);

  static DateTime earliestBirthdate(DateTime today) =>
      DateTime(today.year - maximumAge, today.month, today.day);

  /// Returns the first problem found, or null when the form is valid.
  static RegistrationError? validate({
    required String name,
    required String email,
    required String phone,
    required DateTime? birthdate,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
    DateTime? today,
  }) {
    if (!_name.hasMatch(name)) return RegistrationError.name;
    if (!_email.hasMatch(email)) return RegistrationError.email;
    if (!_phone.hasMatch(phone)) return RegistrationError.phone;
    if (birthdate == null) return RegistrationError.birthdateRequired;

    final now = today ?? DateTime.now();
    final day = DateTime(birthdate.year, birthdate.month, birthdate.day);
    if (day.isBefore(earliestBirthdate(now)) || day.isAfter(latestBirthdate(now))) {
      return RegistrationError.birthdateInvalid;
    }
    if (passwordRules(password).containsValue(false)) return RegistrationError.password;
    if (password != confirmPassword) return RegistrationError.passwordMismatch;
    if (!acceptedTerms) return RegistrationError.terms;
    return null;
  }
}
