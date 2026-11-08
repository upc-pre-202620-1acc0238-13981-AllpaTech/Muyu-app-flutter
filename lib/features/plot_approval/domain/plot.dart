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
    this.imageAsset,
    this.ownerImageAsset,
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
  final String? imageAsset;
  final String? ownerImageAsset;
}
