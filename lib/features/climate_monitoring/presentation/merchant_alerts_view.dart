import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../escrow_custody/presentation/payments/payment_details_screen.dart';
import '../../plot_approval/domain/plot_finance.dart';
import '../application/merchant_alerts_controller.dart';
import 'weather_alert_screen.dart';

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
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
          children: items.isEmpty
              ? [
                  Text(
                    l10n.merchantAlertsEmpty,
                    style: TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ]
              : [
                  for (final item in items) ...[
                    _AlertCard(item: item),
                    const SizedBox(height: 15),
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
    final title = payment ? l10n.merchantAlertPayment : l10n.weatherTitle;
    final subtitle = '${item.plot.name} · ${item.plot.crop}';
    final body = payment && item.payment != null
        ? l10n.merchantAlertPaymentBody(
            item.plot.ownerName,
            _milestoneTitle(l10n, item.payment!.milestoneIndex),
            PlotFinance.formatAmount(item.payment!.amount),
          )
        : l10n.merchantAlertWeatherBody(item.plot.name);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: MuyuColors.forest),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (item.payment != null) {
            Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => PaymentDetailsScreen(payment: item.payment!)),
            );
            return;
          }
          Navigator.of(context)
              .push<void>(MaterialPageRoute(builder: (_) => WeatherAlertScreen(plot: item.plot)));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 37,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA0C97F),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      payment ? Icons.payments_outlined : Icons.thunderstorm,
                      size: 18,
                      color: MuyuColors.forest,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: MuyuColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontSize: 14,
                            height: 20 / 14,
                            color: MuyuColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  body,
                  style: TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
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
    children: [
      SizedBox(height: MediaQuery.sizeOf(context).height * .3),
      Center(child: child),
    ],
  );
}

String _milestoneTitle(AppLocalizations l10n, int index) => switch (index) {
  0 => l10n.paymentMilestonePlanting,
  1 => l10n.paymentMilestoneIrrigation,
  2 => l10n.paymentMilestoneFertilization,
  _ => l10n.paymentMilestoneHarvest,
};
