import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/plot_photo.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../climate_monitoring/presentation/weather_alert_screen.dart';
import '../../../plot_financing/presentation/harvest/harvest_delivery_screens.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../../domain/farmer_plot_repository.dart';
import '../../domain/plot_status_label.dart';
import '../plotdetail/farmer_plot_detail_screen.dart';
import '../publish/publish_plot_screen.dart';
import 'farmer_plot_display.dart';

const _muted = Color(0xFF4F5A50);
const _errorRed = Color(0xFF9E2F2F);
const _okAlertBackground = Color(0xFFCBF5B8);
const _okAlertText = Color(0xFF0F3F0D);
const _nearText = Color(0xFF579226);
const _sectionBackground = Color(0xFFF1F1F1);
const _financedBackground = Color(0xFFC8DBFF);
const _financedText = Color(0xFF3A5DD2);
const _availableBackground = Color(0xFFFFD9D9);
const _rainBackground = Color(0xFFFED2BD);
const _progressFill = Color(0xFF477B1C);
const _menuButton = Color(0xFFD9D9D9);
const _totalMilestones = 4;

TextStyle _urbanist(double size, FontWeight weight, Color color) =>
    TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: size, fontWeight: weight, color: color);

/// Opens the publish flow and confirms when the plot was saved.
Future<void> openPublishPlot(BuildContext context) async {
  final published = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => const PublishPlotScreen()));
  if (published == true && context.mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.publishSuccess)));
  }
}

enum _HomeFilter { all, funded, approved, pending }

enum _PlotFilter { all, funded, available }

/// The farmer's plots, as Kotlin `FarmerHomeScreen` (with [homeStyle]) or
/// `FarmerMyPlotsScreen`. It has no Scaffold so it sits inside the tab shell.
class MyPlotsView extends ConsumerStatefulWidget {
  const MyPlotsView({
    super.key,
    this.bottomInset = 24,
    this.searchController,
    this.homeStyle = false,
    this.onGoToPlots,
  });

  /// Space kept free below the list, for example for a bottom bar.
  final double bottomInset;

  /// Search field owned by the parent, as on Home where it sits in the header.
  /// When null, this view shows its own field.
  final TextEditingController? searchController;

  /// Home cards and filters instead of the My Plots list.
  final bool homeStyle;

  /// Home's empty state button, which opens the My Plots tab.
  final VoidCallback? onGoToPlots;

  @override
  ConsumerState<MyPlotsView> createState() => _MyPlotsViewState();
}

class _MyPlotsViewState extends ConsumerState<MyPlotsView> {
  final _ownSearch = TextEditingController();
  _HomeFilter _homeFilter = _HomeFilter.all;
  _PlotFilter _plotFilter = _PlotFilter.all;

  TextEditingController get _search => widget.searchController ?? _ownSearch;

  bool get _es => Localizations.localeOf(context).languageCode == 'es';

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

  bool _passesHomeFilter(FarmerPlot plot) => switch (_homeFilter) {
    _HomeFilter.all => true,
    _HomeFilter.funded => plot.status.toLowerCase() == 'funded',
    _HomeFilter.approved => plot.status.toLowerCase() == 'approved',
    _HomeFilter.pending =>
      plot.status.toLowerCase() != 'funded' && plot.status.toLowerCase() != 'approved',
  };

  // Kotlin `matchesFarmerFilter`.
  bool _passesPlotFilter(FarmerPlot plot) => switch (_plotFilter) {
    _PlotFilter.all => true,
    _PlotFilter.funded => plot.status == 'funded' || plot.status == 'approved',
    _PlotFilter.available =>
      plot.status == 'available' || plot.status == 'published' || plot.status == 'pending',
  };

  void _open(FarmerPlot plot) =>
      Navigator.of(context)
          .push<bool>(MaterialPageRoute(builder: (_) => FarmerPlotDetailScreen(plot: plot)));

  @override
  Widget build(BuildContext context) =>
      widget.homeStyle ? _buildHome(context) : _buildMyPlots(context);

  Widget _buildHome(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plots = ref.watch(farmerPlotsProvider);
    final all = plots.value ?? const <FarmerPlot>[];
    final visible = all.where((p) => _passesHomeFilter(p) && p.matchesSearch(_search.text));
    final notices = all
        .where((p) => p.harvestReceivedAt.isNotEmpty || p.harvestIncidents.isNotEmpty)
        .take(2);

    final List<Widget> children;
    if (plots.isLoading && all.isEmpty) {
      children = [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator(color: MuyuColors.action)),
        ),
      ];
    } else if (plots.hasError && all.isEmpty) {
      children = [_StateMessage(text: l10n.plotsLoadError, color: _errorRed)];
    } else if (all.isEmpty) {
      children = [_EmptyPlots(es: _es, onGoToPlots: widget.onGoToPlots)];
    } else if (visible.isEmpty) {
      children = [_StateMessage(text: l10n.plotsNoMatch, color: _muted)];
    } else {
      children = [for (final plot in visible) _HomePlotCard(plot: plot, onTap: () => _open(plot))];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 29),
          child: Row(
            children: [
              for (final (filter, label, minWidth) in [
                (_HomeFilter.all, _es ? 'Todas' : 'All', 74.0),
                (_HomeFilter.funded, _es ? 'Financiada' : 'Funded', 111.0),
                (_HomeFilter.approved, _es ? 'Aprobado' : 'Approved', 128.0),
                (_HomeFilter.pending, _es ? 'Pendiente' : 'Pending', 128.0),
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
        const SizedBox(height: 32),
        Expanded(
          child: RefreshIndicator(
            onRefresh: ref.read(farmerPlotsProvider.notifier).refresh,
            color: MuyuColors.action,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(29, 0, 30, widget.bottomInset),
              children: [
                for (final plot in notices) ...[
                  FarmerHarvestNotice(plot: plot),
                  const SizedBox(height: 16),
                ],
                for (final (index, child) in children.indexed) ...[
                  if (index > 0) const SizedBox(height: 16),
                  child,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPlots(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plots = ref.watch(farmerPlotsProvider);
    final all = plots.value ?? const <FarmerPlot>[];
    final visible = all.where((p) => _passesPlotFilter(p) && p.matchesSearch(_search.text)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final Widget body;
    if (plots.isLoading && all.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: MuyuColors.action)),
      );
    } else if (plots.hasError && all.isEmpty) {
      body = _StateMessage(text: l10n.plotsLoadError, color: _errorRed);
    } else if (visible.isEmpty) {
      body = Text(l10n.plotsNoMatch, style: _urbanist(16, FontWeight.w400, _muted));
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plot in visible) ...[
            _FarmerPlotCard(plot: plot, es: _es, onView: () => _open(plot)),
            const SizedBox(height: 16),
          ],
        ],
      );
    }

    return ColoredBox(
      color: MuyuColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.searchController == null)
                  _PlotSearchField(controller: _ownSearch, es: _es),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (filter, label) in [
                      (_PlotFilter.all, _es ? 'Todas' : 'All'),
                      (_PlotFilter.funded, _es ? 'Financiada' : 'Funded'),
                      (_PlotFilter.available, _es ? 'Disponible' : 'Available'),
                    ])
                      _PlotFilterChip(
                        label: label,
                        selected: _plotFilter == filter,
                        selectedBackground: filter == _PlotFilter.all
                            ? MuyuColors.forest
                            : _okAlertBackground,
                        selectedText: filter == _PlotFilter.all ? MuyuColors.field : _nearText,
                        onTap: () => setState(() => _plotFilter = filter),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: ref.read(farmerPlotsProvider.notifier).refresh,
              color: MuyuColors.action,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(28, 16, 28, widget.bottomInset),
                children: [body],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(text, style: _urbanist(16, FontWeight.w600, color)),
  );
}

/// Kotlin `EmptyPlots` on Home.
class _EmptyPlots extends StatelessWidget {
  const _EmptyPlots({required this.es, this.onGoToPlots});

  final bool es;
  final VoidCallback? onGoToPlots;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Icon(Icons.eco, size: 56, color: MuyuColors.action),
        const SizedBox(height: 16),
        Text(
          es ? 'Aún no tienes parcelas' : 'No plots yet',
          textAlign: TextAlign.center,
          style: _urbanist(22, FontWeight.w700, MuyuColors.forest),
        ),
        const SizedBox(height: 12),
        Text(
          es
              ? 'Tus parcelas aparecerán aquí cuando crees la primera.'
              : 'Your plots will appear here once you create your first one.',
          textAlign: TextAlign.center,
          style: _urbanist(14, FontWeight.w400, _muted),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: onGoToPlots,
          style: FilledButton.styleFrom(backgroundColor: MuyuColors.action),
          child: Text(
            es ? 'Ir a Mis parcelas' : 'Go to My Plots',
            style: _urbanist(14, FontWeight.w600, Colors.white),
          ),
        ),
      ],
    ),
  );
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
            style: _urbanist(
              16,
              FontWeight.w700,
              selected ? MuyuColors.field : MuyuColors.nearText,
            ).copyWith(height: 1),
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

/// Kotlin `HomePlotCard`: photo on top and a status-colored panel below.
class _HomePlotCard extends StatelessWidget {
  const _HomePlotCard({required this.plot, required this.onTap});

  final FarmerPlot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final style = _HomeCardStyle.forPlot(plot);
    final progress = plot.progress.clamp(0, 100);
    final stage = plot.stageTitle(es: es) ?? plotStageLabel(plot.stage, es: es);
    final cropArt = _cropArt(plot.cropKey);
    final statusLabel = switch (plot.homeStatus) {
      _HomePlotStatus.funded => es ? 'Financiada' : 'Funded',
      _HomePlotStatus.approved => es ? 'Aprobado' : 'Approved',
      _HomePlotStatus.pending => es ? 'Pendiente' : 'Pending',
    };
    final bodyStyle = _urbanist(16, FontWeight.w400, MuyuColors.field).copyWith(height: 19 / 16);

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
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 145,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PlotPhoto(
                      source: plot.imageUri,
                      description: plot.name,
                      height: null,
                      fallbackAsset: _cropPhoto(plot.cropKey),
                    ),
                  ),
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 19, 0),
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
                            '${plot.crop}  ·  ${formatPlotArea(plot.area)}',
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
                          _Bar(progress: progress, track: style.track, fill: Colors.white),
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
                      style: _urbanist(16, style.chipWeight, style.chipText).copyWith(height: 1),
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

class _Bar extends StatelessWidget {
  const _Bar({required this.progress, required this.track, required this.fill});

  final int progress;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: 16,
      child: ColoredBox(
        color: track,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress / 100,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Kotlin `SearchField` on My Plots.
class _PlotSearchField extends StatelessWidget {
  const _PlotSearchField({required this.controller, required this.es});

  final TextEditingController controller;
  final bool es;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        const Icon(Icons.search, size: 20, color: Colors.black),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              style: _urbanist(16, FontWeight.w400, Colors.black),
              decoration: InputDecoration.collapsed(
                hintText: es ? 'Buscar parcelas o GPS…' : 'Search plots or GPS…',
                hintStyle: _urbanist(16, FontWeight.w400, _muted),
              ),
            ),
          ),
        ),
        const Icon(Icons.tune, size: 18, color: Colors.black),
      ],
    ),
  );
}

class _PlotFilterChip extends StatelessWidget {
  const _PlotFilterChip({
    required this.label,
    required this.selected,
    required this.selectedBackground,
    required this.selectedText,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedBackground;
  final Color selectedText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? selectedBackground : _okAlertBackground.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          child: Text(
            label,
            style: _urbanist(
              16,
              FontWeight.w700,
              selected ? selectedText : _nearText.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Kotlin `FarmerPlotCard` on My Plots.
class _FarmerPlotCard extends ConsumerWidget {
  const _FarmerPlotCard({required this.plot, required this.es, required this.onView});

  final FarmerPlot plot;
  final bool es;
  final VoidCallback onView;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final updated = await Navigator.push<FarmerPlot>(
      context,
      MaterialPageRoute(builder: (_) => EditFarmerPlotScreen(plot: plot)),
    );
    if (updated == null) return;
    try {
      await ref.read(farmerPlotsProvider.notifier).updatePlot(updated);
    } on PlotException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(es ? 'No se pudo guardar la parcela.' : 'The plot could not be saved.'),
          ),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(es ? '¿Eliminar ${plot.name}?' : 'Delete ${plot.name}?'),
        content: Text(
          es
              ? 'Se eliminarán la parcela y sus solicitudes de visita. No se puede deshacer.'
              : 'The plot and its visit requests will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(es ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(es ? 'Eliminar' : 'Delete', style: const TextStyle(color: _errorRed)),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      await ref.read(farmerPlotsProvider.notifier).delete(plot.id);
    } on PlotException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              es ? 'No se pudo eliminar la parcela.' : 'The plot could not be deleted.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funded = plot.isFundedPlot;
    final progress = funded ? plot.progress.clamp(0, 100) : 0;
    final stage = !funded
        ? (es ? 'Publicada' : 'Listed')
        : plot.stageTitle(es: es) ?? plotStageLabel(plot.stage, es: es);
    final (chipBackground, chipText, chipLabel) = funded
        ? (_financedBackground, _financedText, es ? 'Financiada' : 'Funded')
        : plot.status == 'available'
        ? (_availableBackground, _errorRed, es ? 'Disponible' : 'Available')
        : (_financedBackground, _financedText, es ? 'Publicada' : 'Published');
    final muted16 = _urbanist(16, FontWeight.w400, _muted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(plot.name, style: _urbanist(16, FontWeight.w600, Colors.black))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(chipLabel, style: _urbanist(16, FontWeight.w700, chipText)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 104,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MuyuColors.forest),
                ),
                clipBehavior: Clip.antiAlias,
                child: PlotPhoto(source: plot.imageUri, description: plot.name, height: null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${plot.crop} · ${formatPlotArea(plot.area)}', style: muted16),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: MuyuColors.action),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            plot.place.trim().isEmpty ? '—' : plot.place,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: muted16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: es ? 'Etapa actual: ' : 'Current stage: ', style: muted16),
                          TextSpan(
                            text: stage,
                            style: _urbanist(14, FontWeight.w700, Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Bar(
                      progress: progress,
                      track: funded ? _okAlertBackground : _sectionBackground,
                      fill: _progressFill,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      funded
                          ? (es
                                ? '$progress % completo · ${plot.approvedMilestoneCount}/$_totalMilestones hitos'
                                : '$progress % complete · ${plot.approvedMilestoneCount}/$_totalMilestones milestones')
                          : (es
                                ? 'Sin financiar · 0/$_totalMilestones hitos'
                                : 'Unfunded · 0/$_totalMilestones milestones'),
                      style: _urbanist(14, FontWeight.w700, MuyuColors.forest),
                    ),
                    const SizedBox(height: 8),
                    _WeatherAlertRow(
                      rainRisk: plot.hasHeavyRainRisk,
                      neutral: !funded,
                      es: es,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (_) => WeatherAlertScreen(plot: plot)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: MuyuColors.action,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          es ? 'Ver parcela' : 'View plot',
                          style: _urbanist(14, FontWeight.w700, Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: es ? 'Acciones de la parcela' : 'Plot actions',
                onSelected: (action) =>
                    action == 'edit' ? _edit(context, ref) : _delete(context, ref),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    enabled: !funded,
                    child: Text(es ? 'Editar parcela' : 'Edit plot'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    enabled: !funded,
                    child: Text(
                      es ? 'Eliminar parcela' : 'Delete plot',
                      style: funded ? null : const TextStyle(color: _errorRed),
                    ),
                  ),
                  if (funded)
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        es
                            ? 'Las parcelas financiadas no se pueden editar ni eliminar'
                            : 'Funded plots cannot be edited or deleted',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
                child: Container(
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _menuButton,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.more_vert, size: 20, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kotlin `WeatherAlertRow`.
class _WeatherAlertRow extends StatelessWidget {
  const _WeatherAlertRow({
    required this.rainRisk,
    required this.neutral,
    required this.es,
    required this.onTap,
  });

  final bool rainRisk;
  final bool neutral;
  final bool es;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = rainRisk
        ? _rainBackground
        : neutral
        ? _sectionBackground
        : _okAlertBackground;
    final foreground = rainRisk
        ? _errorRed
        : neutral
        ? _muted
        : _okAlertText;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: rainRisk ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            children: [
              if (rainRisk)
                const Icon(Icons.cloud, size: 20, color: _errorRed)
              else if (!neutral)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: MuyuColors.forest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              if (rainRisk || !neutral) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rainRisk
                      ? (es ? 'Riesgo de lluvia fuerte' : 'Heavy rain risk')
                      : (es ? 'Sin alertas activas' : 'No active alerts'),
                  style: _urbanist(14, FontWeight.w700, foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
