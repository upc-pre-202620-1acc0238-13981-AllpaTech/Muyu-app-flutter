import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../i18n/app_language.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';

/// "EN" / "ES" pill that switches the app language, as in the Kotlin app.
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.languageToggleLabel,
      excludeSemantics: true,
      child: Material(
        color: MuyuColors.weatherChip,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref.read(appLanguageProvider.notifier).toggle(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                widthFactor: 1,
                child: Text(
                  l10n.languageCode,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
