import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/user_management/domain/registration_validator.dart';

void main() {
  final today = DateTime(2026, 11, 7);

  RegistrationError? validate({
    String name = 'María Quispe',
    String email = 'maria@gmail.com',
    String phone = '987123456',
    String dni = '12345678',
    DateTime? birthdate,
    bool noBirthdate = false,
    String password = 'Muyu*2026',
    String? confirm,
    bool terms = true,
  }) => RegistrationValidator.validate(
    name: name,
    email: email,
    phone: phone,
    dni: dni,
    birthdate: noBirthdate ? null : (birthdate ?? DateTime(2000, 5, 3)),
    password: password,
    confirmPassword: confirm ?? password,
    acceptedTerms: terms,
    today: today,
  );

  test('accepts a complete, valid form', () => expect(validate(), isNull));

  test('checks fields in the same order as the Kotlin app', () {
    expect(validate(name: 'M'), RegistrationError.name);
    expect(validate(email: 'maria@'), RegistrationError.email);
    expect(validate(phone: '887123456'), RegistrationError.phone);
    expect(validate(dni: '1234567'), RegistrationError.dni);
    expect(validate(noBirthdate: true), RegistrationError.birthdateRequired);
    expect(validate(password: 'muyu2026'), RegistrationError.password);
    expect(validate(confirm: 'Other*2026'), RegistrationError.passwordMismatch);
    expect(validate(terms: false), RegistrationError.terms);
  });

  test('only allows people between 18 and 90 years old', () {
    expect(validate(birthdate: DateTime(2008, 11, 7)), isNull);
    expect(validate(birthdate: DateTime(2008, 11, 8)), RegistrationError.birthdateInvalid);
    expect(validate(birthdate: DateTime(1936, 11, 7)), isNull);
    expect(validate(birthdate: DateTime(1936, 11, 6)), RegistrationError.birthdateInvalid);
  });

  test('password checklist reports each rule', () {
    final rules = RegistrationValidator.passwordRules('abc 1');
    expect(rules[PasswordRule.length], isFalse);
    expect(rules[PasswordRule.uppercase], isFalse);
    expect(rules[PasswordRule.lowercase], isTrue);
    expect(rules[PasswordRule.number], isTrue);
    expect(rules[PasswordRule.special], isFalse);
    expect(rules[PasswordRule.noSpaces], isFalse);
  });
}
