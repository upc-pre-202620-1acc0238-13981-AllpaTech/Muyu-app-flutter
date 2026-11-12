/// A visit a merchant asks to make to a published plot, stored on the backend
/// (`mobile/visits`) with the same fields as Kotlin `PlotVisit`.
class PlotVisit {
  const PlotVisit({
    required this.id,
    required this.plotId,
    required this.plotName,
    required this.plotPlace,
    required this.farmerEmail,
    required this.farmerName,
    required this.merchantEmail,
    required this.merchantName,
    required this.date,
    required this.time,
    required this.message,
    required this.status,
    this.outcome = '',
    this.agreedPrice = '',
    this.raw = const {},
  });

  static const String statusRequested = 'requested';
  static const String statusConfirmed = 'confirmed';
  static const String statusRejected = 'rejected';
  static const String statusCompleted = 'completed';
  static const String outcomeAgreement = 'agreement';
  static const String outcomeNoAgreement = 'no_agreement';

  final int id;
  final int plotId;
  final String plotName;
  final String plotPlace;
  final String farmerEmail;
  final String farmerName;
  final String merchantEmail;
  final String merchantName;

  /// `dd/MM/yyyy`, as Kotlin writes it.
  final String date;

  /// `HH:mm`.
  final String time;
  final String message;
  final String status;
  final String outcome;
  final String agreedPrice;

  /// Every field read from the backend, written back unchanged.
  final Map<String, dynamic> raw;

  /// Kotlin creates requests as `pending` but reads `requested`; both mean
  /// the farmer has not answered yet.
  bool get isRequested => status == statusRequested || status == 'pending';
  bool get isConfirmed => status == statusConfirmed;
  bool get isRejected => status == statusRejected;

  /// A visit with a recorded outcome, even if Kotlin left it as confirmed.
  bool get isCompleted => status == statusCompleted || outcome.isNotEmpty;
  bool get reachedAgreement => outcome == outcomeAgreement;

  bool involves(String email) {
    final value = email.toLowerCase();
    return farmerEmail.toLowerCase() == value || merchantEmail.toLowerCase() == value;
  }

  PlotVisit copyWith({String? status, String? outcome, String? agreedPrice}) => PlotVisit(
    id: id,
    plotId: plotId,
    plotName: plotName,
    plotPlace: plotPlace,
    farmerEmail: farmerEmail,
    farmerName: farmerName,
    merchantEmail: merchantEmail,
    merchantName: merchantName,
    date: date,
    time: time,
    message: message,
    status: status ?? this.status,
    outcome: outcome ?? this.outcome,
    agreedPrice: agreedPrice ?? this.agreedPrice,
    raw: raw,
  );

  factory PlotVisit.fromJson(Map<String, dynamic> json) => PlotVisit(
    id: (json['id'] as num?)?.toInt() ?? 0,
    plotId: (json['plotId'] as num?)?.toInt() ?? 0,
    plotName: json['plotName'] as String? ?? '',
    plotPlace: json['plotPlace'] as String? ?? '',
    farmerEmail: json['farmerEmail'] as String? ?? '',
    farmerName: json['farmerName'] as String? ?? '',
    merchantEmail: json['merchantEmail'] as String? ?? '',
    merchantName: json['merchantName'] as String? ?? '',
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    message: json['message'] as String? ?? '',
    status: json['status'] as String? ?? statusRequested,
    outcome: json['outcome'] as String? ?? '',
    agreedPrice: json['agreedPrice'] as String? ?? '',
    raw: Map<String, dynamic>.from(json),
  );

  Map<String, dynamic> toJson() => {
    ...raw,
    'id': id,
    'plotId': plotId,
    'plotName': plotName,
    'plotPlace': plotPlace,
    'farmerEmail': farmerEmail,
    'farmerName': farmerName,
    'merchantEmail': merchantEmail,
    'merchantName': merchantName,
    'date': date,
    'time': time,
    'message': message,
    'status': status,
    'outcome': outcome,
    'agreedPrice': agreedPrice,
  };
}
