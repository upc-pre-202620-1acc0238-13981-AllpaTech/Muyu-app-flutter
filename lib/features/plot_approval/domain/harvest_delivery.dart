/// Where the harvest delivery of a funded plot stands (Kotlin US30 and US31).
enum HarvestDeliveryState { notReady, pending, withIncident, received }

/// A delivery problem the merchant reports, with the fields of Kotlin `HarvestIncident`.
class HarvestIncident {
  const HarvestIncident({
    required this.reason,
    required this.details,
    required this.reportedAt,
    required this.reportedAtMillis,
    required this.reportedBy,
  });

  static const List<String> reasons = ['not_delivered', 'incomplete', 'quality', 'late', 'other'];

  final String reason;
  final String details;

  /// `12 Nov 2026, 14:05`, as Kotlin `PlotFinance.timestampNow`.
  final String reportedAt;
  final int reportedAtMillis;
  final String reportedBy;

  static String reasonLabel(String reason, {required bool es}) => switch (reason) {
    'not_delivered' => es ? 'No llegó' : 'Not delivered',
    'incomplete' => es ? 'Cantidad incompleta' : 'Incomplete quantity',
    'quality' => es ? 'Problema de calidad' : 'Quality issue',
    'late' => es ? 'Entrega tardía' : 'Late delivery',
    _ => es ? 'Otro' : 'Other',
  };

  factory HarvestIncident.fromJson(Map<String, dynamic> json) => HarvestIncident(
    reason: json['reason'] as String? ?? 'other',
    details: json['details'] as String? ?? '',
    reportedAt: json['reportedAt'] as String? ?? '',
    reportedAtMillis: (json['reportedAtMillis'] as num?)?.toInt() ?? 0,
    reportedBy: json['reportedBy'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'reason': reason,
    'details': details,
    'reportedAt': reportedAt,
    'reportedAtMillis': reportedAtMillis,
    'reportedBy': reportedBy,
  };
}
