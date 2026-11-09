import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../escrow_custody/presentation/payments/payment_details_screen.dart';
import '../application/merchant_alerts_controller.dart';

class MerchantAlertsView extends ConsumerWidget {
  const MerchantAlertsView({super.key, this.bottomInset = 120});
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(merchantAlertsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(merchantAlertsProvider);
        await ref.read(merchantAlertsProvider.future);
      },
      child: alerts.when(
        loading: () => const _Message(child: CircularProgressIndicator()),
        error: (_, _) => _Message(
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(merchantAlertsProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.plotsRetry),
          ),
        ),
        data: (items) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset),
          children: items.isEmpty
              ? [
                  const SizedBox(height: 90),
                  const Icon(Icons.notifications_none, size: 72, color: MuyuColors.forest),
                  const SizedBox(height: 14),
                  Text(l10n.merchantAlertsEmpty, textAlign: TextAlign.center),
                ]
              : [
                  for (final item in items) ...[
                    _AlertCard(item: item),
                    const SizedBox(height: 12),
                  ],
                ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item});
  final MerchantAlertItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final payment = item.type == MerchantAlertType.payment;
    final weather = item.weather;
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.payment == null
            ? null
            : () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => PaymentDetailsScreen(payment: item.payment!)),
              ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: payment
                    ? MuyuColors.pendingBackground
                    : MuyuColors.financedBackground,
                child: Icon(payment ? Icons.payments_outlined : Icons.thunderstorm),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment ? l10n.merchantAlertPayment : l10n.merchantAlertWeather,
                      style: MuyuTextStyles.bodyBold,
                    ),
                    const SizedBox(height: 4),
                    Text('${item.plot.name} · ${item.plot.crop}'),
                    if (weather != null)
                      Text(
                        '${weather.temperature.round()} °C · ${weather.rainProbability}% lluvia',
                        style: const TextStyle(color: MuyuColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (item.payment != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [SizedBox(height: MediaQuery.sizeOf(context).height * .3), Center(child: child)],
  );
}
