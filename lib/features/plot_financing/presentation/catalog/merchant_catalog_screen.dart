import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/designsystem/components/merchant_bottom_bar.dart';
import '../../../../core/designsystem/components/muyu_controls.dart';
import '../../../../core/designsystem/components/session_overflow_button.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/farmer_plot_repository.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/presentation/profile/merchant_profile_screen.dart';
import '../../../escrow_custody/presentation/payments/payment_history_view.dart';
import '../../../climate_monitoring/presentation/merchant_alerts_view.dart';
import '../../application/merchant_financing_controller.dart';
import '../funding/fund_plot_screen.dart';
import '../funding/merchant_financing_lists.dart';
import '../plotdetail/merchant_plot_detail_screen.dart';
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

  List<FarmerPlot> _filtered(List<FarmerPlot> plots) {
    final query = _search.text.trim().toLowerCase();
    return plots.where((plot) {
      if (plot.status != FarmerPlot.statusAvailable) return false;
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

  Future<void> _openPlot(FarmerPlot plot) async {
    final navigator = Navigator.of(context);
    await navigator.push<void>(
      MaterialPageRoute(
        builder: (detailContext) => MerchantPlotDetailScreen(
          plot: plot,
          onFund: () => Navigator.of(detailContext).push<void>(
            MaterialPageRoute<void>(builder: (_) => FundPlotScreen(plot: plot.toPlot())),
          ),
        ),
      ),
    );
    if (mounted) await _refreshCatalog();
  }

  Future<void> _refreshCatalog() async {
    try {
      await ref.read(merchantFinancingProvider.notifier).refresh();
    } on PlotException {
      // The catalog body shows the failure with a retry button.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final catalog = ref.watch(merchantFinancingProvider);
    final companyName = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : (user?.email ?? '');

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
                    plots: _filtered(catalog.value ?? const <FarmerPlot>[]),
                    loading: catalog.isLoading && !catalog.hasValue && !catalog.hasError,
                    failed: catalog.hasError,
                    filter: _filter,
                    onFilterSelected: (value) => setState(() => _filter = value),
                    onRefresh: _refreshCatalog,
                    onPlotSelected: _openPlot,
                  ),
                ),
              ],
            ),
            MerchantTab.myPlots => const MerchantFundedPlotsView(),
            MerchantTab.profile => const SizedBox.expand(child: MerchantProfileScreen()),
            MerchantTab.payments => Column(
              children: [
                _MerchantSectionHeader(title: l10n.paymentsTitle),
                const Expanded(child: PaymentHistoryView(bottomInset: merchantScrollBottomInset)),
              ],
            ),
            MerchantTab.alerts => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AlertsTabHeader(),
                const Expanded(child: MerchantAlertsView(bottomInset: merchantScrollBottomInset)),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            height: 28 / 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguageToggleButton(),
                ],
              ),
              const SizedBox(height: 8),
              const Row(children: [PeruFlag(), SizedBox(width: 8), _PeruLabel()]),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, size: 20, color: Colors.black.withValues(alpha: 0.55)),
                      const SizedBox(width: 10),
                      Expanded(
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
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
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

class _PeruLabel extends StatelessWidget {
  const _PeruLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).farmerCountryPeru,
      style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 14, color: Colors.white),
    );
  }
}

class _AlertsTabHeader extends StatelessWidget {
  const _AlertsTabHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).merchantAlertsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
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
    required this.failed,
    required this.filter,
    required this.onFilterSelected,
    required this.onRefresh,
    required this.onPlotSelected,
  });

  final List<FarmerPlot> plots;
  final bool loading;
  final bool failed;
  final _CatalogFilter filter;
  final ValueChanged<_CatalogFilter> onFilterSelected;
  final Future<void> Function() onRefresh;
  final ValueChanged<FarmerPlot> onPlotSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: MuyuColors.forest));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MuyuColors.forest,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, merchantScrollBottomInset),
        children: [
          Row(
            children: [
              _FilterChip(
                label: l10n.merchantFilterAll,
                selected: filter == _CatalogFilter.all,
                onTap: () => onFilterSelected(_CatalogFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: l10n.merchantFilterNear,
                selected: filter == _CatalogFilter.near,
                onTap: () => onFilterSelected(_CatalogFilter.near),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: l10n.merchantFilterRecommended,
                selected: filter == _CatalogFilter.recommended,
                onTap: () => onFilterSelected(_CatalogFilter.recommended),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (failed)
            Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.cloud_off_outlined, size: 48, color: MuyuColors.forest),
                const SizedBox(height: 12),
                Text(
                  l10n.plotsLoadError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: MuyuColors.forest),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onRefresh, child: Text(l10n.plotsRetry)),
              ],
            )
          else if (plots.isEmpty)
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
            for (final plot in plots) ...[
              PlotOfferCard(plot: plot, onTap: () => onPlotSelected(plot)),
              const SizedBox(height: 16),
            ],
        ],
      ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
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
        ),
      ),
    );
  }
}
