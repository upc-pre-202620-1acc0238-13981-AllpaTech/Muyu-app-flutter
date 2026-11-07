import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';
import '../../domain/user.dart';

/// Picking a card only marks it; "Next" enters with the chosen role.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selected;

  Future<void> _next() async {
    final role = _selected;
    if (role == null) return;
    await ref.read(sessionProvider.notifier).chooseRole(role);
    if (mounted) context.go(AppRoutes.homeFor(role));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Image.asset(
                      'assets/images/muyu_logo.png',
                      height: 72,
                      semanticLabel: l10n.splashLogo,
                    ),
                  ),
                  const LanguageToggleButton(),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  l10n.roleQuestion,
                  textAlign: TextAlign.center,
                  style: MuyuTextStyles.screenTitle.copyWith(color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.roleSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                image: 'assets/images/role_farmer.png',
                imageLabel: l10n.roleFarmerImage,
                title: l10n.roleFarmerTitle,
                body: l10n.roleFarmerBody,
                selected: _selected == UserRole.farmer,
                onTap: () => setState(() => _selected = UserRole.farmer),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                image: 'assets/images/role_merchant.png',
                imageLabel: l10n.roleMerchantImage,
                title: l10n.roleMerchantTitle,
                body: l10n.roleMerchantBody,
                selected: _selected == UserRole.merchant,
                onTap: () => setState(() => _selected = UserRole.merchant),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                text: l10n.roleNext,
                background: MuyuColors.action,
                foreground: Colors.white,
                onPressed: _selected == null ? null : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.image,
    required this.imageLabel,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String image;
  final String imageLabel;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? MuyuColors.skip : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: MuyuColors.forest, width: selected ? 3 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(image, width: 67, height: 64, semanticLabel: imageLabel),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
