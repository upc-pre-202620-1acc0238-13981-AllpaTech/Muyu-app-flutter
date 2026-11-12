import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});
  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _email = TextEditingController(text: widget.initialEmail);
  bool _invalid = false;
  bool _complete = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continue() {
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim());
    setState(() {
      _invalid = !valid;
      if (valid) _complete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeader(title: l10n.resetTitle, onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/pin_hero.png',
              height: 190,
              semanticLabel: l10n.passwordHeroDescription,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AuthSheet(
                child: ListView(
                  children: _complete
                      ? [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 70,
                            color: MuyuColors.lime,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.resetSentTitle,
                            textAlign: TextAlign.center,
                            style: MuyuTextStyles.headerTitle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.resetSentBody(_email.text.trim()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.resetDemoNotice,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: .75)),
                          ),
                          const SizedBox(height: 28),
                          AuthPrimaryButton(
                            text: l10n.resetBackLogin,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ]
                      : [
                          Text(
                            l10n.resetHeading,
                            textAlign: TextAlign.center,
                            style: MuyuTextStyles.headerTitle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.resetBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 28),
                          AuthTextField(
                            label: l10n.resetEmailPrompt,
                            controller: _email,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            error: _invalid ? l10n.resetInvalidEmail : null,
                            onChanged: (_) => setState(() => _invalid = false),
                            onSubmitted: (_) => _continue(),
                          ),
                          const SizedBox(height: 22),
                          AuthPrimaryButton(text: l10n.resetNext, onPressed: _continue),
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
