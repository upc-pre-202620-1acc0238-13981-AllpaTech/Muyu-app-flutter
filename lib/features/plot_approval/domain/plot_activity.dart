/// Evidence and review state for one of the four financed-plot milestones.
class MilestoneState {
  const MilestoneState({
    required this.key,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.notes = '',
  });

  final String key;
  final String status;
  final String? submittedAt;
  final String? reviewedAt;
  final String notes;

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'submitted';

  factory MilestoneState.fromJson(Map<String, dynamic> json) => MilestoneState(
    key: json['key'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    submittedAt: _stringDate(json['submittedAt'] ?? json['submittedAtMillis']),
    reviewedAt: _stringDate(json['reviewedAt'] ?? json['reviewedAtMillis']),
    notes: json['notes'] as String? ?? json['reviewComment'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'status': status,
    'submittedAt': submittedAt,
    'reviewedAt': reviewedAt,
    'notes': notes,
  };
}

/// Measures recorded by a farmer after receiving a weather alert.
class WeatherMeasure {
  const WeatherMeasure({
    required this.alertKey,
    required this.measures,
    required this.attendedAt,
  });

  final String alertKey;
  final List<String> measures;
  final String attendedAt;

  factory WeatherMeasure.fromJson(Map<String, dynamic> json) => WeatherMeasure(
    alertKey: json['alertKey'] as String? ?? '',
    measures: (json['measures'] as List<dynamic>? ?? const []).whereType<String>().toList(),
    attendedAt: _stringDate(json['attendedAt']) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'alertKey': alertKey,
    'measures': measures,
    'attendedAt': attendedAt,
  };
}

String? _stringDate(Object? value) {
  if (value == null) return null;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toIso8601String();
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
