import '../../domain/farmer_plot.dart';
import '../../domain/plot_activity.dart';

/// Display rules for the farmer's plot lists, from Kotlin `FarmerPlotListSupport.kt`.
extension FarmerPlotDisplay on FarmerPlot {
  /// Kotlin `isFundedPlot`: a merchant already financed it.
  bool get isFundedPlot => status == 'funded' || status == 'approved';

  int get approvedMilestoneCount => milestoneStates.where((item) => item.isApproved).length;

  /// The title of the milestone in progress, or null when the plot is not funded.
  String? stageTitle({required bool es}) {
    if (!isFundedPlot) return null;
    MilestoneState? current;
    for (final item in milestoneStates) {
      if (item.isQueued || item.isSubmitted) {
        current = item;
        break;
      }
    }
    current ??= milestoneStates.where((item) => item.needsCorrection).firstOrNull;
    current ??= milestoneStates
        .where((item) => item.status == MilestoneState.statusPending)
        .firstOrNull;
    return current == null ? null : MilestoneState.title(current.key, es: es);
  }

  /// Kotlin `hasHeavyRainRisk`: funded plots in Cusco get the rain warning.
  bool get hasHeavyRainRisk {
    final value = place.toLowerCase();
    return isFundedPlot && (value.contains('cusco') || value.contains('cuzco'));
  }

  /// Kotlin `matchesSearch`: name, crop, place or GPS coordinates.
  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [name, crop, place].any((value) => value.toLowerCase().contains(q)) ||
        [latitude, longitude].whereType<double>().any((value) => value.toString().contains(q));
  }
}

/// Kotlin `formatPlotArea`.
String formatPlotArea(String area) {
  final trimmed = area.trim();
  if (trimmed.isEmpty) return '—';
  if (trimmed.toLowerCase().contains('ha')) return trimmed;
  return '$trimmed ha';
}
