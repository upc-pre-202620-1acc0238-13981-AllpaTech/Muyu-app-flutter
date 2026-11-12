/// Plot aggregate used by catalog, financing, and farmer listing.
class Plot {
  const Plot({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
    required this.place,
    required this.amount,
    required this.status,
    required this.ownerName,
    required this.ownerEmail,
    this.harvestDate = '',
    this.stage = '',
    this.progress = 0,
    this.cycle = '',
    this.milestones = '',
    this.imageUri,
    this.imageAsset,
    this.ownerImageAsset,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String crop;
  final String area;
  final String place;
  final String amount;
  final String status;
  final String ownerName;
  final String ownerEmail;
  final String harvestDate;
  final String stage;
  final int progress;
  final String cycle;
  final String milestones;
  final String? imageUri;
  final String? imageAsset;
  final String? ownerImageAsset;
  final double? latitude;
  final double? longitude;
}
