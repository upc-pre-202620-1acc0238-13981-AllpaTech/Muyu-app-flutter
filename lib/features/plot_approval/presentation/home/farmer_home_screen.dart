import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/role_home_scaffold.dart';
import '../../../../l10n/app_localizations.dart';

/// Farmer home (My plots). Plot listing and publishing come in a later feature.
class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleHomeScaffold(title: l10n.farmerHomeTitle, emptyMessage: l10n.farmerHomeEmpty);
  }
}
