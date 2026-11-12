import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/user_preferences.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/registration_validator.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dni = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  DateTime? _birthdate;
  bool _acceptedTerms = false;
  bool _passwordHidden = true;
  bool _confirmHidden = true;
  bool _loading = false;
  RegistrationError? _error;
  AuthFailure? _failure;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _dni, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearError([Object? _]) {
    setState(() {
      _error = null;
      _failure = null;
    });
  }

  Future<void> _pickBirthdate() async {
    final today = DateTime.now();
    final latest = RegistrationValidator.latestBirthdate(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? latest,
      firstDate: RegistrationValidator.earliestBirthdate(today),
      lastDate: latest,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      _birthdate = picked;
      _clearError();
    }
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    final name = _name.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final dni = _dni.text.trim();
    final error = RegistrationValidator.validate(
      name: name,
      email: email,
      phone: phone,
      dni: dni,
      birthdate: _birthdate,
      password: _password.text,
      confirmPassword: _confirm.text,
      acceptedTerms: _acceptedTerms,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            email: email,
            phone: phone,
            dni: dni,
            // Same format the Kotlin app sends to the API.
            birthdate: DateFormat('dd MMM yyyy', 'en_US').format(_birthdate!),
            password: _password.text,
          );
      await ref
          .read(userPreferencesProvider)
          .saveString(email, UserPreferences.keyContactPhone, phone);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
      context.go(AppRoutes.login, extra: email);
    } on AuthException catch (e) {
      if (mounted) setState(() => _failure = e.failure);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _messageFor(AppLocalizations l10n, List<RegistrationError> fields) {
    final error = _error;
    if (error == null || !fields.contains(error)) return null;
    return switch (error) {
      RegistrationError.name => l10n.registerNameInvalid,
      RegistrationError.email => l10n.registerEmailInvalid,
      RegistrationError.phone => l10n.registerPhoneInvalid,
      RegistrationError.dni => l10n.registerDniInvalid,
      RegistrationError.birthdateRequired => l10n.registerBirthdateRequired,
      RegistrationError.birthdateInvalid => l10n.registerBirthdateInvalid,
      RegistrationError.password => l10n.registerPasswordInvalid,
      RegistrationError.passwordMismatch => l10n.registerPasswordMismatch,
      RegistrationError.terms => l10n.registerTermsRequired,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failureMessage = switch (_failure) {
      null => null,
      AuthFailure.network => l10n.loginNetworkError,
      _ => l10n.registerError,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeader(title: l10n.registerTitle, onBack: () => context.go(AppRoutes.login)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: AuthSheet(
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: l10n.registerName,
                          controller: _name,
                          onChanged: _clearError,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          error: _messageFor(l10n, [RegistrationError.name]),
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          label: l10n.loginEmail,
                          controller: _email,
                          onChanged: _clearError,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          error: _messageFor(l10n, [RegistrationError.email]),
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          label: l10n.registerPhone,
                          controller: _phone,
                          onChanged: _clearError,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumberNational],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          error: _messageFor(l10n, [RegistrationError.phone]),
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          label: l10n.registerDni,
                          controller: _dni,
                          onChanged: _clearError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                          error: _messageFor(l10n, [RegistrationError.dni]),
                        ),
                        const SizedBox(height: 12),
                        _BirthdateField(
                          label: l10n.registerBirthdate,
                          hint: l10n.registerBirthdateHint,
                          value: _birthdate,
                          onTap: _pickBirthdate,
                          error: _messageFor(l10n, [
                            RegistrationError.birthdateRequired,
                            RegistrationError.birthdateInvalid,
                          ]),
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          label: l10n.loginPassword,
                          controller: _password,
                          onChanged: _clearError,
                          obscureText: _passwordHidden,
                          onToggleObscure: () => setState(() => _passwordHidden = !_passwordHidden),
                          autofillHints: const [AutofillHints.newPassword],
                          error: _messageFor(l10n, [RegistrationError.password]),
                        ),
                        const SizedBox(height: 8),
                        _PasswordChecklist(password: _password.text),
                        const SizedBox(height: 12),
                        AuthTextField(
                          label: l10n.registerConfirmPassword,
                          controller: _confirm,
                          onChanged: _clearError,
                          obscureText: _confirmHidden,
                          onToggleObscure: () => setState(() => _confirmHidden = !_confirmHidden),
                          textInputAction: TextInputAction.done,
                          error: _messageFor(l10n, [RegistrationError.passwordMismatch]),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            _acceptedTerms = value ?? false;
                            _clearError();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: MuyuColors.lime,
                          checkColor: Colors.black,
                          side: const BorderSide(color: Colors.white, width: 2),
                          title: Text(
                            l10n.registerAcceptTerms,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        FieldError(_messageFor(l10n, [RegistrationError.terms])),
                        FieldError(failureMessage),
                        const SizedBox(height: 16),
                        AuthPrimaryButton(
                          text: l10n.registerButton,
                          loading: _loading,
                          onPressed: _register,
                        ),
                        const SizedBox(height: 16),
                        AuthSwitchPrompt(
                          question: l10n.registerHaveAccount,
                          action: l10n.loginTitle,
                          onPressed: () => context.go(AppRoutes.login),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthdateField extends StatelessWidget {
  const _BirthdateField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
    this.error,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final date = value;
    final text = date == null ? hint : MaterialLocalizations.of(context).formatMediumDate(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(label, style: MuyuTextStyles.sheetLabel)),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: '$label, $text',
          excludeSemantics: true,
          child: Material(
            color: MuyuColors.field,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: error == null ? Colors.black : MuyuColors.errorBorder,
                width: error == null ? 1 : 2,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          style: MuyuTextStyles.field.copyWith(
                            color: date == null ? Colors.black54 : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, color: MuyuColors.forest),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        FieldError(error),
      ],
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({required this.password});

  final String password;

  String _label(AppLocalizations l10n, PasswordRule rule) => switch (rule) {
    PasswordRule.length => l10n.registerRuleLength,
    PasswordRule.uppercase => l10n.registerRuleUppercase,
    PasswordRule.lowercase => l10n.registerRuleLowercase,
    PasswordRule.number => l10n.registerRuleNumber,
    PasswordRule.special => l10n.registerRuleSpecial,
    PasswordRule.noSpaces => l10n.registerRuleNoSpaces,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = RegistrationValidator.passwordRules(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: rule, value: met) in rules.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Semantics(
              label:
                  '${_label(l10n, rule)}, ${met ? l10n.registerRuleMet : l10n.registerRuleMissing}',
              excludeSemantics: true,
              child: Row(
                children: [
                  Icon(
                    met ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: met ? MuyuColors.lime : Colors.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _label(l10n, rule),
                      style: TextStyle(
                        fontSize: 13,
                        color: met ? Colors.white : Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
