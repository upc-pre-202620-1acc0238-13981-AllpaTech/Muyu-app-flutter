import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../plot_approval/domain/plot_status_label.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../labor_execution/application/milestone_evidence_service.dart';
import '../../../labor_execution/presentation/milestone_widgets.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/farmer_plot_repository.dart';
import '../../../plot_approval/domain/plot_activity.dart';
import '../../../plot_approval/domain/plot_finance.dart';
import '../harvest/harvest_delivery_screens.dart';

/// A funded plot as the merchant follows it: progress and the milestones
/// waiting for review, as Kotlin `MerchantPlotDetailScreen` for funded plots.
class MerchantFundedPlotScreen extends StatefulWidget {
  const MerchantFundedPlotScreen({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  State<MerchantFundedPlotScreen> createState() => _MerchantFundedPlotScreenState();
}

class _MerchantFundedPlotScreenState extends State<MerchantFundedPlotScreen> {
  late FarmerPlot plot = widget.plot;

  Future<void> _review(MilestoneState milestone) async {
    final updated = await Navigator.of(context).push<FarmerPlot>(
      MaterialPageRoute(
        builder: (_) => MilestoneEvidenceReviewScreen(plot: plot, milestoneKey: milestone.key),
      ),
    );
    if (updated != null && mounted) setState(() => plot = updated);
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: plot.name, onBack: () => Navigator.pop(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MuyuColors.navBar,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plot.crop} · ${plot.area} · ${plot.place}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(plot.amount, style: MuyuTextStyles.headerTitle),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: plot.progress / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          color: MuyuColors.lime,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${es ? 'Etapa' : 'Stage'}: ${plotStageLabel(plot.stage, es: es)} · ${plot.progress}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MilestonePlanCard(
                  milestones: plot.milestoneStates,
                  actionLabel: (milestone) =>
                      milestone.isSubmitted ? (es ? 'Revisar evidencia' : 'Review evidence') : null,
                  onAction: _review,
                ),
                const SizedBox(height: 16),
                HarvestDeliveryCard(
                  plot: plot,
                  onChanged: (updated) => setState(() => plot = updated),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The merchant reviews one milestone's evidence and approves it, releasing its
/// payment, or rejects it with a reason, as the Kotlin review screens do.
class MilestoneEvidenceReviewScreen extends ConsumerStatefulWidget {
  const MilestoneEvidenceReviewScreen({super.key, required this.plot, required this.milestoneKey});

  final FarmerPlot plot;
  final String milestoneKey;

  @override
  ConsumerState<MilestoneEvidenceReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<MilestoneEvidenceReviewScreen> {
  bool _sending = false;
  String? _error;

  bool get _es => Localizations.localeOf(context).languageCode == 'es';

  String get _releaseAmount {
    final index = MilestoneState.planKeys.indexOf(widget.milestoneKey);
    final steps = PlotFinance.disbursement(PlotFinance.parseAmount(widget.plot.amount));
    return PlotFinance.formatAmount(index < 0 ? 0 : steps[index]);
  }

  Future<void> _approve() async {
    final es = _es;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(es ? '¿Aprobar este hito?' : 'Approve this milestone?'),
        content: Text(
          es
              ? 'Se liberarán $_releaseAmount de la custodia al agricultor.'
              : '$_releaseAmount will be released from escrow to the farmer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(es ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(es ? 'Aprobar y liberar' : 'Approve and release'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _submit(approved: true);
  }

  Future<void> _reject() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _RejectReasonSheet(),
    );
    if (reason != null && reason.trim().isNotEmpty) await _submit(approved: false, reason: reason);
  }

  Future<void> _submit({required bool approved, String reason = ''}) async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(milestoneEvidenceServiceProvider)
          .review(
            plot: widget.plot,
            milestoneKey: widget.milestoneKey,
            approved: approved,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? (_es ? 'Hito aprobado. Pago liberado.' : 'Milestone approved. Payment released.')
                : (_es ? 'Se pidió una corrección al agricultor.' : 'A correction was requested.'),
          ),
        ),
      );
      Navigator.of(context).pop(updated);
    } on PlotException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error.failure == PlotFailure.network
            ? (_es ? 'Sin conexión. Inténtalo de nuevo.' : 'No connection. Try again.')
            : (_es ? 'No se pudo guardar la revisión.' : 'The review could not be saved.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = _es;
    final milestone = widget.plot.milestone(widget.milestoneKey);
    final latitude = milestone?.latitude;
    final longitude = milestone?.longitude;
    final rows = <String, String>{
      es ? 'Insumo' : 'Input': milestone?.inputUsed ?? '',
      es ? 'Cantidad' : 'Amount': milestone?.amountApplied ?? '',
      es ? 'Fecha' : 'Date': milestone?.recordedAt ?? '',
      'GPS': latitude == null || longitude == null
          ? ''
          : '${formatCoordinates(latitude, longitude)}'
                '${milestone?.accuracyMeters == null ? '' : ' (±${milestone!.accuracyMeters} m)'}',
      es ? 'Notas' : 'Notes': milestone?.notes ?? '',
    };
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Revisar evidencia' : 'Review evidence',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${widget.plot.name} · ${MilestoneState.title(widget.milestoneKey, es: es)}',
                  style: MuyuTextStyles.bodyBold,
                ),
                const SizedBox(height: 12),
                EvidencePhoto(uri: milestone?.photoUri ?? ''),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: MuyuColors.forest),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      for (final row in rows.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  row.key,
                                  style: const TextStyle(color: MuyuColors.mutedFooter),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  row.value.isEmpty ? '—' : row.value,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MuyuColors.statCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    es
                        ? 'Al aprobar se liberan $_releaseAmount de la custodia.'
                        : 'Approving releases $_releaseAmount from escrow.',
                    style: const TextStyle(color: MuyuColors.forest),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _sending || milestone?.isSubmitted != true ? null : _approve,
                  child: _sending
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(es ? 'Aprobar hito' : 'Approve milestone'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _sending || milestone?.isSubmitted != true ? null : _reject,
                  style: OutlinedButton.styleFrom(foregroundColor: MuyuColors.dangerMessage),
                  child: Text(es ? 'Pedir corrección' : 'Request correction'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  int? _choice;
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final presets = [
      es
          ? 'La foto no muestra el trabajo con claridad'
          : 'The photo does not clearly show the work',
      es
          ? 'El insumo o la cantidad no coinciden con el plan'
          : 'The input or amount does not match the plan',
    ];
    final reason = _choice == null
        ? ''
        : _choice! < presets.length
        ? presets[_choice!]
        : _other.text.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            es ? 'Motivo de la corrección' : 'Reason for the correction',
            style: MuyuTextStyles.bodyBold,
          ),
          const SizedBox(height: 8),
          RadioGroup<int>(
            groupValue: _choice,
            onChanged: (value) => setState(() => _choice = value),
            child: Column(
              children: [
                for (final (index, text) in presets.indexed)
                  RadioListTile<int>(
                    value: index,
                    title: Text(text),
                    contentPadding: EdgeInsets.zero,
                  ),
                RadioListTile<int>(
                  value: presets.length,
                  title: Text(es ? 'Otro motivo' : 'Other reason'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          if (_choice == presets.length)
            TextField(
              controller: _other,
              autofocus: true,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: es ? 'Explica qué debe corregir' : 'Explain what to correct',
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: reason.isEmpty ? null : () => Navigator.pop(context, reason),
              child: Text(es ? 'Enviar al agricultor' : 'Send to the farmer'),
            ),
          ),
        ],
      ),
    );
  }
}
