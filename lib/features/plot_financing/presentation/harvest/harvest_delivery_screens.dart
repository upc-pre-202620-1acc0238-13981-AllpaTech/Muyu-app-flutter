import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/farmer_plot_repository.dart';
import '../../../plot_approval/domain/harvest_delivery.dart';
import '../../application/harvest_delivery_service.dart';

const _minIncidentDetail = 10;

/// The harvest delivery of a funded plot for the merchant, as Kotlin
/// `HarvestDeliveryCard`. Hidden until the harvest milestone is approved.
class HarvestDeliveryCard extends StatelessWidget {
  const HarvestDeliveryCard({super.key, required this.plot, required this.onChanged});

  final FarmerPlot plot;
  final ValueChanged<FarmerPlot> onChanged;

  Future<void> _open(BuildContext context, Widget screen) async {
    final updated = await Navigator.of(context)
        .push<FarmerPlot>(MaterialPageRoute(builder: (_) => screen));
    if (updated != null) onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final state = plot.harvestDeliveryState;
    if (state == HarvestDeliveryState.notReady) return const SizedBox.shrink();
    final es = Localizations.localeOf(context).languageCode == 'es';
    final incidents = plot.harvestIncidents;
    final body = switch (state) {
      HarvestDeliveryState.received =>
        es
            ? 'Confirmaste la recepción el ${plot.harvestReceivedAt}. El acuerdo quedó cerrado.'
            : 'You confirmed receipt on ${plot.harvestReceivedAt}. The agreement is closed.',
      HarvestDeliveryState.withIncident =>
        '${HarvestIncident.reasonLabel(incidents.last.reason, es: es)}: ${incidents.last.details}',
      _ =>
        es
            ? 'El agricultor terminó la cosecha. Confirma cuando la recibas o reporta un problema.'
            : 'The farmer finished the harvest. Confirm when you receive it or report a problem.',
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MuyuColors.forest),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  es ? 'Entrega de la cosecha' : 'Harvest delivery',
                  style: MuyuTextStyles.bodyBold,
                ),
              ),
              HarvestStatusChip(state: state),
            ],
          ),
          const SizedBox(height: 8),
          Text(body),
          const SizedBox(height: 12),
          if (state == HarvestDeliveryState.received)
            OutlinedButton(
              onPressed: () => _open(context, HarvestReceiptScreen(plot: plot)),
              child: Text(es ? 'Ver cierre' : 'View closing'),
            )
          else ...[
            FilledButton(
              onPressed: () => _open(context, HarvestReceiptScreen(plot: plot)),
              child: Text(es ? 'Confirmar recepción' : 'Confirm receipt'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _open(context, HarvestIncidentScreen(plot: plot)),
              style: OutlinedButton.styleFrom(foregroundColor: MuyuColors.dangerMessage),
              child: Text(es ? 'Reportar un problema' : 'Report a problem'),
            ),
          ],
        ],
      ),
    );
  }
}

class HarvestStatusChip extends StatelessWidget {
  const HarvestStatusChip({super.key, required this.state});
  final HarvestDeliveryState state;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final (label, background, foreground) = switch (state) {
      HarvestDeliveryState.received => (
        es ? 'Recibida' : 'Received',
        MuyuColors.approvedBg,
        MuyuColors.forest,
      ),
      HarvestDeliveryState.withIncident => (
        es ? 'Con incidencia' : 'With incident',
        MuyuColors.pendingBackground,
        MuyuColors.pendingText,
      ),
      _ => (
        es ? 'Por recibir' : 'To receive',
        MuyuColors.pendingBackground,
        MuyuColors.pendingText,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// US30: the merchant checks the delivery data and confirms the harvest.
class HarvestReceiptScreen extends ConsumerStatefulWidget {
  const HarvestReceiptScreen({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  ConsumerState<HarvestReceiptScreen> createState() => _HarvestReceiptScreenState();
}

class _HarvestReceiptScreenState extends ConsumerState<HarvestReceiptScreen> {
  late FarmerPlot _plot = widget.plot;
  bool _agreed = false;
  bool _saving = false;
  String? _error;

  Future<void> _confirm() async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ref.read(harvestDeliveryServiceProvider).confirmReceipt(_plot);
      if (mounted) {
        setState(() {
          _plot = updated;
          _saving = false;
        });
      }
    } on PlotException {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = es
              ? 'No se pudo confirmar. Inténtalo de nuevo.'
              : 'It could not be confirmed. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final received = _plot.harvestReceivedAt.isNotEmpty;
    final harvest = _plot.milestone('harvest');
    final rows = <String, String>{
      es ? 'Parcela' : 'Plot': _plot.name,
      es ? 'Cultivo' : 'Crop': '${_plot.crop} · ${_plot.area}',
      es ? 'Agricultor' : 'Farmer': _plot.ownerName,
      es ? 'Fecha de cosecha' : 'Harvest date': (harvest?.recordedAt.isNotEmpty ?? false)
          ? harvest!.recordedAt
          : _plot.harvestDate,
      if (harvest?.amountApplied.isNotEmpty ?? false)
        es ? 'Cantidad' : 'Quantity': harvest!.amountApplied,
      if (harvest?.notes.isNotEmpty ?? false) es ? 'Notas' : 'Notes': harvest!.notes,
      es ? 'Monto financiado' : 'Funded amount': _plot.amount,
      if (received) es ? 'Recibida el' : 'Received on': _plot.harvestReceivedAt,
    };
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Recepción de la cosecha' : 'Harvest receipt',
            onBack: () => Navigator.pop(context, _plot),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (received)
                  _Notice(
                    color: MuyuColors.approvedBg,
                    textColor: MuyuColors.forest,
                    text: es
                        ? 'Cosecha recibida. El acuerdo con ${_plot.ownerName} quedó cerrado.'
                        : 'Harvest received. The agreement with ${_plot.ownerName} is closed.',
                  )
                else
                  Text(
                    es
                        ? 'Revisa los datos de la entrega. Confirma solo cuando tengas la cosecha contigo.'
                        : 'Check the delivery data. Confirm only when you have the harvest with you.',
                  ),
                const SizedBox(height: 16),
                _DataCard(rows: rows),
                if (_plot.harvestIncidents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _IncidentHistory(incidents: _plot.harvestIncidents),
                ],
                if (!received) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _agreed,
                    onChanged: _saving ? null : (value) => setState(() => _agreed = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      es
                          ? 'Recibí la cosecha y está conforme con el acuerdo.'
                          : 'I received the harvest and it matches the agreement.',
                    ),
                  ),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _agreed && !_saving ? _confirm : null,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(es ? 'Confirmar recepción' : 'Confirm receipt'),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _plot),
                    child: Text(es ? 'Volver a la parcela' : 'Back to the plot'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// US31: the merchant reports a delivery problem; the receipt stays pending.
class HarvestIncidentScreen extends ConsumerStatefulWidget {
  const HarvestIncidentScreen({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  ConsumerState<HarvestIncidentScreen> createState() => _HarvestIncidentScreenState();
}

class _HarvestIncidentScreenState extends ConsumerState<HarvestIncidentScreen> {
  String _reason = HarvestIncident.reasons.first;
  final _details = TextEditingController();
  bool _saving = false;
  bool _showDetailError = false;
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    if (_details.text.trim().length < _minIncidentDetail) {
      setState(() => _showDetailError = true);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(harvestDeliveryServiceProvider)
          .reportIncident(widget.plot, reason: _reason, details: _details.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            es
                ? 'Incidencia enviada a ${widget.plot.ownerName}.'
                : 'Incident sent to ${widget.plot.ownerName}.',
          ),
        ),
      );
      Navigator.of(context).pop(updated);
    } on PlotException {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = es
              ? 'No se pudo enviar. Inténtalo de nuevo.'
              : 'It could not be sent. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Reportar un problema' : 'Report a problem',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  es
                      ? 'Cuéntanos qué pasó con la cosecha de ${widget.plot.name}. La recepción quedará pendiente hasta resolverlo.'
                      : 'Tell us what happened with the harvest of ${widget.plot.name}. The receipt stays pending until it is solved.',
                ),
                const SizedBox(height: 16),
                Text(es ? 'Motivo' : 'Reason', style: MuyuTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final reason in HarvestIncident.reasons)
                      ChoiceChip(
                        label: Text(HarvestIncident.reasonLabel(reason, es: es)),
                        selected: _reason == reason,
                        onSelected: _saving ? null : (_) => setState(() => _reason = reason),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _details,
                  enabled: !_saving,
                  maxLines: 4,
                  onChanged: (_) {
                    if (_showDetailError) setState(() => _showDetailError = false);
                  },
                  decoration: InputDecoration(
                    labelText: es ? 'Detalle' : 'Details',
                    hintText: es
                        ? 'Describe el problema con la entrega'
                        : 'Describe the delivery problem',
                    errorText: _showDetailError
                        ? (es
                              ? 'Escribe al menos $_minIncidentDetail caracteres.'
                              : 'Write at least $_minIncidentDetail characters.')
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _send,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(es ? 'Enviar incidencia' : 'Send incident'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What the farmer sees once the merchant confirmed or reported a problem,
/// as Kotlin `FarmerHarvestNotice`.
class FarmerHarvestNotice extends StatelessWidget {
  const FarmerHarvestNotice({super.key, required this.plot});
  final FarmerPlot plot;

  @override
  Widget build(BuildContext context) {
    final state = plot.harvestDeliveryState;
    if (state != HarvestDeliveryState.received && state != HarvestDeliveryState.withIncident) {
      return const SizedBox.shrink();
    }
    final es = Localizations.localeOf(context).languageCode == 'es';
    final received = state == HarvestDeliveryState.received;
    final merchant = plot.harvestReceivedBy.isNotEmpty
        ? plot.harvestReceivedBy
        : (plot.fundedByEmail ?? '');
    final last = received ? null : plot.harvestIncidents.last;
    return _Notice(
      color: received ? MuyuColors.approvedBg : MuyuColors.pendingBackground,
      textColor: received ? MuyuColors.forest : MuyuColors.pendingText,
      title: received
          ? (es ? 'El comerciante recibió tu cosecha' : 'The merchant received your harvest')
          : (es
                ? 'El comerciante reportó una incidencia en la entrega'
                : 'The merchant reported a delivery incident'),
      text: received
          ? (es
                ? '$merchant confirmó la recepción el ${plot.harvestReceivedAt}. El acuerdo quedó cerrado.'
                : '$merchant confirmed receipt on ${plot.harvestReceivedAt}. The agreement is closed.')
          : '${HarvestIncident.reasonLabel(last!.reason, es: es)}: ${last.details}',
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.rows});
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
      children: [
        for (final row in rows.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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

class _IncidentHistory extends StatelessWidget {
  const _IncidentHistory({required this.incidents});
  final List<HarvestIncident> incidents;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MuyuColors.pendingBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            es
                ? '${incidents.length} incidencia(s) reportada(s)'
                : '${incidents.length} incident(s) reported',
            style: const TextStyle(color: MuyuColors.pendingText, fontWeight: FontWeight.w700),
          ),
          for (final incident in incidents) ...[
            const SizedBox(height: 6),
            Text(
              '${incident.reportedAt} · ${HarvestIncident.reasonLabel(incident.reason, es: es)}: ${incident.details}',
              style: const TextStyle(color: MuyuColors.pendingText),
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.color, required this.textColor, required this.text, this.title});

  final Color color;
  final Color textColor;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
        ],
        Text(text, style: TextStyle(color: textColor)),
      ],
    ),
  );
}
