import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../escrow_custody/domain/payment_record.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';
import '../domain/weather_alert.dart';
import '../infrastructure/open_meteo_repository.dart';

enum MerchantAlertType { payment, weather }

class MerchantAlertItem {
  const MerchantAlertItem({
    required this.id,
    required this.type,
    required this.plot,
    this.payment,
    this.weather,
  });
  final String id;
  final MerchantAlertType type;
  final FarmerPlot plot;
  final PaymentRecord? payment;
  final WeatherAlert? weather;
}

final merchantAlertsProvider = FutureProvider<List<MerchantAlertItem>>((ref) async {
  final user = ref.watch(sessionProvider).user;
  if (user == null || user.token.isEmpty) return const [];
  final all = await ref.watch(farmerPlotRepositoryProvider).getAll(user.token);
  final funded = all
      .where((plot) => plot.fundedByEmail?.toLowerCase() == user.email.toLowerCase())
      .toList();
  final alerts = <MerchantAlertItem>[];
  for (final plot in funded) {
    for (final payment in paymentsFromPlot(plot).where(
      (item) => item.status == PaymentStatus.pending,
    )) {
      alerts.add(
        MerchantAlertItem(
          id: 'payment:${payment.id}',
          type: MerchantAlertType.payment,
          plot: plot,
          payment: payment,
        ),
      );
    }
    try {
      final weather = await ref.read(weatherRepositoryProvider).alertFor(plot);
      if (weather.risk != WeatherRisk.low) {
        alerts.add(
          MerchantAlertItem(
            id: 'weather:${plot.id}:${weather.risk.name}',
            type: MerchantAlertType.weather,
            plot: plot,
            weather: weather,
          ),
        );
      }
    } on WeatherException {
      // Payment alerts remain useful when the public forecast is unavailable.
    }
  }
  return alerts;
}, retry: (retryCount, error) => null);
