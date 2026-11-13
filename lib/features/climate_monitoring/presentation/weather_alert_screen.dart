import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/designsystem/components/green_title_header.dart';
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
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.weatherTitle, onBack: () => Navigator.pop(context)),
          Expanded(
            child: forecast.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: MuyuColors.forest),
                    const SizedBox(height: 12),
                    Text(l10n.weatherLoading, textAlign: TextAlign.center),
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
              data: (alert) => ListView(
                padding: const EdgeInsets.fromLTRB(21, 16, 21, 28),
                children: [
                  Text(
                    '${widget.plot.name} · ${widget.plot.crop.isEmpty ? '—' : widget.plot.crop}',
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 16,
                      color: Color(0x80000000),
                    ),
                  ),
                  Text(
                    l10n.weatherCycle(
                      widget.plot.cycle.isEmpty ? '${DateTime.now().year}' : widget.plot.cycle,
                    ),
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 16,
                      color: Color(0x80000000),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AlertCard(plot: widget.plot, alert: alert),
                  const SizedBox(height: 16),
                  Text(
                    l10n.weatherRecommendations,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w300,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MeasuresCard(
                    alert: alert,
                    plot: widget.plot,
                    selected: _selected,
                    saved: _saved,
                    saving: _saving,
                    validationError: _validationError,
                    onToggle: (measure) => setState(() {
                      _validationError = false;
                      _selected.contains(measure)
                          ? _selected.remove(measure)
                          : _selected.add(measure);
                    }),
                    onSave: () => _save(alert),
                  ),
                  if (alert.forecast.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ForecastCard(days: alert.forecast),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.plot, required this.alert});

  final FarmerPlot plot;
  final WeatherAlert alert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = alert.isFrost
        ? l10n.weatherFrost
        : alert.isRain
        ? (alert.risk == WeatherRisk.high ? l10n.weatherHeavyRain : l10n.weatherModerateRain)
        : l10n.weatherStable;
    final elevation = alert.elevationMeters == null ? '' : ' · ${alert.elevationMeters!.round()} m';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: MuyuColors.weatherCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Column(
        children: [
          Icon(_weatherIcon(alert), size: 70, color: MuyuColors.forest),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${plot.place.isEmpty ? plot.crop : plot.place}$elevation',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(value: '${alert.temperature.round()}°C', label: l10n.weatherEstTemp),
              _divider(),
              _Metric(
                value: alert.timing == WeatherTiming.tonight
                    ? l10n.weatherTonight
                    : l10n.weatherToday,
                label: l10n.weatherEstTime,
              ),
              _divider(),
              _Metric(value: _riskLabel(l10n, alert.risk), label: l10n.weatherRisk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 48, color: MuyuColors.forest.withValues(alpha: 0.35));
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 11),
        ),
      ],
    ),
  );
}

class _MeasuresCard extends StatelessWidget {
  const _MeasuresCard({
    required this.alert,
    required this.plot,
    required this.selected,
    required this.saved,
    required this.saving,
    required this.validationError,
    required this.onToggle,
    required this.onSave,
  });

  final WeatherAlert alert;
  final FarmerPlot plot;
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
    final showCheckboxes = alert.risk != WeatherRisk.low;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCheckboxes) ...[
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
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.weatherMeasuresConfirm),
              ),
          ] else
            for (final measure in alert.measures)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 18, color: MuyuColors.action),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_measureLabel(l10n, measure), style: MuyuTextStyles.body)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.days});

  final List<WeatherForecastDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: MuyuColors.statCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weatherForecast,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < days.length; i++)
                _ForecastDay(
                  day: days[i],
                  label: i == 0 ? l10n.weatherToday : DateFormat.E(locale).format(days[i].date),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForecastDay extends StatelessWidget {
  const _ForecastDay({required this.day, required this.label});

  final WeatherForecastDay day;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black.withValues(alpha: 0.5),
        ),
      ),
      const SizedBox(height: 8),
      Icon(_forecastIcon(day), size: 40, color: MuyuColors.forest),
      const SizedBox(height: 6),
      Text(
        '${day.maximumTemperature.round()}° / ${day.minimumTemperature.round()}°',
        style: const TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    ],
  );
}

IconData _weatherIcon(WeatherAlert alert) {
  if (alert.isFrost) return Icons.ac_unit;
  if (alert.rainProbability >= 70) return Icons.thunderstorm;
  if (alert.isRain) return Icons.water_drop;
  return _codeIcon(alert.weatherCode, alert.maximumTemperature, alert.minimumTemperature);
}

IconData _forecastIcon(WeatherForecastDay day) =>
    _codeIcon(day.weatherCode, day.maximumTemperature, day.minimumTemperature, day.rainProbability);

IconData _codeIcon(int code, double max, double min, [int rain = 0]) {
  if (code >= 95 || rain >= 75) return Icons.thunderstorm;
  if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82) || rain >= 55)
    return Icons.water_drop;
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86) || min <= 0) return Icons.ac_unit;
  if (code == 0 || max >= 30) return Icons.wb_sunny;
  if (code == 1 || code == 2 || max >= 24) return Icons.wb_cloudy;
  return Icons.cloud;
}

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
