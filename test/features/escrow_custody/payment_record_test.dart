import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/escrow_custody/domain/payment_record.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/plot_approval/domain/plot_activity.dart';

FarmerPlot _plot({List<MilestoneState> milestones = const []}) => FarmerPlot(
  id: 7,
  name: 'El Rosal',
  crop: 'Papa',
  area: '2 ha',
  harvestDate: '2026-12-01',
  place: 'Cusco',
  stage: 'Funded',
  progress: 50,
  status: 'funded',
  amount: 'S/ 10 000',
  cycle: '2026',
  milestones: '4',
  ownerEmail: 'farmer@example.com',
  ownerName: 'Ana',
  publishedAt: '2026-01-01',
  fundedByEmail: 'merchant@example.com',
  milestoneStates: milestones,
);

void main() {
  test('derives completed and pending payments from milestone state', () {
    final records = paymentsFromPlot(
      _plot(
        milestones: const [
          MilestoneState(key: 'planting', status: 'approved', reviewedAt: '2026-03-02'),
          MilestoneState(key: 'irrigation', status: 'submitted', submittedAt: '2026-04-03'),
          MilestoneState(key: 'fertilization', status: 'pending'),
        ],
      ),
    );

    expect(records, hasLength(2));
    expect(records.first.status, PaymentStatus.completed);
    expect(records.last.status, PaymentStatus.pending);
    expect(records.first.amount, closeTo(2353, .01));
    expect(records.last.transactionId, 'MY-7-IRRIGATION');
  });

  test('parses and serializes backend activity without losing it', () {
    final plot = FarmerPlot.fromJson({
      ..._plot().toJson(),
      'latitude': -13.52,
      'longitude': -71.97,
      'milestoneStates': [
        {'key': 'planting', 'status': 'approved', 'reviewedAtMillis': 1000},
      ],
      'weatherMeasures': [
        {
          'alertKey': '7_2026-11-09_high',
          'measures': ['cover'],
          'attendedAt': '2026-11-09',
        },
      ],
      'visitOutcome': 'accepted',
    });

    expect(plot.milestoneStates.single.isApproved, isTrue);
    expect(plot.weatherMeasures.single.measures, ['cover']);
    expect(plot.toJson()['latitude'], -13.52);
    expect(plot.toJson()['visitOutcome'], 'accepted');
  });
}
