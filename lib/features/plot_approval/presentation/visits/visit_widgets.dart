import 'package:flutter/material.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../domain/plot_visit.dart';

/// Status label for a visit, the same wording for farmer and merchant.
class VisitStatusChip extends StatelessWidget {
  const VisitStatusChip({super.key, required this.visit});
  final PlotVisit visit;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final (label, background, foreground) = visit.isCompleted
        ? visit.reachedAgreement
              ? (es ? 'Con acuerdo' : 'Agreement', MuyuColors.approvedBg, MuyuColors.forest)
              : (es ? 'Sin acuerdo' : 'No agreement', MuyuColors.pageGray, MuyuColors.mutedFooter)
        : visit.isConfirmed
        ? (es ? 'Confirmada' : 'Confirmed', MuyuColors.financedBackground, MuyuColors.financedText)
        : visit.isRejected
        ? (es ? 'Rechazada' : 'Declined', MuyuColors.dangerBackground, MuyuColors.dangerMessage)
        : (
            es ? 'Por responder' : 'Awaiting reply',
            MuyuColors.pendingBackground,
            MuyuColors.pendingText,
          );
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

/// Date, time, message and outcome of a visit.
class VisitSummary extends StatelessWidget {
  const VisitSummary({super.key, required this.visit, required this.counterpart});

  final PlotVisit visit;

  /// The other person: the merchant for the farmer, the farmer for the merchant.
  final String counterpart;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(counterpart, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            VisitStatusChip(visit: visit),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${visit.date} · ${visit.time}',
          style: const TextStyle(color: MuyuColors.mutedFooter),
        ),
        if (visit.message.isNotEmpty) ...[const SizedBox(height: 6), Text('“${visit.message}”')],
        if (visit.isCompleted && visit.reachedAgreement && visit.agreedPrice.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '${es ? 'Precio acordado' : 'Agreed price'}: ${visit.agreedPrice}',
            style: const TextStyle(color: MuyuColors.forest, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

String visitError(Object error, {required bool es}) => es
    ? 'No se pudo guardar. Revisa tu conexión e inténtalo de nuevo.'
    : 'It could not be saved. Check your connection and try again.';
