import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';

/// Space the catalog list leaves so the last card clears this bar.
const merchantScrollBottomInset = 140.0;

/// Merchant tabs, matching `MerchantTab` in the Kotlin `MerchantBottomBar`.
enum MerchantTab { catalog, myPlots, alerts, payments, profile }

extension MerchantTabUi on MerchantTab {
  String label(AppLocalizations l10n) => switch (this) {
    MerchantTab.catalog => l10n.navCatalog,
    MerchantTab.myPlots => l10n.navMyPlots,
    MerchantTab.alerts => l10n.navAlerts,
    MerchantTab.payments => l10n.navPayments,
    MerchantTab.profile => l10n.navProfile,
  };

  String get iconAsset => switch (this) {
    MerchantTab.catalog => 'assets/icons/ic_nav_catalog.svg',
    MerchantTab.myPlots => 'assets/icons/ic_nav_plot.svg',
    MerchantTab.alerts => 'assets/icons/ic_nav_alerts.svg',
    MerchantTab.payments => 'assets/icons/ic_nav_payments.svg',
    MerchantTab.profile => 'assets/icons/ic_nav_profile.svg',
  };

  Size get iconSize => switch (this) {
    MerchantTab.catalog => const Size(22, 20),
    MerchantTab.myPlots => const Size(26, 22),
    MerchantTab.alerts => const Size(22, 24),
    MerchantTab.payments => const Size(24, 20),
    MerchantTab.profile => const Size(24, 22),
  };
}

/// Dark green merchant navigation bar, reusable on every merchant screen.
class MerchantBottomBar extends StatelessWidget {
  const MerchantBottomBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final MerchantTab selectedTab;
  final ValueChanged<MerchantTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MuyuColors.navBar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final tab in MerchantTab.values)
                  Expanded(
                    child: _MerchantNavTab(
                      tab: tab,
                      selected: tab == selectedTab,
                      onTap: () => onTabSelected(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MerchantNavTab extends StatelessWidget {
  const _MerchantNavTab({required this.tab, required this.selected, required this.onTap});

  final MerchantTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = tab.label(AppLocalizations.of(context));
    final size = tab.iconSize;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Container(
                width: 62,
                height: 56,
                decoration: BoxDecoration(
                  color: MuyuColors.navSelected,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  tab.iconAsset,
                  width: size.width,
                  height: size.height,
                  semanticsLabel: label,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
