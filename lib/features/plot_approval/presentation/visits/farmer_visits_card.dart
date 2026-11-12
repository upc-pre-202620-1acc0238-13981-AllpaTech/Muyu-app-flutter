import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../application/plot_visits_controller.dart';
import '../../domain/plot_visit.dart';
import 'visit_widgets.dart';

/// Visit requests for one of the farmer's plots, as Kotlin `VisitRequestsScreen`:
/// accept or decline a request, then record the outcome of a confirmed visit.
class FarmerVisitsCard extends ConsumerStatefulWidget {
  const FarmerVisitsCard({super.key, required this.plotId});
  final int plotId;

  @override
  ConsumerState<FarmerVisitsCard> createState() => _FarmerVisitsCardState();
}

class _FarmerVisitsCardState extends ConsumerState<FarmerVisitsCard> {
  int? _busyId;
  String? _error;

  Future<void> _answer(PlotVisit visit, bool accepted) async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    setState(() {
      _busyId = visit.id;
      _error = null;
    });
    try {
      await ref.read(plotVisitsProvider.notifier).answer(visit, accepted: accepted);
    } on Exception catch (error) {
      if (mounted) setState(() => _error = visitError(error, es: es));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final state = ref.watch(plotVisitsProvider);
    final visits = (state.value ?? const <PlotVisit>[])
        .where((visit) => visit.plotId == widget.plotId)
        .toList();
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
          Text(es ? 'Solicitudes de visita' : 'Visit requests', style: MuyuTextStyles.bodyBold),
          const SizedBox(height: 8),
          if (state.isLoading && !state.hasValue)
            const Center(child: CircularProgressIndicator())
          else if (state.hasError && !state.hasValue)
            Row(
              children: [
                Expanded(
                  child: Text(
                    es ? 'No se pudieron cargar las visitas.' : 'Visits could not be loaded.',
                    style: const TextStyle(color: MuyuColors.mutedFooter),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(plotVisitsProvider),
                  child: Text(es ? 'Reintentar' : 'Retry'),
                ),
              ],
            )
          else if (visits.isEmpty)
            Text(
              es ? 'Todavía no hay solicitudes de visita.' : 'No visit requests yet.',
              style: const TextStyle(color: MuyuColors.mutedFooter),
            )
          else
            for (final (index, visit) in visits.indexed) ...[
              if (index > 0) const Divider(height: 24),
              VisitSummary(visit: visit, counterpart: visit.merchantName),
              if (visit.isRequested) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busyId == null ? () => _answer(visit, false) : null,
                        style: OutlinedButton.styleFrom(foregroundColor: MuyuColors.dangerMessage),
                        child: Text(es ? 'Rechazar' : 'Decline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busyId == null ? () => _answer(visit, true) : null,
                        child: Text(es ? 'Aceptar' : 'Accept'),
                      ),
                    ),
                  ],
                ),
              ] else if (visit.isConfirmed && !visit.isCompleted) ...[
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).push<void>(MaterialPageRoute(builder: (_) => VisitOutcomeScreen(visit: visit))),
                  child: Text(es ? 'Registrar resultado' : 'Record outcome'),
                ),
              ],
            ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
          ],
        ],
      ),
    );
  }
}

/// The farmer records whether the visit ended in an agreement and at what price,
/// as Kotlin `VisitOutcomeScreen`.
class VisitOutcomeScreen extends ConsumerStatefulWidget {
  const VisitOutcomeScreen({super.key, required this.visit});
  final PlotVisit visit;

  @override
  ConsumerState<VisitOutcomeScreen> createState() => _VisitOutcomeScreenState();
}

class _VisitOutcomeScreenState extends ConsumerState<VisitOutcomeScreen> {
  bool? _agreement;
  final _price = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  bool get _ready =>
      !_saving && _agreement != null && (_agreement == false || _price.text.trim().isNotEmpty);

  Future<void> _save() async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(plotVisitsProvider.notifier)
          .recordOutcome(widget.visit, agreement: _agreement!, agreedPrice: _price.text);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = visitError(error, es: es);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final visit = widget.visit;
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Resultado de la visita' : 'Visit outcome',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(visit.plotName, style: MuyuTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  '${visit.merchantName} · ${visit.date} · ${visit.time}',
                  style: const TextStyle(color: MuyuColors.mutedFooter),
                ),
                const SizedBox(height: 20),
                RadioGroup<bool>(
                  groupValue: _agreement,
                  onChanged: (value) {
                    if (!_saving) setState(() => _agreement = value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        value: true,
                        title: Text(es ? 'Llegamos a un acuerdo' : 'We reached an agreement'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool>(
                        value: false,
                        title: Text(es ? 'No hubo acuerdo' : 'No agreement'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                if (_agreement == true) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _price,
                    enabled: !_saving,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: es ? 'Precio acordado' : 'Agreed price',
                      hintText: es ? 'Ej. S/ 1.20 por kg' : 'e.g. S/ 1.20 per kg',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _ready ? _save : null,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(es ? 'Guardar resultado' : 'Save outcome'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
