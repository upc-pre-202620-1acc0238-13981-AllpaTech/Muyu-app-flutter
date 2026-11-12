import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';
import '../../domain/auth_repository.dart';
import '../password/reset_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  /// Prefilled after a successful registration.
  final String? initialEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  final _password = TextEditingController();
  bool _hidden = true;
  bool _loading = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      // The router moves on once the session changes.
      await ref.read(sessionProvider.notifier).login(_email.text.trim(), _password.text);
    } on AuthException catch (e) {
      if (mounted) setState(() => _failure = e.failure);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearError(String _) {
    if (_failure != null) setState(() => _failure = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = switch (_failure) {
      null => null,
      AuthFailure.network => l10n.loginNetworkError,
      _ => l10n.loginInvalid,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    AuthHeader(title: l10n.loginTitle),
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/images/login_hero.png',
                      height: 200,
                      semanticLabel: l10n.loginHero,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AuthSheet(
                        topPadding: 40,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                label: l10n.loginEmail,
                                controller: _email,
                                onChanged: _clearError,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                label: l10n.loginPassword,
                                controller: _password,
                                onChanged: _clearError,
                                prefixIcon: Icons.lock_outline,
                                obscureText: _hidden,
                                onToggleObscure: () => setState(() => _hidden = !_hidden),
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onSubmitted: (_) => _login(),
                              ),
                              FieldError(error),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) => ResetPasswordScreen(
                                        initialEmail: _email.text.trim(),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.loginForgotPassword,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AuthPrimaryButton(
                                text: l10n.loginButton,
                                loading: _loading,
                                loadingLabel: l10n.loginLoading,
                                onPressed: _login,
                              ),
                              const SizedBox(height: 16),
                              AuthSwitchPrompt(
                                question: l10n.loginNoAccount,
                                action: l10n.loginRegister,
                                onPressed: () => context.go(AppRoutes.register),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
