import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/designsystem/components/muyu_controls.dart';
import '../../../../core/designsystem/components/plot_photo.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../../domain/farmer_plot_repository.dart';
import '../../domain/plot_status_label.dart';
import '../../../climate_monitoring/application/weather_controller.dart';
import '../../../climate_monitoring/presentation/weather_alert_screen.dart';
import '../../../labor_execution/application/evidence_queue.dart';
import '../../../labor_execution/application/milestone_evidence_service.dart';
import '../../../labor_execution/presentation/milestone_widgets.dart';
import '../../../labor_execution/presentation/record_evidence_screen.dart';
import '../visits/farmer_visits_card.dart';
import '../../../plot_financing/presentation/harvest/harvest_delivery_screens.dart';

class FarmerPlotDetailScreen extends ConsumerStatefulWidget {
  const FarmerPlotDetailScreen({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  ConsumerState<FarmerPlotDetailScreen> createState() => _FarmerPlotDetailScreenState();
}

class _FarmerPlotDetailScreenState extends ConsumerState<FarmerPlotDetailScreen> {
  late FarmerPlot plot = widget.plot;
  bool busy = false;
  bool failed = false;

  bool get es => Localizations.localeOf(context).languageCode == 'es';

  Future<void> edit() async {
    final updated = await Navigator.push<FarmerPlot>(
      context,
      MaterialPageRoute(builder: (_) => EditFarmerPlotScreen(plot: plot)),
    );
    if (updated == null || !mounted) return;
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      await ref.read(farmerPlotsProvider.notifier).updatePlot(updated);
      if (mounted) setState(() => plot = updated);
    } on PlotException {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> delete() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(es ? '¿Eliminar esta parcela?' : 'Delete this plot?'),
        content: Text(
          es
              ? 'Se eliminará del servidor y no se puede deshacer.'
              : 'It will be removed from the server and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(es ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MuyuColors.errorBorder),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(es ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      await ref.read(farmerPlotsProvider.notifier).delete(plot.id);
      if (mounted) Navigator.pop(context, true);
    } on PlotException {
      if (mounted) {
        setState(() {
          busy = false;
          failed = true;
        });
      }
    }
  }

  Future<void> recordEvidence(String milestoneKey) async {
    final result = await Navigator.of(context).push<EvidenceSubmission>(
      MaterialPageRoute(
        builder: (_) => RecordEvidenceScreen(plot: plot, milestoneKey: milestoneKey),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => plot = result.plot);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.queued
              ? (es
                    ? 'Sin señal: la evidencia quedó guardada y se enviará desde Sincronizar.'
                    : 'No signal: the evidence was saved and will be sent from Sync.')
              : (es ? 'Evidencia enviada al comerciante.' : 'Evidence sent to the merchant.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(evidenceQueueProvider);
    final shown = ref.read(evidenceQueueProvider.notifier).withQueued(plot);
    final editable = !plot.isFunded;
    final current = shown.currentMilestone;
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: plot.isFunded ? (es ? '${plot.name} parcela' : '${plot.name} plot') : plot.name,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                PlotPhoto(
                  source: plot.imageUri,
                  description: plot.name,
                  height: plot.isFunded ? 180 : 239,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(19, 16, 19, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Hero(plot: plot),
                      const SizedBox(height: 16),
                      _Card(
                        title: es ? 'Información de la parcela' : 'Plot information',
                        rows: {
                          es ? 'Cultivo' : 'Crop': plot.crop,
                          es ? 'Área' : 'Area': plot.area,
                          es ? 'Cosecha' : 'Harvest': plot.harvestDate,
                          es ? 'Ubicación' : 'Location': plot.place,
                          es ? 'Ciclo' : 'Cycle': plot.cycle,
                        },
                      ),
                      const SizedBox(height: 16),
                      _Card(
                        title: es ? 'Estado financiero' : 'Financial status',
                        rows: {
                          es ? 'Monto' : 'Amount': plot.amount,
                          es ? 'Etapa' : 'Stage': plot.stage,
                          es ? 'Progreso' : 'Progress': '${plot.progress}%',
                          es ? 'Hitos' : 'Milestones': plot.milestones,
                        },
                      ),
                      if (plot.isFunded && plot.milestoneStates.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        MilestonePlanCard(
                          milestones: shown.milestoneStates,
                          actionLabel: (milestone) => milestone.key == current?.key
                              ? (milestone.needsCorrection
                                    ? (es ? 'Corregir evidencia' : 'Correct evidence')
                                    : (es ? 'Registrar evidencia' : 'Record evidence'))
                              : null,
                          onAction: busy ? null : (milestone) => recordEvidence(milestone.key),
                        ),
                        const SizedBox(height: 16),
                        FarmerHarvestNotice(plot: plot),
                      ],
                      const SizedBox(height: 16),
                      FarmerVisitsCard(plotId: plot.id),
                      if (failed)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            es ? 'No se pudo completar la operación.' : 'The operation failed.',
                            style: const TextStyle(color: MuyuColors.errorBorder),
                          ),
                        ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(builder: (_) => WeatherAlertScreen(plot: plot)),
                        ),
                        icon: const Icon(Icons.cloud_outlined),
                        label: Text(es ? 'Ver alerta climática' : 'View weather alert'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (editable) ...[
                        FilledButton.icon(
                          onPressed: busy ? null : edit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(es ? 'Editar parcela' : 'Edit plot'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: busy ? null : delete,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(es ? 'Eliminar parcela' : 'Delete plot'),
                          style: OutlinedButton.styleFrom(foregroundColor: MuyuColors.errorBorder),
                        ),
                      ] else
                        Text(
                          es
                              ? 'Una parcela financiada ya no puede editarse ni eliminarse.'
                              : 'A funded plot can no longer be edited or deleted.',
                          textAlign: TextAlign.center,
                        ),
                      if (busy)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditFarmerPlotScreen extends StatefulWidget {
  const EditFarmerPlotScreen({super.key, required this.plot});
  final FarmerPlot plot;
  @override
  State<EditFarmerPlotScreen> createState() => _EditFarmerPlotScreenState();
}

class _EditFarmerPlotScreenState extends State<EditFarmerPlotScreen> {
  final form = GlobalKey<FormState>();
  late final controllers = <TextEditingController>[
    TextEditingController(text: widget.plot.name),
    TextEditingController(text: widget.plot.crop),
    TextEditingController(text: widget.plot.area),
    TextEditingController(text: widget.plot.harvestDate),
    TextEditingController(text: widget.plot.place),
    TextEditingController(text: widget.plot.amount),
    TextEditingController(text: widget.plot.cycle),
  ];
  bool get es => Localizations.localeOf(context).languageCode == 'es';

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = es
        ? ['Nombre', 'Cultivo', 'Área', 'Fecha de cosecha', 'Ubicación', 'Monto', 'Ciclo']
        : ['Name', 'Crop', 'Area', 'Harvest date', 'Location', 'Amount', 'Cycle'];
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Editar parcela' : 'Edit plot',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (var i = 0; i < controllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: controllers[i],
                        decoration: InputDecoration(
                          labelText: labels[i],
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? (es ? 'Campo obligatorio' : 'Required field')
                            : null,
                      ),
                    ),
                  FilledButton(
                    onPressed: () {
                      if (!form.currentState!.validate()) return;
                      Navigator.pop(
                        context,
                        widget.plot.copyWith(
                          name: controllers[0].text.trim(),
                          crop: controllers[1].text.trim(),
                          area: controllers[2].text.trim(),
                          harvestDate: controllers[3].text.trim(),
                          place: controllers[4].text.trim(),
                          amount: controllers[5].text.trim(),
                          cycle: controllers[6].text.trim(),
                        ),
                      );
                    },
                    child: Text(es ? 'Guardar cambios' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.plot});
  final FarmerPlot plot;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final weather = ref.watch(weatherAlertProvider(plot));
    final temperature = weather.value?.temperature;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PeruFlag(),
              const SizedBox(width: 8),
              Text(
                es ? 'PERÚ' : 'PERU',
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.of(context)
                    .push<void>(MaterialPageRoute(builder: (_) => WeatherAlertScreen(plot: plot))),
                child: Row(
                  children: [
                    const Icon(Icons.wb_cloudy_outlined, size: 30, color: MuyuColors.action),
                    const SizedBox(width: 6),
                    Text(
                      temperature == null ? '—°C' : '${temperature.round()}°C',
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
                child: Text(
                  plot.name,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w600,
                    fontSize: 21,
                    color: MuyuColors.forest,
                  ),
                ),
              ),
              Container(
                height: 23,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: plot.isFunded ? MuyuColors.financedBackground : MuyuColors.approvedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plotStatusLabel(plot.status, es: es),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: plot.isFunded ? MuyuColors.financedText : MuyuColors.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${plot.crop} · ${plot.area} · ${plot.place}',
            style: const TextStyle(fontSize: 16, color: Color(0x80000000)),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: plot.progress.clamp(0, 100) / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: MuyuColors.action,
            backgroundColor: MuyuColors.skip,
          ),
          const SizedBox(height: 6),
          Text(
            '${plot.progress}% · ${plotStageLabel(plot.stage, es: es)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.rows});
  final String title;
  final Map<String, String> rows;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: MuyuColors.forest),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MuyuTextStyles.bodyBold),
        const SizedBox(height: 10),
        for (final row in rows.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(row.key, style: const TextStyle(color: MuyuColors.mutedFooter)),
                ),
                Expanded(
                  child: Text(row.value.isEmpty ? '—' : row.value, textAlign: TextAlign.end),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
