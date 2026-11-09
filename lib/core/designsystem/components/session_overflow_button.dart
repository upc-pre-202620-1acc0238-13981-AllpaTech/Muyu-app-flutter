import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/user_management/application/session_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/app_routes.dart';
import '../../theme/muyu_colors.dart';

/// Three-dot menu for change-role and log-out, shared by role homes.
class SessionOverflowButton extends ConsumerWidget {
  const SessionOverflowButton({super.key, this.iconColor = MuyuColors.forest, this.iconSize = 28});

  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider.notifier);

    return PopupMenuButton<VoidCallback>(
      tooltip: l10n.homeMoreOptions,
      iconSize: iconSize,
      icon: Icon(Icons.more_vert, color: iconColor, size: iconSize),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: () {
            session.clearRole();
            context.go(AppRoutes.role);
          },
          child: ListTile(leading: const Icon(Icons.swap_horiz), title: Text(l10n.homeChangeRole)),
        ),
        PopupMenuItem(
          value: session.logout,
          child: ListTile(leading: const Icon(Icons.logout), title: Text(l10n.homeLogout)),
        ),
      ],
    );
  }
}
