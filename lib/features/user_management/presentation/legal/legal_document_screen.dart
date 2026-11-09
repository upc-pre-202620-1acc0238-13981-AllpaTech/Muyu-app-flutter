import 'package:flutter/material.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/legal_copy.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LegalDocumentScreen(
      title: l10n.profileTerms,
      sections: LegalCopy.terms(Localizations.localeOf(context)),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LegalDocumentScreen(
      title: l10n.profilePrivacy,
      sections: LegalCopy.privacy(Localizations.localeOf(context)),
    );
  }
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.title, required this.sections});

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          ColoredBox(
            color: MuyuColors.navBar,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: l10n.back,
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Text(l10n.legalUpdated, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 14),
                for (final section in sections) ...[
                  _LegalSection(section),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: MuyuColors.olive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      l10n.legalUnderstood,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection(this.section);

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Color(0xFF245B27),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: const TextStyle(fontSize: 15, height: 21 / 15, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
