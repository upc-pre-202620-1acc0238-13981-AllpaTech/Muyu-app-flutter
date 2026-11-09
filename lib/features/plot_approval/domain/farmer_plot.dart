import 'plot_activity.dart';

/// A plot as the backend stores it, with the fields of Kotlin's `PlotRecord`,
/// so plots published from either app read the same.
class FarmerPlot {
  const FarmerPlot({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
    required this.harvestDate,
    required this.place,
    required this.stage,
    required this.progress,
    required this.status,
    required this.amount,
    required this.cycle,
    required this.milestones,
    required this.ownerEmail,
    required this.ownerName,
    required this.publishedAt,
    this.imageUri,
    this.fundedByEmail,
    this.latitude,
    this.longitude,
    this.milestoneStates = const [],
    this.weatherMeasures = const [],
    this.rawJson = const {},
  });

  static const String statusAvailable = 'available';
  static const String stagePublished = 'Published';

  /// Every published plot is paid in these four milestones.
  static const String fixedMilestones = '4';

  final int id;
  final String name;
  final String crop;
  final String area;
  final String harvestDate;
  final String place;
  final String stage;
  final int progress;
  final String status;
  final String amount;
  final String cycle;
  final String milestones;
  final String ownerEmail;
  final String ownerName;
  final String publishedAt;
  final String? imageUri;
  final String? fundedByEmail;
  final double? latitude;
  final double? longitude;
  final List<MilestoneState> milestoneStates;
  final List<WeatherMeasure> weatherMeasures;

  /// Backend fields not yet modeled by Flutter (visits, harvest incidents,
  /// etc.). Keeping them prevents a weather-measure update from erasing data
  /// written by another client.
  final Map<String, dynamic> rawJson;

  bool get isFunded => status == 'funded' || status == 'approved';

  bool isOwnedBy(String email) => ownerEmail.toLowerCase() == email.toLowerCase();

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [name, crop, place].any((value) => value.toLowerCase().contains(q));
  }

  FarmerPlot copyWith({
    String? name,
    String? crop,
    String? area,
    String? harvestDate,
    String? place,
    String? amount,
    String? cycle,
    List<WeatherMeasure>? weatherMeasures,
  }) => FarmerPlot(
    id: id,
    name: name ?? this.name,
    crop: crop ?? this.crop,
    area: area ?? this.area,
    harvestDate: harvestDate ?? this.harvestDate,
    place: place ?? this.place,
    stage: stage,
    progress: progress,
    status: status,
    amount: amount ?? this.amount,
    cycle: cycle ?? this.cycle,
    milestones: milestones,
    ownerEmail: ownerEmail,
    ownerName: ownerName,
    publishedAt: publishedAt,
    fundedByEmail: fundedByEmail,
    imageUri: imageUri,
    latitude: latitude,
    longitude: longitude,
    milestoneStates: milestoneStates,
    weatherMeasures: weatherMeasures ?? this.weatherMeasures,
    rawJson: rawJson,
  );

  factory FarmerPlot.fromJson(Map<String, dynamic> json) => FarmerPlot(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    crop: json['crop'] as String? ?? '',
    area: json['area'] as String? ?? '',
    harvestDate: json['harvestDate'] as String? ?? '',
    place: json['place'] as String? ?? '',
    stage: json['stage'] as String? ?? '',
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? '',
    amount: json['amount'] as String? ?? '',
    cycle: json['cycle'] as String? ?? '',
    milestones: json['milestones'] as String? ?? '',
    ownerEmail: json['ownerEmail'] as String? ?? '',
    ownerName: json['ownerName'] as String? ?? '',
    publishedAt: json['publishedAt'] as String? ?? '',
    imageUri: json['imageUri'] as String?,
    fundedByEmail: json['fundedByEmail'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    milestoneStates: (json['milestoneStates'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MilestoneState.fromJson)
        .toList(),
    weatherMeasures: (json['weatherMeasures'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(WeatherMeasure.fromJson)
        .toList(),
    rawJson: Map<String, dynamic>.from(json),
  );

  /// The full record, including the empty fields Kotlin expects on a new plot.
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'name': name,
    'crop': crop,
    'area': area,
    'harvestDate': harvestDate,
    'place': place,
    'stage': stage,
    'progress': progress,
    'status': status,
    'amount': amount,
    'cycle': cycle,
    'milestones': milestones,
    'imageUri': imageUri,
    'ownerEmail': ownerEmail,
    'ownerName': ownerName,
    'fundedByEmail': fundedByEmail,
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': rawJson['accuracyMeters'],
    'publishedAt': publishedAt,
    'milestoneStates': milestoneStates.map((item) => item.toJson()).toList(),
    'visitOutcome': rawJson['visitOutcome'] ?? '',
    'visitDate': rawJson['visitDate'] ?? '',
    'agreedPrice': rawJson['agreedPrice'] ?? '',
    'harvestReceivedAt': rawJson['harvestReceivedAt'] ?? '',
    'harvestReceivedBy': rawJson['harvestReceivedBy'] ?? '',
    'harvestIncidents': rawJson['harvestIncidents'] ?? const <Object>[],
    'weatherMeasures': weatherMeasures.map((item) => item.toJson()).toList(),
  };
}
/// What the farmer fills in on the publish flow.
class NewFarmerPlot {
  const NewFarmerPlot({
    required this.name,
    required this.crop,
    required this.area,
    required this.harvestDate,
    required this.place,
    required this.amount,
    required this.cycle,
  });

  final String name;
  final String crop;
  final String area;
  final String harvestDate;
  final String place;
  final String amount;
  final String cycle;
}
