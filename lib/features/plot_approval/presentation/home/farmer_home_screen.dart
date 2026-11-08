import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user_management/application/session_controller.dart';
import '../myplots/my_plots_view.dart';

/// Farmer home: the farmer's plots, with language and session actions.
class FarmerHomeScreen extends ConsumerWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.farmerHomeTitle),
        actions: [
          const LanguageToggleButton(),
          PopupMenuButton<VoidCallback>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () {
                  session.clearRole();
                  context.go(AppRoutes.role);
                },
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(l10n.homeChangeRole),
                ),
              ),
              PopupMenuItem(
                value: session.logout,
                child: ListTile(leading: const Icon(Icons.logout), title: Text(l10n.homeLogout)),
              ),
            ],
          ),
        ],
      ),
      body: const MyPlotsView(),
    );
  }
}
