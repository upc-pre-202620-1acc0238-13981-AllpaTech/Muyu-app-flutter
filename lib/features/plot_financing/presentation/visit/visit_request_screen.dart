import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/application/plot_visits_controller.dart';
import '../../../plot_approval/domain/plot.dart';
import '../../../plot_approval/presentation/visits/visit_widgets.dart';
import '../../../user_management/application/session_controller.dart';

/// The merchant's visit to a plot: its latest request and the button to ask
/// for one, shown on the plot details as in Kotlin `AvailablePlotScreen`.
class MerchantVisitPanel extends ConsumerWidget {
  const MerchantVisitPanel({super.key, required this.plot});
  final Plot plot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final email = ref.watch(sessionProvider).user?.email.toLowerCase() ?? '';
    final visits = ref.watch(plotVisitsProvider);
    final mine = (visits.value ?? const [])
        .where((visit) => visit.plotId == plot.id && visit.merchantEmail.toLowerCase() == email)
        .toList();
    final latest = mine.isEmpty ? null : mine.first;
    final canRequest = latest == null || latest.isRejected || latest.isCompleted;

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
          Text(es ? 'Visita a la parcela' : 'Plot visit', style: MuyuTextStyles.bodyBold),
          const SizedBox(height: 8),
          if (visits.isLoading && !visits.hasValue)
            const Center(child: CircularProgressIndicator())
          else if (latest != null)
            VisitSummary(visit: latest, counterpart: latest.farmerName)
          else
            Text(
              es
                  ? 'Conoce la parcela antes de financiarla. El agricultor confirmará la fecha.'
                  : 'See the plot before funding it. The farmer will confirm the date.',
              style: const TextStyle(color: MuyuColors.mutedFooter),
            ),
          if (canRequest) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context)
                  .push<void>(MaterialPageRoute(builder: (_) => VisitRequestScreen(plot: plot))),
              icon: const Icon(Icons.event_outlined),
              label: Text(es ? 'Solicitar visita' : 'Request a visit'),
            ),
          ],
        ],
      ),
    );
  }
}

/// The merchant proposes a date, time and message, as Kotlin `MerchantVisitRequestScreen`.
class VisitRequestScreen extends ConsumerStatefulWidget {
  const VisitRequestScreen({super.key, required this.plot});
  final Plot plot;

  @override
  ConsumerState<VisitRequestScreen> createState() => _VisitRequestScreenState();
}

class _VisitRequestScreenState extends ConsumerState<VisitRequestScreen> {
  static const _times = ['08:00', '09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00'];

  late DateTime _date = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 7));
  String _time = '10:00';
  final _message = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _send() async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(plotVisitsProvider.notifier)
          .request(plot: widget.plot, date: _date, time: _time, message: _message.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            es
                ? 'Solicitud enviada. El agricultor confirmará la visita.'
                : 'Request sent. The farmer will confirm the visit.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = visitError(error, es: es);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Solicitar visita' : 'Request a visit',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('${widget.plot.name} · ${widget.plot.place}', style: MuyuTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  '${es ? 'Agricultor' : 'Farmer'}: ${widget.plot.ownerName}',
                  style: const TextStyle(color: MuyuColors.mutedFooter),
                ),
                const SizedBox(height: 20),
                Text(es ? 'Fecha propuesta' : 'Proposed date', style: MuyuTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _sending ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(DateFormat.yMMMMd(locale).format(_date)),
                ),
                const SizedBox(height: 16),
                Text(es ? 'Hora preferida' : 'Preferred time', style: MuyuTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final time in _times)
                      ChoiceChip(
                        label: Text(time),
                        selected: _time == time,
                        onSelected: _sending ? null : (_) => setState(() => _time = time),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _message,
                  enabled: !_sending,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: es
                        ? 'Mensaje para el agricultor (opcional)'
                        : 'Message to the farmer (optional)',
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
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(es ? 'Enviar solicitud' : 'Send request'),
                ),
                const SizedBox(height: 8),
                Text(
                  es
                      ? 'La visita no compromete el financiamiento. Sirve para conocer la parcela y acordar un precio.'
                      : 'The visit does not commit you to fund. It helps you see the plot and agree on a price.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: MuyuColors.mutedFooter),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
