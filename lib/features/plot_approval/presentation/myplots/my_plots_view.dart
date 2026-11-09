import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../publish/publish_plot_screen.dart';

enum _PlotFilter { all, funded, available }

/// The farmer's plots with search, filters and the Publish action. It has no
/// Scaffold of its own so it can sit inside the farmer's tab shell.
class MyPlotsView extends ConsumerStatefulWidget {
  const MyPlotsView({super.key, this.bottomInset = 24});

  /// Space kept free below the list, for example for a bottom bar.
  final double bottomInset;

  @override
  ConsumerState<MyPlotsView> createState() => _MyPlotsViewState();
}

class _MyPlotsViewState extends ConsumerState<MyPlotsView> {
  final _search = TextEditingController();
  _PlotFilter _filter = _PlotFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openPublish() async {
    final published = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const PublishPlotScreen()));
    if (published == true && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.publishSuccess)));
    }
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.plotsSearchHint,
                    prefixIcon: const Icon(Icons.search, color: MuyuColors.forest),
                    filled: true,
                    fillColor: MuyuColors.field,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _openPublish,
                style: FilledButton.styleFrom(
                  backgroundColor: MuyuColors.action,
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.plotsPublish),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Wrap(
            spacing: 8,
            children: [
              for (final (filter, label) in [
                (_PlotFilter.all, l10n.plotsFilterAll),
                (_PlotFilter.funded, l10n.plotsFilterFunded),
                (_PlotFilter.available, l10n.plotsFilterAvailable),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _filter == filter,
                  selectedColor: MuyuColors.skip,
                  onSelected: (_) => setState(() => _filter = filter),
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
  });

  final int ownedCount;
  final List<FarmerPlot> plots;
  final double bottomInset;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: MuyuColors.action,
      child: plots.isEmpty
          ? ListView(
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
                  style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
                ),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset),
              itemCount: plots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _PlotCard(plot: plots[index]),
            ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  const _PlotCard({required this.plot});

  final FarmerPlot plot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    plot.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(funded: plot.isFunded),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [plot.crop, plot.area].where((part) => part.isNotEmpty).join(' · '),
              style: const TextStyle(fontSize: 15, color: MuyuColors.forest),
            ),
            const SizedBox(height: 8),
            _InfoLine(icon: Icons.place_outlined, text: plot.place),
            if (plot.harvestDate.isNotEmpty)
              _InfoLine(
                icon: Icons.calendar_today_outlined,
                text: l10n.plotHarvest(plot.harvestDate),
              ),
            const SizedBox(height: 8),
            Text(
              plot.amount,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: MuyuColors.forest,
              ),
            ),
          ],
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
          Icon(icon, size: 16, color: MuyuColors.navSelected),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
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
        color: funded ? MuyuColors.financedBackground : MuyuColors.statCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          funded ? l10n.plotsFilterFunded : l10n.plotsFilterAvailable,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
              style: const TextStyle(fontSize: 16, color: MuyuColors.forest),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.plotsRetry)),
          ],
        ),
      ),
    );
  }
}
