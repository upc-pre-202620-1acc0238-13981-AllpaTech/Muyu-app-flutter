import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Opens a draft in the email app, like Kotlin `openFarmerContact`. It never sends a message.
Future<void> openFarmerContact(BuildContext context, String email) async {
  final l10n = AppLocalizations.of(context);
  final recipient = email.trim();
  if (!_emailPattern.hasMatch(recipient)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.muyuContactMissing)));
    return;
  }
  final uri = Uri(scheme: 'mailto', path: recipient);
  try {
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.muyuContactUnavailable)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.muyuContactUnavailable)));
    }
  }
}
