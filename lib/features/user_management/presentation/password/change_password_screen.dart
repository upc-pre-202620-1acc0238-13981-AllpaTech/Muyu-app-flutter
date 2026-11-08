import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';
import '../../domain/auth_repository.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _currentHidden = true;
  var _passwordHidden = true;
  var _confirmHidden = true;
  var _showMismatch = false;
  var _submitting = false;
  var _complete = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_password.text != _confirmation.text) {
      setState(() {
        _showMismatch = true;
        _error = null;
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).changePassword(_current.text, _password.text);
      if (!mounted) return;
      setState(() {
        _current.clear();
        _password.clear();
        _confirmation.clear();
        _complete = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = e.failure == AuthFailure.network ? l10n.loginNetworkError : l10n.passwordChangeFailed;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_complete) {
      return _PasswordComplete(onContinue: () => Navigator.of(context).pop());
    }

    final canSubmit =
        !_submitting && _current.text.trim().isNotEmpty && _password.text.length >= 8 && _confirmation.text.isNotEmpty;

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeader(title: l10n.passwordNewTitle, onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/pin_hero.png',
              height: 180,
              semanticLabel: l10n.passwordHeroDescription,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AuthSheet(
                child: ListView(
                  children: [
                    AuthTextField(
                      label: l10n.passwordCurrent,
                      controller: _current,
                      obscureText: _currentHidden,
                      onToggleObscure: () => setState(() => _currentHidden = !_currentHidden),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: l10n.loginPassword,
                      controller: _password,
                      obscureText: _passwordHidden,
                      onToggleObscure: () => setState(() => _passwordHidden = !_passwordHidden),
                      onChanged: (_) => setState(() => _showMismatch = false),
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: l10n.registerConfirmPassword,
                      controller: _confirmation,
                      obscureText: _confirmHidden,
                      onToggleObscure: () => setState(() => _confirmHidden = !_confirmHidden),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() => _showMismatch = false),
                      onSubmitted: (_) {
                        if (canSubmit) _submit();
                      },
                    ),
                    if (_showMismatch)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.passwordMismatch,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            color: MuyuColors.errorText,
                          ),
                        ),
                      ),
                    FieldError(_error),
                    const SizedBox(height: 16),
                    Text(
                      l10n.passwordRulesTitle,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '· ${l10n.passwordRuleLength}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                    ),
                    Text(
                      '· ${l10n.passwordRuleNumber}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                    ),
                    Text(
                      '· ${l10n.passwordRuleUppercase}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.passwordConfirmationHint,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    AuthPrimaryButton(
                      text: l10n.profileChangePassword,
                      loading: _submitting,
                      onPressed: canSubmit ? _submit : null,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordComplete extends StatelessWidget {
  const _PasswordComplete({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeader(title: l10n.passwordFlowCompleteTitle, onBack: onContinue),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/pin_hero.png',
              height: 180,
              semanticLabel: l10n.passwordHeroDescription,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AuthSheet(
                child: Column(
                  children: [
                    Text(
                      l10n.passwordFlowCompleteBody,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(text: l10n.passwordBackProfile, onPressed: onContinue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
