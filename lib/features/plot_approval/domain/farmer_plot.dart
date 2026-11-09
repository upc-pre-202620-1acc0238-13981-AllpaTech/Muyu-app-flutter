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
    this.fundedByEmail,
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
  final String? fundedByEmail;

  bool get isFunded => status == 'funded' || status == 'approved';

  bool isOwnedBy(String email) => ownerEmail.toLowerCase() == email.toLowerCase();

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [name, crop, place].any((value) => value.toLowerCase().contains(q));
  }

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
    fundedByEmail: json['fundedByEmail'] as String?,
  );

  /// The full record, including the empty fields Kotlin expects on a new plot.
  Map<String, dynamic> toJson() => {
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
    'imageUri': null,
    'ownerEmail': ownerEmail,
    'ownerName': ownerName,
    'fundedByEmail': fundedByEmail,
    'latitude': null,
    'longitude': null,
    'accuracyMeters': null,
    'publishedAt': publishedAt,
    'milestoneStates': const <Object>[],
    'visitOutcome': '',
    'visitDate': '',
    'agreedPrice': '',
    'harvestReceivedAt': '',
    'harvestReceivedBy': '',
    'harvestIncidents': const <Object>[],
    'weatherMeasures': const <Object>[],
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
