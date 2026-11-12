import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../application/weather_controller.dart';
import '../domain/weather_alert.dart';

class WeatherAlertScreen extends ConsumerStatefulWidget {
  const WeatherAlertScreen({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  ConsumerState<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends ConsumerState<WeatherAlertScreen> {
  final Set<WeatherMeasureKind> _selected = {};
  bool _saving = false;
  bool _saved = false;
  bool _validationError = false;

  Future<void> _save(WeatherAlert alert) async {
    if (_selected.isEmpty) {
      setState(() => _validationError = true);
      return;
    }
    setState(() {
      _saving = true;
      _validationError = false;
    });
    try {
      await ref
          .read(weatherMeasuresControllerProvider)
          .save(plot: widget.plot, alert: alert, selected: _selected);
      if (mounted) setState(() => _saved = true);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).plotsLoadError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forecast = ref.watch(weatherAlertProvider(widget.plot));
    return Scaffold(
      backgroundColor: MuyuColors.background,
      appBar: AppBar(
        backgroundColor: MuyuColors.navBar,
        foregroundColor: Colors.white,
        title: Text(l10n.weatherTitle),
      ),
      body: forecast.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.weatherLoading),
            ],
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: MuyuColors.forest),
                const SizedBox(height: 12),
                Text(l10n.weatherUnavailable, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => ref.invalidate(weatherAlertProvider(widget.plot)),
                  child: Text(l10n.plotsRetry),
                ),
              ],
            ),
          ),
        ),
        data: (alert) => _WeatherContent(
          plot: widget.plot,
          alert: alert,
          selected: _selected,
          saved: _saved,
          saving: _saving,
          validationError: _validationError,
          onToggle: (measure) => setState(() {
            _validationError = false;
            _selected.contains(measure) ? _selected.remove(measure) : _selected.add(measure);
          }),
          onSave: () => _save(alert),
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.plot,
    required this.alert,
    required this.selected,
    required this.saved,
    required this.saving,
    required this.validationError,
    required this.onToggle,
    required this.onSave,
  });
  final FarmerPlot plot;
  final WeatherAlert alert;
  final Set<WeatherMeasureKind> selected;
  final bool saved;
  final bool saving;
  final bool validationError;
  final ValueChanged<WeatherMeasureKind> onToggle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = weatherAlertKey(plot, alert, DateTime.now());
    final previous = recordedMeasures(plot, key);
    final done = saved || previous != null;
    final title = alert.isFrost
        ? l10n.weatherFrost
        : alert.isRain
        ? l10n.weatherHeavyRain
        : l10n.weatherStable;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('${plot.name} · ${plot.crop}', style: MuyuTextStyles.bodyBold),
        Text(plot.place),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _riskColor(alert.risk),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                alert.isRain
                    ? Icons.thunderstorm
                    : alert.isFrost
                    ? Icons.ac_unit
                    : Icons.wb_sunny,
                size: 64,
              ),
              Text(title, style: MuyuTextStyles.bodyBold.copyWith(fontSize: 24)),
              Text('${alert.temperature.round()} °C'),
              Text('${l10n.weatherRisk}: ${_riskLabel(l10n, alert.risk)}'),
              Text(
                '${alert.rainProbability}% lluvia · ${alert.minimumTemperature.round()}° / ${alert.maximumTemperature.round()}°',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(l10n.weatherRecommendations, style: MuyuTextStyles.bodyBold),
        const SizedBox(height: 10),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  done ? l10n.weatherMeasuresDone : l10n.weatherMeasuresPending,
                  style: MuyuTextStyles.bodyBold,
                ),
                const SizedBox(height: 6),
                Text(l10n.weatherMeasuresHint),
                for (final measure in alert.measures)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: done
                        ? (previous?.measures.contains(measure.name) ?? selected.contains(measure))
                        : selected.contains(measure),
                    onChanged: done ? null : (_) => onToggle(measure),
                    title: Text(_measureLabel(l10n, measure)),
                    activeColor: MuyuColors.forest,
                  ),
                if (validationError)
                  Text(
                    l10n.weatherMeasuresRequired,
                    style: const TextStyle(color: MuyuColors.dangerMessage),
                  ),
                if (!done)
                  FilledButton(
                    onPressed: saving ? null : onSave,
                    child: saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.weatherMeasuresConfirm),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color _riskColor(WeatherRisk risk) => switch (risk) {
  WeatherRisk.high => MuyuColors.dangerBackground,
  WeatherRisk.medium => MuyuColors.pendingBackground,
  WeatherRisk.low => MuyuColors.statCard,
};

String _riskLabel(AppLocalizations l10n, WeatherRisk risk) => switch (risk) {
  WeatherRisk.high => l10n.weatherRiskHigh,
  WeatherRisk.medium => l10n.weatherRiskMedium,
  WeatherRisk.low => l10n.weatherRiskLow,
};

String _measureLabel(AppLocalizations l10n, WeatherMeasureKind measure) => switch (measure) {
  WeatherMeasureKind.drainage => l10n.weatherMeasureDrainage,
  WeatherMeasureKind.cover => l10n.weatherMeasureCover,
  WeatherMeasureKind.irrigation => l10n.weatherMeasureIrrigation,
  WeatherMeasureKind.monitor => l10n.weatherMeasureMonitor,
};
