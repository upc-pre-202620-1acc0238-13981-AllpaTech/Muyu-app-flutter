import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/farmer_bottom_bar.dart';
import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/designsystem/components/muyu_controls.dart';
import '../../../../core/designsystem/components/session_overflow_button.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/presentation/profile/farmer_profile_screen.dart';
import '../../../escrow_custody/presentation/payments/payment_history_view.dart';
import '../myplots/my_plots_view.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            switch (_tab) {
              FarmerTab.home => const _FarmerHomeTab(),
              FarmerTab.plot => SizedBox.expand(
                child: Column(
                  children: [
                    _FarmerSectionHeader(title: _tab.label(l10n), trailing: const _PublishButton()),
                    const Expanded(child: MyPlotsView(bottomInset: farmerScrollBottomInset)),
                  ],
                ),
              ),
              FarmerTab.profile => const SizedBox.expand(child: FarmerProfileScreen()),
              FarmerTab.payments => Column(
                children: [
                  _FarmerSectionHeader(title: _tab.label(l10n)),
                  const Expanded(child: PaymentHistoryView(bottomInset: farmerScrollBottomInset)),
                ],
              ),
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
                child: FarmerBottomBar(
                  selectedTab: _tab,
                  onTabSelected: (tab) => setState(() => _tab = tab),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Greeting header and the farmer's plots, as in the Figma Home.
class _FarmerHomeTab extends ConsumerStatefulWidget {
  const _FarmerHomeTab();

  @override
  ConsumerState<_FarmerHomeTab> createState() => _FarmerHomeTabState();
}

class _FarmerHomeTabState extends ConsumerState<_FarmerHomeTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final name = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : (user?.email ?? '');

    return Column(
      children: [
        ColoredBox(
          color: MuyuColors.navBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.merchantWelcome, style: MuyuTextStyles.welcomeLabel),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MuyuTextStyles.welcomeName,
                            ),
                          ],
                        ),
                      ),
                      const LanguageToggleButton(),
                      const SessionOverflowButton(iconColor: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const PeruFlag(),
                      const SizedBox(width: MuyuSpacing.s4),
                      Text(
                        l10n.farmerCountryPeru,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontSize: 15,
                          color: MuyuColors.field,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: MuyuSearchField(controller: _search, hint: l10n.plotsSearchHint),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: MyPlotsView(
            bottomInset: farmerScrollBottomInset,
            searchController: _search,
            homeStyle: true,
          ),
        ),
      ],
    );
  }
}

class _FarmerSectionHeader extends StatelessWidget {
  const _FarmerSectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 12),
          child: Row(
            children: [
              Expanded(child: Text(title, style: MuyuTextStyles.headerTitle)),
              ?trailing,
              const SizedBox(width: MuyuSpacing.s8),
              const LanguageToggleButton(),
              const SessionOverflowButton(iconColor: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  const _PublishButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => openPublishPlot(context),
      style: FilledButton.styleFrom(
        backgroundColor: MuyuColors.lime,
        foregroundColor: Colors.black,
        minimumSize: const Size(48, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        AppLocalizations.of(context).plotsPublish,
        style: MuyuTextStyles.bodyBold.copyWith(color: Colors.black),
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
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: MuyuTextStyles.body.copyWith(color: MuyuColors.forest),
        ),
      ),
    );
  }
}
