import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/domain/plot.dart';

class MerchantPlotDetailScreen extends StatelessWidget {
  const MerchantPlotDetailScreen({super.key, required this.plot});
  final Plot plot;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Detalle de parcela' : 'Plot details',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MuyuColors.navBar,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plot.name, style: MuyuTextStyles.headerTitle),
                      const SizedBox(height: 8),
                      Text(
                        '${plot.crop} · ${plot.area}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plot.amount,
                        style: MuyuTextStyles.bodyBold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: es ? 'Agricultor' : 'Farmer',
                  child: Row(
                    children: [
                      FarmerAvatar(name: plot.ownerName, imageAsset: plot.ownerImageAsset),
                      const SizedBox(width: 12),
                      Expanded(child: Text(plot.ownerName, style: MuyuTextStyles.bodySemiBold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: es ? 'Información de la parcela' : 'Plot information',
                  child: Column(
                    children: [
                      _Row(label: es ? 'Ubicación' : 'Location', value: plot.place),
                      _Row(label: es ? 'Cosecha' : 'Harvest', value: plot.harvestDate),
                      _Row(label: es ? 'Ciclo' : 'Cycle', value: plot.cycle),
                      _Row(label: es ? 'Hitos' : 'Milestones', value: plot.milestones),
                      _Row(label: es ? 'Estado' : 'Status', value: plot.status),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9ECFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    es
                        ? 'Los fondos se mantienen en custodia y se liberan por hitos aprobados.'
                        : 'Funds are held in escrow and released after approved milestones.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: MuyuColors.forest),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MuyuTextStyles.bodyBold),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: MuyuColors.mutedFooter)),
        ),
        Expanded(child: Text(value.isEmpty ? '—' : value, textAlign: TextAlign.end)),
      ],
    ),
  );
}
