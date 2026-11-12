/// Evidence and review state for one of the four financed-plot milestones.
class MilestoneState {
  const MilestoneState({
    required this.key,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.notes = '',
    this.raw = const {},
  });

  /// Milestone keys in the order Kotlin's `MilestoneCatalog` uses.
  static const List<String> planKeys = ['planting', 'irrigation', 'fertilization', 'harvest'];

  /// The plan a plot gets when it is funded, matching Kotlin `MilestoneCatalog.seed`:
  /// every milestone pending, with the empty evidence fields Kotlin expects.
  static List<MilestoneState> seed() => [
    for (final key in planKeys)
      MilestoneState(
        key: key,
        status: 'pending',
        raw: const {
          'dueLabel': '',
          'photoUri': '',
          'inputUsed': '',
          'amountApplied': '',
          'notes': '',
          'recordedAt': '',
          'submittedAtMillis': 0,
          'latitude': null,
          'longitude': null,
          'accuracyMeters': null,
          'extensionDate': '',
          'extensionReason': '',
        },
      ),
  ];

  final String key;
  final String status;
  final String? submittedAt;
  final String? reviewedAt;
  final String notes;

  /// Every field read from the backend, including the evidence photo, GPS and
  /// inputs Kotlin records. Writing it back keeps a Flutter update from erasing them.
  final Map<String, dynamic> raw;

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'submitted';
  bool get isSubmitted => status == statusSubmitted;
  bool get needsCorrection => status == statusNeedsCorrection;

  /// Kotlin `MilestoneState.canRecord`: a new milestone or one sent back for correction.
  bool get canRecord => status == statusPending || needsCorrection;

  static const String statusPending = 'pending';
  static const String statusSubmitted = 'submitted';
  static const String statusApproved = 'approved';
  static const String statusNeedsCorrection = 'needs_correction';

  /// The evidence photo as Kotlin stores it: a `data:image/...;base64,` URL.
  String get photoUri => raw['photoUri'] as String? ?? '';
  String get inputUsed => raw['inputUsed'] as String? ?? '';
  String get amountApplied => raw['amountApplied'] as String? ?? '';
  String get recordedAt => raw['recordedAt'] as String? ?? '';
  String get reviewComment => raw['reviewComment'] as String? ?? '';
  double? get latitude => (raw['latitude'] as num?)?.toDouble();
  double? get longitude => (raw['longitude'] as num?)?.toDouble();
  int? get accuracyMeters => (raw['accuracyMeters'] as num?)?.toInt();

  /// A copy with a new status, notes or extra fields, keeping every other field.
  MilestoneState copyWith({String? status, String? notes, Map<String, dynamic> extra = const {}}) {
    final merged = {...raw, ...extra};
    return MilestoneState(
      key: key,
      status: status ?? this.status,
      submittedAt: _stringDate(merged['submittedAtMillis'] ?? merged['submittedAt']),
      reviewedAt: _stringDate(merged['reviewedAtMillis'] ?? merged['reviewedAt']),
      notes: notes ?? this.notes,
      raw: merged,
    );
  }

  /// Stage name Kotlin writes on the plot when this milestone moves.
  static String stageTitle(String key) => switch (key) {
    'planting' => 'Planting',
    'irrigation' => 'Irrigation',
    'fertilization' => 'Fertilization',
    'harvest' => 'Harvest',
    _ => key,
  };

  static String title(String key, {required bool es}) => switch (key) {
    'planting' => es ? 'Siembra' : 'Planting',
    'irrigation' => es ? 'Riego' : 'Irrigation',
    'fertilization' => es ? 'Fertilización' : 'Fertilization',
    'harvest' => es ? 'Cosecha' : 'Harvest',
    _ => key,
  };

  /// What the evidence must show, from Kotlin `evidence_hint_*`.
  static String hint(String key, {required bool es}) => switch (key) {
    'planting' => es ? 'Fecha de siembra y densidad' : 'Planting date and density',
    'irrigation' => es ? 'Sistema de riego y volumen' : 'Irrigation system and volume',
    'fertilization' => es ? 'Tipo y cantidad de fertilizante' : 'Fertilizer type and amount',
    'harvest' => es ? 'Volumen y calidad de cosecha' : 'Harvest volume and quality',
    _ => '',
  };

  /// Inputs offered for each milestone, from Kotlin `MilestoneCatalog`.
  static List<String> inputOptions(String key, {required bool es}) => switch (key) {
    'planting' => [es ? 'Semilla certificada' : 'Certified seed', 'Compost'],
    'irrigation' => [es ? 'Agua' : 'Water', es ? 'Riego por goteo' : 'Drip system'],
    'fertilization' => ['NPK', 'Compost', 'Urea'],
    'harvest' => [es ? 'Jabas' : 'Crates', es ? 'Sacos' : 'Sacks'],
    _ => const [],
  };

  factory MilestoneState.fromJson(Map<String, dynamic> json) => MilestoneState(
    key: json['key'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    submittedAt: _stringDate(json['submittedAt'] ?? json['submittedAtMillis']),
    reviewedAt: _stringDate(json['reviewedAt'] ?? json['reviewedAtMillis']),
    notes: json['notes'] as String? ?? json['reviewComment'] as String? ?? '',
    raw: Map<String, dynamic>.from(json),
  );

  Map<String, dynamic> toJson() => {
    ...raw,
    'key': key,
    'status': status,
    if (submittedAt != null && !raw.containsKey('submittedAtMillis')) 'submittedAt': submittedAt,
    if (reviewedAt != null && !raw.containsKey('reviewedAtMillis')) 'reviewedAt': reviewedAt,
    'notes': notes,
  };
}

/// Measures recorded by a farmer after receiving a weather alert.
class WeatherMeasure {
  const WeatherMeasure({required this.alertKey, required this.measures, required this.attendedAt});

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
  if (value is num) {
    // Kotlin stores 0 when a milestone has not been submitted yet.
    if (value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toIso8601String();
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
