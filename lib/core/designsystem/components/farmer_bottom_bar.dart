import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';

const farmerScrollBottomInset = 140.0;

/// Farmer tabs, matching `MuyuTab` in the Kotlin `MuyuBottomBar`.
enum FarmerTab { home, plot, sync, payments, profile }

extension FarmerTabUi on FarmerTab {
  String label(AppLocalizations l10n) => switch (this) {
    FarmerTab.home => l10n.navHome,
    FarmerTab.plot => l10n.navPlot,
    FarmerTab.sync => l10n.navSync,
    FarmerTab.payments => l10n.navPayment,
    FarmerTab.profile => l10n.navProfile,
  };

  IconData get icon => switch (this) {
    FarmerTab.home => Icons.home,
    FarmerTab.plot => Symbols.article,
    FarmerTab.sync => Icons.cloud_done,
    FarmerTab.payments => Symbols.money_bag,
    FarmerTab.profile => Icons.person,
  };
}

class FarmerBottomBar extends StatelessWidget {
  const FarmerBottomBar({super.key, required this.selectedTab, required this.onTabSelected});

  final FarmerTab selectedTab;
  final ValueChanged<FarmerTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MuyuColors.navBar,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final tab in FarmerTab.values)
                  Expanded(
                    child: _FarmerNavTab(
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

class _FarmerNavTab extends StatelessWidget {
  const _FarmerNavTab({required this.tab, required this.selected, required this.onTap});

  final FarmerTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = tab.label(AppLocalizations.of(context));
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
                decoration: BoxDecoration(color: MuyuColors.navSelected, borderRadius: BorderRadius.circular(20)),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 28, fill: 1, color: Colors.white, semanticLabel: label),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
