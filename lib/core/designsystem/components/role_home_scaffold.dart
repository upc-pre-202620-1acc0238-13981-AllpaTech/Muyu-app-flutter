import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/user_management/application/session_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';
import 'language_toggle_button.dart';
import 'session_overflow_button.dart';

/// Starting point for each role's home until its real screens are ported.
/// It only shows an empty state: new users never get demo data.
class RoleHomeScaffold extends ConsumerWidget {
  const RoleHomeScaffold({super.key, required this.title, required this.emptyMessage});

  final String title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [LanguageToggleButton(), SessionOverflowButton()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user != null)
                Text(
                  l10n.homeGreeting(user.firstName.isEmpty ? user.email : user.firstName),
                  textAlign: TextAlign.center,
                  style: MuyuTextStyles.screenTitle.copyWith(fontSize: 26),
                ),
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/mascot_search.png',
                height: 180,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 24),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
