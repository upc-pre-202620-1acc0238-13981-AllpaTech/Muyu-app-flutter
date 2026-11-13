import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/plot_activity.dart';

/// Kotlin `MerchantMyPlotsSupport` helpers for funded merchant lists and detail.
extension MerchantPlotSupport on FarmerPlot {
  List<MilestoneState> get milestoneStatesOrSeed =>
      milestoneStates.isEmpty ? MilestoneState.seed() : milestoneStates;

  bool get needsMerchantReview => milestoneStatesOrSeed.any((item) => item.isSubmitted);

  MilestoneState? get submittedForReview =>
      milestoneStatesOrSeed.where((item) => item.isSubmitted).firstOrNull;

  MilestoneState? get nextPendingMilestone => milestoneStatesOrSeed
      .where((item) => item.status == MilestoneState.statusPending)
      .firstOrNull;

  String? get currentMilestoneLabelKey => submittedForReview?.key ?? nextPendingMilestone?.key;

  String get evidenceMilestoneKey =>
      submittedForReview?.key ??
      milestoneStatesOrSeed.where((item) => item.needsCorrection).firstOrNull?.key ??
      nextPendingMilestone?.key ??
      milestoneStatesOrSeed.where((item) => item.isApproved).lastOrNull?.key ??
      MilestoneState.planKeys.first;

  int get sortPriorityNeedsReview => needsMerchantReview ? 0 : 1;

  String get dueLabel {
    final milestone = submittedForReview ?? nextPendingMilestone;
    if (milestone == null) return '';
    final extension = milestone.raw['extensionDate'] as String? ?? '';
    if (extension.trim().isNotEmpty) return extension;
    return milestone.raw['dueLabel'] as String? ?? '';
  }
}
