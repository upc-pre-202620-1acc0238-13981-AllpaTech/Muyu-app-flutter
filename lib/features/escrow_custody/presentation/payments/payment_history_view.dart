import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/plot_finance.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/domain/user.dart';
import '../../application/payment_history_controller.dart';
import '../../domain/payment_record.dart';
import 'payment_details_screen.dart';

enum _PaymentFilter { all, completed, pending }

class PaymentHistoryView extends ConsumerStatefulWidget {
  const PaymentHistoryView({super.key, this.bottomInset = 120});

  final double bottomInset;

  @override
  ConsumerState<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends ConsumerState<PaymentHistoryView> {
  _PaymentFilter _filter = _PaymentFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(sessionProvider).role;
    final history = ref.watch(paymentHistoryProvider);
    return RefreshIndicator(
      color: MuyuColors.forest,
      onRefresh: () async {
        ref.invalidate(paymentHistoryProvider);
        await ref.read(paymentHistoryProvider.future);
      },
      child: history.when(
        loading: () => const _ScrollableMessage(child: CircularProgressIndicator()),
        error: (_, _) => _ScrollableMessage(
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(paymentHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.plotsRetry),
          ),
        ),
        data: (all) {
          final completed = all.where((item) => item.status == PaymentStatus.completed).toList();
          final visible = all.where((item) => switch (_filter) {
            _PaymentFilter.all => true,
            _PaymentFilter.completed => item.status == PaymentStatus.completed,
            _PaymentFilter.pending => item.status == PaymentStatus.pending,
          }).toList();
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 20, 24, widget.bottomInset),
            children: [
              _SummaryCard(
                label: role == UserRole.merchant
                    ? l10n.paymentsTotalReleased
                    : l10n.paymentsTotalReceived,
                amount: PlotFinance.formatAmount(
                  completed.fold<double>(0, (sum, item) => sum + item.amount),
                ),
                count: l10n.paymentsCompletedCount(completed.length),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                children: [
                  for (final (filter, label) in [
                    (_PaymentFilter.all, l10n.paymentsFilterAll),
                    (_PaymentFilter.completed, l10n.paymentsFilterCompleted),
                    (_PaymentFilter.pending, l10n.paymentsFilterPending),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: MuyuColors.forest,
                      labelStyle: TextStyle(
                        color: _filter == filter ? Colors.white : MuyuColors.forest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              if (visible.isEmpty)
                _EmptyPayments(title: l10n.paymentsEmptyTitle, body: l10n.paymentsEmptyBody)
              else
                for (final payment in visible) ...[
                  _PaymentCard(
                    payment: payment,
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(builder: (_) => PaymentDetailsScreen(payment: payment)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.amount, required this.count});
  final String label;
  final String amount;
  final String count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: MuyuColors.forest,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(amount, style: MuyuTextStyles.headerTitle.copyWith(fontSize: 34)),
        Text(count, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.onTap});
  final PaymentRecord payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completed = payment.status == PaymentStatus.completed;
    final date = payment.date;
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: completed ? MuyuColors.approvedBg : MuyuColors.pendingBackground,
                child: Icon(completed ? Icons.check : Icons.schedule, color: MuyuColors.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.plot.name, style: MuyuTextStyles.bodyBold),
                    Text(milestoneLabel(l10n, payment.milestoneIndex)),
                    Text(
                      completed && date != null
                          ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date)
                          : l10n.paymentPendingDate,
                      style: const TextStyle(color: MuyuColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(PlotFinance.formatAmount(payment.amount), style: MuyuTextStyles.bodyBold),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPayments extends StatelessWidget {
  const _EmptyPayments({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 42),
    child: Column(
      children: [
        const Icon(Icons.savings_outlined, size: 64, color: MuyuColors.forest),
        const SizedBox(height: 14),
        Text(title, style: MuyuTextStyles.bodyBold),
        const SizedBox(height: 6),
        Text(body, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [SizedBox(height: MediaQuery.sizeOf(context).height * .3), Center(child: child)],
  );
}

String milestoneLabel(AppLocalizations l10n, int index) => switch (index) {
  0 => l10n.paymentMilestonePlanting,
  1 => l10n.paymentMilestoneIrrigation,
  2 => l10n.paymentMilestoneFertilization,
  _ => l10n.paymentMilestoneHarvest,
};
