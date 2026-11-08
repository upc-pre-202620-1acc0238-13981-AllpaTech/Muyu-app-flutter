import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/farmer_bottom_bar.dart';
import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/designsystem/components/session_overflow_button.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/presentation/profile/farmer_profile_screen.dart';

/// Farmer home shell with the five-tab bar from `FarmerHomeScreen` / `MuyuBottomBar`.
class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  FarmerTab _tab = FarmerTab.home;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          switch (_tab) {
            FarmerTab.home => const _FarmerPlotsEmpty(),
            FarmerTab.profile => const SizedBox.expand(child: FarmerProfileScreen()),
            _ => Column(
              children: [
                _FarmerSectionHeader(title: _tab.label(l10n)),
                Expanded(child: _FarmerComingSoon(message: l10n.merchantTabSoon)),
              ],
            ),
          },
          Align(
            alignment: Alignment.bottomCenter,
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: FarmerBottomBar(selectedTab: _tab, onTabSelected: (tab) => setState(() => _tab = tab)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerPlotsEmpty extends ConsumerWidget {
  const _FarmerPlotsEmpty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    return Column(
      children: [
        ColoredBox(
          color: MuyuColors.navBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.farmerHomeTitle,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const LanguageToggleButton(),
                  const SessionOverflowButton(iconColor: Colors.white),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, farmerScrollBottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user != null)
                    Text(
                      l10n.homeGreeting(user.firstName.isEmpty ? user.email : user.firstName),
                      textAlign: TextAlign.center,
                      style: MuyuTextStyles.screenTitle.copyWith(fontSize: 26),
                    ),
                  const SizedBox(height: 24),
                  Image.asset('assets/images/mascot_search.png', height: 180, excludeFromSemantics: true),
                  const SizedBox(height: 24),
                  Text(
                    l10n.farmerHomeEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FarmerSectionHeader extends StatelessWidget {
  const _FarmerSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.fredoka,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const LanguageToggleButton(),
              const SessionOverflowButton(iconColor: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerComingSoon extends StatelessWidget {
  const _FarmerComingSoon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, farmerScrollBottomInset),
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: MuyuColors.forest)),
      ),
    );
  }
}
