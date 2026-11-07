import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/role_home_scaffold.dart';
import '../../../../l10n/app_localizations.dart';

/// Merchant home (plot catalog). Catalog and funding come in a later feature.
class MerchantCatalogScreen extends StatelessWidget {
  const MerchantCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleHomeScaffold(title: l10n.merchantHomeTitle, emptyMessage: l10n.merchantHomeEmpty);
  }
}
