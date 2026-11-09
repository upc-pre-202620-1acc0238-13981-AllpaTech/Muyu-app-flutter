import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/plot_finance.dart';
import '../../domain/payment_record.dart';
import 'payment_history_view.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key, required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completed = payment.status == PaymentStatus.completed;
    final date = payment.date;
    return Scaffold(
      backgroundColor: MuyuColors.background,
      appBar: AppBar(
        backgroundColor: MuyuColors.navBar,
        foregroundColor: Colors.white,
        title: Text(l10n.paymentDetailsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MuyuColors.forest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: completed
                      ? MuyuColors.approvedBg
                      : MuyuColors.pendingBackground,
                  child: Icon(
                    completed ? Icons.check_circle : Icons.schedule,
                    size: 42,
                    color: MuyuColors.forest,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  PlotFinance.formatAmount(payment.amount),
                  style: MuyuTextStyles.headerTitle.copyWith(fontSize: 38),
                ),
                Text(
                  completed ? l10n.paymentsFilterCompleted : l10n.paymentsFilterPending,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paymentTransactionDetails, style: MuyuTextStyles.bodyBold),
                  const Divider(height: 28),
                  _DetailRow(
                    label: l10n.paymentLabelMilestone,
                    value: milestoneLabel(l10n, payment.milestoneIndex),
                  ),
                  _DetailRow(label: l10n.paymentLabelPlot, value: payment.plot.name),
                  _DetailRow(
                    label: l10n.paymentLabelDate,
                    value: completed && date != null
                        ? DateFormat.yMMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(date)
                        : l10n.paymentPendingDate,
                  ),
                  _DetailRow(
                    label: l10n.paymentLabelAmount,
                    value: PlotFinance.formatAmount(payment.amount),
                  ),
                  _DetailRow(label: l10n.paymentLabelTxid, value: payment.transactionId),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: MuyuColors.statCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: MuyuColors.forest),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.paymentEscrowExplanation)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: MuyuColors.textSecondary))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
