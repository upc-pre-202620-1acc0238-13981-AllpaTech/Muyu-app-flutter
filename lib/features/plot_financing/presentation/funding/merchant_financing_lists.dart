import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/merchant_bottom_bar.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../user_management/application/session_controller.dart';
import '../../application/merchant_financing_controller.dart';

class MerchantFundedPlotsView extends ConsumerWidget {
  const MerchantFundedPlotsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final email = ref.watch(sessionProvider).user?.email.toLowerCase() ?? '';
    final state = ref.watch(merchantFinancingProvider);
    return _FinancingList(
      title: es ? 'Parcelas financiadas' : 'Funded plots',
      empty: es ? 'Todavía no financiaste ninguna parcela.' : 'You have not funded any plots yet.',
      state: state,
      select: (items) => items
          .where((plot) => plot.fundedByEmail?.toLowerCase() == email && plot.isFunded)
          .toList(),
      onRefresh: ref.read(merchantFinancingProvider.notifier).refresh,
    );
  }
}

class MerchantPaymentsView extends ConsumerWidget {
  const MerchantPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final email = ref.watch(sessionProvider).user?.email.toLowerCase() ?? '';
    final state = ref.watch(merchantFinancingProvider);
    return _FinancingList(
      title: es ? 'Pagos en verificación' : 'Payments under verification',
      empty: es
          ? 'No tienes pagos pendientes de verificación.'
          : 'You have no payments awaiting verification.',
      state: state,
      select: (items) => items
          .where((plot) => plot.fundedByEmail?.toLowerCase() == email && plot.isPaymentVerification)
          .toList(),
      onRefresh: ref.read(merchantFinancingProvider.notifier).refresh,
    );
  }
}

class _FinancingList extends StatelessWidget {
  const _FinancingList({
    required this.title,
    required this.empty,
    required this.state,
    required this.select,
    required this.onRefresh,
  });

  final String title;
  final String empty;
  final AsyncValue<List<FarmerPlot>> state;
  final List<FarmerPlot> Function(List<FarmerPlot>) select;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(title: title),
      Expanded(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(onPressed: onRefresh, child: const Text('Try again')),
          ),
          data: (all) {
            final plots = select(all);
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: plots.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, merchantScrollBottomInset),
                      children: [Text(empty, textAlign: TextAlign.center)],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, merchantScrollBottomInset),
                      itemCount: plots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _FinancingCard(plot: plots[index]),
                    ),
            );
          },
        ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: MuyuColors.navBar,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: MuyuTextStyles.headerTitle),
        ),
      ),
    ),
  );
}

class _FinancingCard extends StatelessWidget {
  const _FinancingCard({required this.plot});
  final FarmerPlot plot;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final pending = plot.isPaymentVerification;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MuyuColors.forest),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(plot.name, style: MuyuTextStyles.bodyBold)),
              _Status(pending: pending, es: es),
            ],
          ),
          const SizedBox(height: 8),
          Text('${plot.crop} · ${plot.area} · ${plot.place}'),
          const SizedBox(height: 10),
          Text(plot.amount, style: MuyuTextStyles.bodyBold.copyWith(color: MuyuColors.forest)),
          const SizedBox(height: 6),
          Text('${es ? 'Método' : 'Method'}: ${plot.paymentMethod ?? '—'}'),
          Text('${es ? 'Referencia' : 'Reference'}: ${plot.paymentReference ?? '—'}'),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.pending, required this.es});
  final bool pending;
  final bool es;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: pending ? MuyuColors.pendingBackground : MuyuColors.approvedBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      pending ? (es ? 'En verificación' : 'Verifying') : (es ? 'En custodia' : 'In escrow'),
      style: TextStyle(color: pending ? MuyuColors.pendingText : MuyuColors.forest),
    ),
  );
}
