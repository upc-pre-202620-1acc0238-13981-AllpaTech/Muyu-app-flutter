import 'package:flutter/material.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Shown while the saved session is restored; the router leaves it on its own.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/muyu_logo.png', width: 220, semanticLabel: l10n.splashLogo),
            const SizedBox(height: 16),
            Text(
              l10n.splashTagline,
              style: const TextStyle(
                fontFamily: MuyuFonts.fredoka,
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: MuyuColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
