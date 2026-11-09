import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/muyu_controls.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../publish/publish_plot_screen.dart';
import '../plotdetail/farmer_plot_detail_screen.dart';

enum _PlotFilter { all, funded, available }

/// Opens the publish flow and confirms when the plot was saved.
Future<void> openPublishPlot(BuildContext context) async {
  final published = await Navigator.of(
    context,
  ).push<bool>(MaterialPageRoute(builder: (_) => const PublishPlotScreen()));
  if (published == true && context.mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.publishSuccess)));
  }
}

/// The farmer's plots with filters. It has no Scaffold of its own so it can
/// sit inside the farmer's tab shell.
class MyPlotsView extends ConsumerStatefulWidget {
  const MyPlotsView({super.key, this.bottomInset = 24, this.searchController});

  /// Space kept free below the list, for example for a bottom bar.
  final double bottomInset;

  /// Search field owned by the parent, as on Home where it sits in the header.
  /// When null, this view shows its own field.
  final TextEditingController? searchController;

  @override
  ConsumerState<MyPlotsView> createState() => _MyPlotsViewState();
}

class _MyPlotsViewState extends ConsumerState<MyPlotsView> {
  final _ownSearch = TextEditingController();
  _PlotFilter _filter = _PlotFilter.all;

  TextEditingController get _search => widget.searchController ?? _ownSearch;

  void _onSearchChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(MyPlotsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.searchController ?? _ownSearch;
    if (previous != _search) {
      previous.removeListener(_onSearchChanged);
      _search.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _ownSearch.dispose();
    super.dispose();
  }

  bool _passesFilter(FarmerPlot plot) => switch (_filter) {
    _PlotFilter.all => true,
    _PlotFilter.funded => plot.isFunded,
    _PlotFilter.available => !plot.isFunded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plots = ref.watch(farmerPlotsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchController == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: MuyuSearchField(controller: _ownSearch, hint: l10n.plotsSearchHint),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, MuyuSpacing.s8),
          child: Wrap(
            spacing: MuyuSpacing.s8,
            runSpacing: MuyuSpacing.s8,
            children: [
              for (final (filter, label) in [
                (_PlotFilter.all, l10n.plotsFilterAll),
                (_PlotFilter.funded, l10n.plotsFilterFunded),
                (_PlotFilter.available, l10n.plotsFilterAvailable),
              ])
                MuyuFilterChip(
                  label: label,
                  selected: _filter == filter,
                  onTap: () => setState(() => _filter = filter),
                ),
            ],
          ),
        ),
        Expanded(
          child: plots.when(
            loading: () => const Center(child: CircularProgressIndicator(color: MuyuColors.action)),
            error: (_, _) => _LoadError(onRetry: ref.read(farmerPlotsProvider.notifier).refresh),
            data: (all) => _PlotList(
              ownedCount: all.length,
              plots: all.where((p) => _passesFilter(p) && p.matches(_search.text)).toList(),
              bottomInset: widget.bottomInset,
              onRefresh: ref.read(farmerPlotsProvider.notifier).refresh,
              onOpen: (plot) => Navigator.of(
                context,
              ).push<bool>(MaterialPageRoute(builder: (_) => FarmerPlotDetailScreen(plot: plot))),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlotList extends StatelessWidget {
  const _PlotList({
    required this.ownedCount,
    required this.plots,
    required this.bottomInset,
    required this.onRefresh,
    required this.onOpen,
  });

  final int ownedCount;
  final List<FarmerPlot> plots;
  final double bottomInset;
  final Future<void> Function() onRefresh;
  final ValueChanged<FarmerPlot> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MuyuColors.action,
      child: plots.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(30, 40, 30, bottomInset),
              children: [
                Image.asset(
                  'assets/images/mascot_search.png',
                  height: 170,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 20),
                Text(
                  ownedCount == 0 ? l10n.farmerHomeEmpty : l10n.plotsNoMatch,
                  textAlign: TextAlign.center,
                  style: MuyuTextStyles.body.copyWith(color: MuyuColors.forest),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, MuyuSpacing.s8, 24, bottomInset),
              itemCount: plots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) =>
                  _PlotCard(plot: plots[index], onTap: () => onOpen(plots[index])),
            ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  const _PlotCard({required this.plot, required this.onTap});

  final FarmerPlot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MuyuColors.forest),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(plot.name, style: MuyuTextStyles.bodySemiBold)),
                    const SizedBox(width: MuyuSpacing.s8),
                    _StatusChip(funded: plot.isFunded),
                  ],
                ),
                const SizedBox(height: MuyuSpacing.s4),
                Text(
                  [plot.crop, plot.area].where((part) => part.isNotEmpty).join(' · '),
                  style: MuyuTextStyles.body,
                ),
                const SizedBox(height: MuyuSpacing.s8),
                _InfoLine(icon: Icons.place_outlined, text: plot.place),
                if (plot.harvestDate.isNotEmpty)
                  _InfoLine(
                    icon: Icons.calendar_today_outlined,
                    text: l10n.plotHarvest(plot.harvestDate),
                  ),
                const SizedBox(height: MuyuSpacing.s8),
                Text(
                  plot.amount,
                  style: MuyuTextStyles.bodyBold.copyWith(color: MuyuColors.forest),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: MuyuColors.action),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: MuyuTextStyles.body)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.funded});

  final bool funded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: funded ? MuyuColors.financedBackground : MuyuColors.approvedBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          funded ? l10n.plotsFilterFunded : l10n.plotsFilterAvailable,
          style: MuyuTextStyles.bodyBold.copyWith(
            color: funded ? MuyuColors.financedText : MuyuColors.forest,
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: MuyuColors.forest),
            const SizedBox(height: 12),
            Text(
              l10n.plotsLoadError,
              textAlign: TextAlign.center,
              style: MuyuTextStyles.body.copyWith(color: MuyuColors.forest),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.plotsRetry)),
          ],
        ),
      ),
    );
  }
}
