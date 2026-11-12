import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';
import '../../user_management/domain/user.dart';
import '../domain/payment_record.dart';

final paymentHistoryProvider = FutureProvider<List<PaymentRecord>>((ref) async {
  final session = ref.watch(sessionProvider);
  final user = session.user;
  final role = session.role;
  if (user == null || role == null || user.token.isEmpty) return const [];

  final plots = await ref.watch(farmerPlotRepositoryProvider).getAll(user.token);
  final email = user.email.toLowerCase();
  final visiblePlots = plots.where(
    (plot) => switch (role) {
      UserRole.farmer => plot.ownerEmail.toLowerCase() == email,
      UserRole.merchant => plot.fundedByEmail?.toLowerCase() == email,
    },
  );

  final payments = visiblePlots.expand(paymentsFromPlot).toList();
  payments.sort((a, b) {
    final left = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
    final right = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
    return right.compareTo(left);
  });
  return payments;
}, retry: (retryCount, error) => null);
