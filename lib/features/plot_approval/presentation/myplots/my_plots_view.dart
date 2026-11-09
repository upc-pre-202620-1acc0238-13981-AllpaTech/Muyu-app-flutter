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

enum _HomeFilter { all, funded, approved, pending }

/// Opens the publish flow and confirms when the plot was saved.
Future<void> openPublishPlot(BuildContext context) async {
  final published = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => const PublishPlotScreen()));
  if (published == true && context.mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.publishSuccess)));
  }
}

/// The farmer's plots with filters. It has no Scaffold of its own so it can
/// sit inside the farmer's tab shell.
class MyPlotsView extends ConsumerStatefulWidget {
  const MyPlotsView({
    super.key,
    this.bottomInset = 24,
    this.searchController,
    this.homeStyle = false,
  });

  /// Space kept free below the list, for example for a bottom bar.
  final double bottomInset;

  /// Search field owned by the parent, as on Home where it sits in the header.
  /// When null, this view shows its own field.
  final TextEditingController? searchController;

  /// Uses the photographic cards from Figma Home only when real plots exist.
  /// The empty state deliberately keeps the existing layout.
  final bool homeStyle;

  @override
  ConsumerState<MyPlotsView> createState() => _MyPlotsViewState();
}

class _MyPlotsViewState extends ConsumerState<MyPlotsView> {
  final _ownSearch = TextEditingController();
  _PlotFilter _plotFilter = _PlotFilter.all;
  _HomeFilter _homeFilter = _HomeFilter.all;

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

  bool _passesFilter(FarmerPlot plot, {required bool useHomeDesign}) {
    if (useHomeDesign) {
      return switch (_homeFilter) {
        _HomeFilter.all => true,
        _HomeFilter.funded => plot.status.toLowerCase() == 'funded',
        _HomeFilter.approved => plot.status.toLowerCase() == 'approved',
        _HomeFilter.pending =>
          plot.status.toLowerCase() != 'funded' && plot.status.toLowerCase() != 'approved',
      };
    }
    return switch (_plotFilter) {
      _PlotFilter.all => true,
      _PlotFilter.funded => plot.isFunded,
      _PlotFilter.available => !plot.isFunded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plots = ref.watch(farmerPlotsProvider);
    final useHomeDesign = plots.when(
      data: (all) => widget.homeStyle && all.isNotEmpty,
      loading: () => false,
      error: (_, _) => false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchController == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: MuyuSearchField(controller: _ownSearch, hint: l10n.plotsSearchHint),
          ),
        if (useHomeDesign)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 29),
              child: Row(
                children: [
                  for (final (filter, label, minWidth) in [
                    (_HomeFilter.all, l10n.plotsFilterAll, 74.0),
                    (_HomeFilter.funded, l10n.plotsFilterFunded, 111.0),
                    (_HomeFilter.approved, l10n.plotsFilterApproved, 128.0),
                    (_HomeFilter.pending, l10n.plotsFilterPending, 128.0),
                  ]) ...[
                    _HomeFilterChip(
                      label: label,
                      minWidth: minWidth,
                      selected: _homeFilter == filter,
                      onTap: () => setState(() => _homeFilter = filter),
                    ),
                    if (filter != _HomeFilter.pending) const SizedBox(width: MuyuSpacing.s8),
                  ],
                ],
              ),
            ),
          )
        else
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
                    selected: _plotFilter == filter,
                    onTap: () => setState(() => _plotFilter = filter),
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
              plots: all
                  .where(
                    (p) =>
                        _passesFilter(p, useHomeDesign: useHomeDesign) && p.matches(_search.text),
                  )
                  .toList(),
              bottomInset: widget.bottomInset,
              homeStyle: useHomeDesign,
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
    required this.homeStyle,
    required this.onRefresh,
    required this.onOpen,
  });

  final int ownedCount;
  final List<FarmerPlot> plots;
  final double bottomInset;
  final bool homeStyle;
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
              padding: EdgeInsets.fromLTRB(
                homeStyle ? 29 : 24,
                homeStyle ? 32 : MuyuSpacing.s8,
                homeStyle ? 30 : 24,
                bottomInset,
              ),
              itemCount: plots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) => homeStyle
                  ? _HomePlotCard(plot: plots[index], onTap: () => onOpen(plots[index]))
                  : _PlotCard(plot: plots[index], onTap: () => onOpen(plots[index])),
            ),
    );
  }
}

class _HomeFilterChip extends StatelessWidget {
  const _HomeFilterChip({
    required this.label,
    required this.minWidth,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double minWidth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? MuyuColors.forest : MuyuColors.skip,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth),
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1,
              color: selected ? MuyuColors.field : MuyuColors.nearText,
            ),
          ),
        ),
      ),
    ),
  );
}

enum _HomePlotStatus { funded, approved, pending }

extension on FarmerPlot {
  _HomePlotStatus get homeStatus => switch (status.toLowerCase()) {
    'funded' => _HomePlotStatus.funded,
    'approved' => _HomePlotStatus.approved,
    _ => _HomePlotStatus.pending,
  };

  String? get cropKey {
    final value = crop.toLowerCase();
    if (value.contains('coffee') || value.contains('café') || value.contains('cafe')) {
      return 'coffee';
    }
    if (value.contains('corn') || value.contains('maíz') || value.contains('maiz')) {
      return 'corn';
    }
    if (value.contains('quinoa') || value.contains('quinua')) return 'quinoa';
    return null;
  }
}

class _HomeCardStyle {
  const _HomeCardStyle({
    required this.panel,
    required this.track,
    required this.chipBackground,
    required this.chipText,
    required this.chipWeight,
  });

  final Color panel;
  final Color track;
  final Color chipBackground;
  final Color chipText;
  final FontWeight chipWeight;

  factory _HomeCardStyle.forPlot(FarmerPlot plot) => switch (plot.homeStatus) {
    _HomePlotStatus.funded => _HomeCardStyle(
      panel: MuyuColors.homeFundedPanel,
      track: MuyuColors.homeFundedTrack,
      chipBackground: MuyuColors.financedBackground.withValues(alpha: 0.6),
      chipText: MuyuColors.financedText,
      chipWeight: FontWeight.w800,
    ),
    _HomePlotStatus.approved => _HomeCardStyle(
      panel: MuyuColors.homeApprovedPanel,
      track: MuyuColors.homeApprovedTrack,
      chipBackground: MuyuColors.approvedBg.withValues(alpha: 0.6),
      chipText: MuyuColors.forest,
      chipWeight: FontWeight.w700,
    ),
    _HomePlotStatus.pending => _HomeCardStyle(
      panel: MuyuColors.homePendingPanel,
      track: MuyuColors.homePendingTrack,
      chipBackground: MuyuColors.pendingBackground.withValues(alpha: 0.6),
      chipText: MuyuColors.pendingText,
      chipWeight: FontWeight.w700,
    ),
  };
}

class _CropArtData {
  const _CropArtData({
    required this.asset,
    required this.width,
    required this.height,
    required this.top,
    required this.right,
  });

  final String asset;
  final double width;
  final double height;
  final double top;
  final double right;
}

_CropArtData? _cropArt(String? cropKey) => switch (cropKey) {
  'coffee' => const _CropArtData(
    asset: 'assets/images/home_crop_coffee.png',
    width: 39,
    height: 43,
    top: 100,
    right: 0,
  ),
  'corn' => const _CropArtData(
    asset: 'assets/images/home_crop_corn.png',
    width: 60,
    height: 74,
    top: 85,
    right: 5,
  ),
  'quinoa' => const _CropArtData(
    asset: 'assets/images/home_crop_quinoa.png',
    width: 81,
    height: 118,
    top: 81,
    right: 8,
  ),
  _ => null,
};

String? _cropPhoto(String? cropKey) => switch (cropKey) {
  'coffee' => 'assets/images/home_photo_coffee.png',
  'corn' => 'assets/images/home_photo_corn.png',
  'quinoa' => 'assets/images/home_photo_quinoa.png',
  _ => null,
};

class _HomePlotCard extends StatelessWidget {
  const _HomePlotCard({required this.plot, required this.onTap});

  final FarmerPlot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = _HomeCardStyle.forPlot(plot);
    final progress = plot.progress.clamp(0, 100);
    final stage = plot.stage.trim().isEmpty ? '—' : plot.stage;
    final cropArt = _cropArt(plot.cropKey);
    final statusLabel = switch (plot.homeStatus) {
      _HomePlotStatus.funded => l10n.plotsFilterFunded,
      _HomePlotStatus.approved => l10n.plotsFilterApproved,
      _HomePlotStatus.pending => l10n.plotsFilterPending,
    };
    const bodyStyle = TextStyle(
      fontFamily: MuyuFonts.urbanist,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 19 / 16,
      color: MuyuColors.field,
    );

    return Semantics(
      container: true,
      button: true,
      label: '${plot.name}, ${plot.crop}, ${plot.area}, $statusLabel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 248,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: MuyuColors.homePendingTrack),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 145,
                  child: _HomePlotPhoto(plot: plot),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 119,
                  height: 129,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: style.panel,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 11, 19, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plot.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStyle.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            [plot.crop, plot.area].where((value) => value.isNotEmpty).join('  ·  '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.plotCurrentStage}  $stage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 16,
                              child: ColoredBox(
                                color: style.track,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress / 100,
                                    heightFactor: 1,
                                    child: const ColoredBox(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(l10n.plotProgressComplete(progress), style: bodyStyle),
                        ],
                      ),
                    ),
                  ),
                ),
                if (cropArt case final art?)
                  Positioned(
                    top: art.top,
                    right: art.right,
                    width: art.width,
                    height: art.height,
                    child: Image.asset(art.asset, fit: BoxFit.contain, excludeFromSemantics: true),
                  ),
                Positioned(
                  top: 8,
                  right: 18,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 103),
                    height: 23,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: style.chipBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontSize: 16,
                        fontWeight: style.chipWeight,
                        height: 1,
                        color: style.chipText,
                      ),
                    ),
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

class _HomePlotPhoto extends StatelessWidget {
  const _HomePlotPhoto({required this.plot});

  final FarmerPlot plot;

  @override
  Widget build(BuildContext context) {
    final asset = _cropPhoto(plot.cropKey);
    final uri = plot.imageUri?.trim();

    Widget fallback() {
      if (asset != null) {
        return Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true);
      }
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9FCB72), Color(0xFF416D25)],
          ),
        ),
        child: Center(child: Icon(Icons.grass, size: 64, color: Colors.white70)),
      );
    }

    if (uri != null && (uri.startsWith('https://') || uri.startsWith('http://'))) {
      return Image.network(
        uri,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return fallback();
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
