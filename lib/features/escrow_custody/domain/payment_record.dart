import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../../plot_approval/domain/plot_finance.dart';

enum PaymentStatus { completed, pending }

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.plot,
    required this.milestone,
    required this.milestoneIndex,
    required this.amount,
    required this.status,
  });

  final String id;
  final FarmerPlot plot;
  final MilestoneState milestone;
  final int milestoneIndex;
  final double amount;
  final PaymentStatus status;

  DateTime? get date => DateTime.tryParse(
    status == PaymentStatus.completed
        ? milestone.reviewedAt ?? milestone.submittedAt ?? ''
        : milestone.submittedAt ?? '',
  );

  String get transactionId => 'MY-${plot.id}-${milestone.key.toUpperCase()}';
}

List<PaymentRecord> paymentsFromPlot(FarmerPlot plot) {
  final amounts = PlotFinance.disbursement(PlotFinance.parseAmount(plot.amount));
  return plot.milestoneStates.indexed
      .where((entry) => entry.$2.isApproved || entry.$2.isPending)
      .map((entry) {
        final index = entry.$1.clamp(0, amounts.length - 1);
        final milestone = entry.$2;
        return PaymentRecord(
          id: '${plot.id}:${milestone.key}',
          plot: plot,
          milestone: milestone,
          milestoneIndex: index,
          amount: amounts[index],
          status: milestone.isApproved ? PaymentStatus.completed : PaymentStatus.pending,
        );
      })
      .toList();
}
