import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/designsystem/components/merchant_bottom_bar.dart';
import '../../../../core/designsystem/components/session_overflow_button.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/application/get_plots_use_case.dart';
import '../../../plot_approval/domain/plot.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/presentation/profile/merchant_profile_screen.dart';
import 'plot_offer_card.dart';

enum _CatalogFilter { all, near, recommended }

/// Merchant home: plot catalog, matching `MerchantCatalogScreen` in Kotlin.
class MerchantCatalogScreen extends ConsumerStatefulWidget {
  const MerchantCatalogScreen({super.key});

  @override
  ConsumerState<MerchantCatalogScreen> createState() => _MerchantCatalogScreenState();
}

class _MerchantCatalogScreenState extends ConsumerState<MerchantCatalogScreen> {
  MerchantTab _tab = MerchantTab.catalog;
  _CatalogFilter _filter = _CatalogFilter.all;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Plot> _filtered(List<Plot> plots) {
    final query = _search.text.trim().toLowerCase();
    return plots.where((plot) {
      final matchesQuery =
          query.isEmpty ||
          plot.name.toLowerCase().contains(query) ||
          plot.crop.toLowerCase().contains(query) ||
          plot.place.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _CatalogFilter.all => true,
        _CatalogFilter.near =>
          plot.place.toLowerCase().contains('cusco') ||
              plot.place.toLowerCase().contains('cuzco') ||
              plot.place.toLowerCase().contains('lima'),
        _CatalogFilter.recommended =>
          plot.amount.contains('8') ||
              plot.crop.toLowerCase().contains('papa') ||
              plot.crop.toLowerCase().contains('potato'),
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final companyName = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : l10n.merchantCompanyName;

    return Scaffold(
      backgroundColor: MuyuColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          switch (_tab) {
            MerchantTab.catalog => Column(
              children: [
                _CatalogHeader(
                  companyName: companyName,
                  search: _search,
                  onSearchChanged: (_) => setState(() {}),
                ),
                Expanded(
                  child: _CatalogBody(
                    plots: ref
                        .watch(_availablePlotsProvider)
                        .maybeWhen(data: _filtered, orElse: () => const <Plot>[]),
                    loading: ref.watch(_availablePlotsProvider).isLoading,
                    filter: _filter,
                    onFilterSelected: (value) => setState(() => _filter = value),
                  ),
                ),
              ],
            ),
            MerchantTab.profile => const SizedBox.expand(child: MerchantProfileScreen()),
            _ => Column(
              children: [
                _MerchantSectionHeader(title: _tab.label(l10n)),
                Expanded(child: _MerchantComingSoon(message: l10n.merchantTabSoon)),
              ],
            ),
          },
          Align(
            alignment: Alignment.bottomCenter,
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: MerchantBottomBar(
                selectedTab: _tab,
                onTabSelected: (tab) => setState(() => _tab = tab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _availablePlotsProvider = FutureProvider<List<Plot>>((ref) async {
  final plots = await ref.watch(getPlotsUseCaseProvider).execute();
  return plots.where((plot) => plot.status == 'available').toList();
});

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.companyName,
    required this.search,
    required this.onSearchChanged,
  });

  final String companyName;
  final TextEditingController search;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
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
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.merchantWelcome,
                            style: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              height: 28 / 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const LanguageToggleButton(),
                  const SessionOverflowButton(iconColor: Colors.white),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const _PeruFlag(),
                  const SizedBox(width: 8),
                  Text(
                    l10n.farmerCountryPeru,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: search,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.merchantSearch,
                      hintStyle: TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.black.withValues(alpha: 0.55)),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MerchantSectionHeader extends StatelessWidget {
  const _MerchantSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
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

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.plots,
    required this.loading,
    required this.filter,
    required this.onFilterSelected,
  });

  final List<Plot> plots;
  final bool loading;
  final _CatalogFilter filter;
  final ValueChanged<_CatalogFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: MuyuColors.forest));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, merchantScrollBottomInset),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: l10n.merchantFilterAll,
              selected: filter == _CatalogFilter.all,
              onTap: () => onFilterSelected(_CatalogFilter.all),
            ),
            _FilterChip(
              label: l10n.merchantFilterNear,
              selected: filter == _CatalogFilter.near,
              onTap: () => onFilterSelected(_CatalogFilter.near),
            ),
            _FilterChip(
              label: l10n.merchantFilterRecommended,
              selected: filter == _CatalogFilter.recommended,
              onTap: () => onFilterSelected(_CatalogFilter.recommended),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (plots.isEmpty)
          Text(
            l10n.merchantNoPlots,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          )
        else
          for (final plot in plots) ...[PlotOfferCard(plot: plot), const SizedBox(height: 16)],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MuyuColors.navBar : MuyuColors.skip,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected ? Colors.white : MuyuColors.nearText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MerchantComingSoon extends StatelessWidget {
  const _MerchantComingSoon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, merchantScrollBottomInset),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
        ),
      ),
    );
  }
}

class _PeruFlag extends StatelessWidget {
  const _PeruFlag();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).farmerFlagPeru,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: const SizedBox(
          width: 28,
          height: 16,
          child: Row(
            children: [
              Expanded(child: ColoredBox(color: Color(0xFFD22F27))),
              Expanded(child: ColoredBox(color: Colors.white)),
              Expanded(child: ColoredBox(color: Color(0xFFD22F27))),
            ],
          ),
        ),
      ),
    );
  }
}
