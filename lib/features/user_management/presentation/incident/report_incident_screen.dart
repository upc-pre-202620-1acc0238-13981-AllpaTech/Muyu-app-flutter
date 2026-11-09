import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The backend has no endpoint for incident reports yet, so this screen sends
/// the user to technical support instead of pretending to submit a form.
class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.reportTitle, onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.support_agent, size: 56, color: MuyuColors.forest),
                    const SizedBox(height: 16),
                    Text(
                      l10n.reportUnavailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          launchUrl(Uri(scheme: 'tel', path: l10n.profileSupportPhone)),
                      style: FilledButton.styleFrom(
                        backgroundColor: MuyuColors.action,
                        minimumSize: const Size(48, 52),
                      ),
                      icon: const Icon(Icons.call),
                      label: Text(l10n.profileCallSupport),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
