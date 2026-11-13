import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/application/plot_visits_controller.dart';
import '../../../plot_approval/domain/plot.dart';
import '../../../plot_approval/domain/plot_visit.dart';
import '../../../plot_approval/presentation/visits/visit_widgets.dart';
import '../../../user_management/application/session_controller.dart';

void openMerchantVisitFlow(BuildContext context, WidgetRef ref, Plot plot) {
  final email = ref.read(sessionProvider).user?.email.toLowerCase() ?? '';
  final latest = (ref.read(plotVisitsProvider).value ?? const <PlotVisit>[])
      .where((visit) => visit.plotId == plot.id && visit.merchantEmail.toLowerCase() == email)
      .firstOrNull;
  final Widget screen = latest != null && !latest.isRejected && !latest.isCompleted
      ? VisitSentScreen(visit: latest, plot: plot)
      : VisitRequestScreen(plot: plot);
  Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
}

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
              onPressed: () => openMerchantVisitFlow(context, ref, plot),
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
  static const _times = ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

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
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _cycleTime() {
    final next = (_times.indexOf(_time).clamp(0, _times.length - 1) + 1) % _times.length;
    setState(() => _time = _times[next]);
  }

  Future<void> _send() async {
    if (_sending || _time.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final visit = await ref
          .read(plotVisitsProvider.notifier)
          .request(plot: widget.plot, date: _date, time: _time, message: _message.text);
      if (!mounted) return;
      final backToPlot = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => VisitSentScreen(visit: visit, plot: widget.plot)),
      );
      if (mounted) {
        setState(() => _sending = false);
        if (backToPlot == true) Navigator.of(context).pop();
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = visitError(error, es: Localizations.localeOf(context).languageCode == 'es');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final plot = widget.plot;
    final subtitle = [plot.place, plot.ownerName].where((value) => value.trim().isNotEmpty).join(' · ');
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: l10n.merchantVisitRequestTitle,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _VisitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (plot.name.trim().isNotEmpty)
                        Text(
                          plot.name,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _VisitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.merchantVisitProposedDate,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: MuyuColors.skip,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _sending ? null : _pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat.yMMMd(locale).format(_date),
                                      style: const TextStyle(
                                        fontFamily: MuyuFonts.urbanist,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, size: 22, color: MuyuColors.forest),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.merchantVisitPreferredTime,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Material(
                        color: MuyuColors.skip,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: MuyuColors.action),
                        ),
                        child: InkWell(
                          onTap: _sending ? null : _cycleTime,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$_time  ▾',
                                  style: const TextStyle(
                                    fontFamily: MuyuFonts.urbanist,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.merchantVisitMessage,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _message,
                        enabled: !_sending,
                        maxLines: 4,
                        minLines: 3,
                        style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: l10n.merchantVisitMessageHint,
                          hintStyle: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: MuyuColors.skip,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MuyuColors.action),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MuyuColors.action),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MuyuColors.action, width: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.merchantVisitDisclaimer,
                  style: TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 13,
                      color: MuyuColors.dangerMessage,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _VisitPrimaryButton(
                  label: _sending ? l10n.merchantVisitSending : l10n.merchantVisitSend,
                  onTap: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisitSentScreen extends ConsumerWidget {
  const VisitSentScreen({super.key, required this.visit, required this.plot});

  final PlotVisit visit;
  final Plot plot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final latest = (ref.watch(plotVisitsProvider).value ?? const <PlotVisit>[])
            .where((item) => item.id == visit.id)
            .firstOrNull ??
        visit;
    final confirmed = latest.isConfirmed || latest.isCompleted;
    final farmer = latest.farmerName.trim().isNotEmpty ? latest.farmerName : plot.ownerName;
    final plotName = latest.plotName.trim().isNotEmpty ? latest.plotName : plot.name;
    final place = latest.plotPlace.trim().isNotEmpty ? latest.plotPlace : plot.place;

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: l10n.merchantVisitStatusTitle,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MuyuColors.skip,
                      shape: BoxShape.circle,
                      border: Border.all(color: MuyuColors.action),
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: MuyuColors.forest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  confirmed ? l10n.merchantVisitConfirmed : l10n.merchantVisitSent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: MuyuColors.forest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  confirmed
                      ? l10n.merchantVisitConfirmedBody(farmer)
                      : l10n.merchantVisitSentBody(farmer),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontSize: 14,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 16),
                _VisitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.merchantVisitToPlot(plotName),
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(l10n.merchantVisitDate, latest.date),
                      _SummaryRow(l10n.merchantVisitTime, latest.time),
                      _SummaryRow(l10n.merchantVisitPlace, place),
                      if (latest.message.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          latest.message,
                          style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                if (confirmed) ...[
                  const SizedBox(height: 12),
                  _VisitCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.merchantVisitMeetingPoint,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: MuyuColors.forest,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          place,
                          style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 14),
                        ),
                        Text(
                          l10n.merchantVisitMeetingHint,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MuyuColors.termsBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.merchantVisitCoordinationOnly,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 13,
                      color: Color(0xFF7A4B00),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _VisitPrimaryButton(
                  label: l10n.merchantVisitBackPlot,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 13, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitPrimaryButton extends StatelessWidget {
  const _VisitPrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MuyuColors.action,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
