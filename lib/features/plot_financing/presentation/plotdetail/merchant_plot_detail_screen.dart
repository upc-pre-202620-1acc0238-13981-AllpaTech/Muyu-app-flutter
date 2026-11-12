import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/designsystem/components/plot_photo.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/domain/plot.dart';
import '../visit/visit_request_screen.dart';

/// Merchant plot detail aligned with Kotlin: photo, producer, location, crop,
/// traceability, financing, escrow and the available actions.
class MerchantPlotDetailScreen extends StatelessWidget {
  const MerchantPlotDetailScreen({super.key, required this.plot, this.onFund});

  final Plot plot;
  final VoidCallback? onFund;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final available = plot.status.toLowerCase() == 'available';
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Detalle de parcela' : 'Plot details',
            onBack: () => Navigator.pop(context),
            trailing: _StatusChip(
              label: available ? (es ? 'Disponible' : 'Available') : plot.status,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                PlotPhoto(
                  source: plot.imageUri ?? plot.imageAsset,
                  description: plot.name,
                  height: 224,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlotSummary(plot: plot, es: es),
                      const SizedBox(height: 12),
                      _FarmerCard(plot: plot, es: es),
                      const SizedBox(height: 12),
                      _LocationCard(place: plot.place, es: es),
                      const SizedBox(height: 12),
                      _CropCard(plot: plot, es: es),
                      const SizedBox(height: 12),
                      _TraceabilityCard(es: es),
                      const SizedBox(height: 12),
                      _FundingCard(plot: plot, es: es),
                      const SizedBox(height: 12),
                      _EscrowNote(es: es),
                      const SizedBox(height: 12),
                      MerchantVisitPanel(plot: plot),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onFund != null)
            SafeArea(
              top: false,
              child: Container(
                color: MuyuColors.background,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: FilledButton(
                  onPressed: onFund,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(es ? 'Financiar parcela' : 'Fund this plot'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlotSummary extends StatelessWidget {
  const _PlotSummary({required this.plot, required this.es});

  final Plot plot;
  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(plot.name, style: MuyuTextStyles.bodyBold)),
            _StatusChip(label: es ? 'Disponible' : 'Available'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [plot.crop, plot.area, plot.place].where((value) => value.isNotEmpty).join(' · '),
          style: const TextStyle(color: MuyuColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: es ? 'Cosecha estimada' : 'Estimated harvest',
                value: plot.harvestDate,
              ),
            ),
            Expanded(
              child: _Metric(
                label: es ? 'Financiamiento' : 'Financing',
                value: plot.amount,
                alignEnd: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FarmerCard extends StatelessWidget {
  const _FarmerCard({required this.plot, required this.es});

  final Plot plot;
  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    title: es ? 'Agricultor' : 'Farmer',
    child: Row(
      children: [
        FarmerAvatar(name: plot.ownerName, imageAsset: plot.ownerImageAsset, size: 58),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plot.ownerName, style: MuyuTextStyles.bodyBold),
              const SizedBox(height: 3),
              Text(
                es ? 'Productor verificado' : 'Verified producer',
                style: const TextStyle(fontSize: 13, color: MuyuColors.textSecondary),
              ),
              const SizedBox(height: 6),
              _Badge(label: es ? 'Perfil verificado' : 'Verified profile'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.place, required this.es});

  final String place;
  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    title: es ? 'Ubicación exacta' : 'Exact location',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 112,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
              const Center(child: Icon(Icons.location_on, color: MuyuColors.action, size: 36)),
              Positioned(
                left: 10,
                top: 10,
                child: _Badge(label: es ? 'GPS verificado' : 'GPS verified'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(place.isEmpty ? '—' : place, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}

class _CropCard extends StatelessWidget {
  const _CropCard({required this.plot, required this.es});

  final Plot plot;
  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    title: es ? 'Detalles del cultivo' : 'Crop details',
    child: Column(
      children: [
        _InfoRow(label: es ? 'Cultivo' : 'Crop', value: plot.crop),
        _InfoRow(label: es ? 'Área' : 'Area', value: plot.area),
        _InfoRow(label: es ? 'Cosecha estimada' : 'Estimated harvest', value: plot.harvestDate),
        _InfoRow(label: es ? 'Ciclo' : 'Cycle', value: plot.cycle),
        _InfoRow(label: es ? 'Hitos' : 'Milestones', value: plot.milestones),
      ],
    ),
  );
}

class _TraceabilityCard extends StatelessWidget {
  const _TraceabilityCard({required this.es});

  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    title: es ? 'Trazabilidad' : 'Traceability',
    child: Column(
      children: [
        _InfoRow(label: es ? 'Suelo' : 'Soil', value: es ? 'Verificado' : 'Verified'),
        _InfoRow(label: es ? 'Insumos' : 'Inputs', value: es ? 'Documentados' : 'Documented'),
        _InfoRow(
          label: es ? 'Prácticas' : 'Practices',
          value: es ? 'Registro disponible' : 'Record available',
        ),
      ],
    ),
  );
}

class _FundingCard extends StatelessWidget {
  const _FundingCard({required this.plot, required this.es});

  final Plot plot;
  final bool es;

  @override
  Widget build(BuildContext context) => _DetailCard(
    title: es ? 'Financiamiento' : 'Financing',
    child: Column(
      children: [
        _InfoRow(label: es ? 'Monto total' : 'Total amount', value: plot.amount),
        _InfoRow(label: es ? 'Ciclo productivo' : 'Production cycle', value: plot.cycle),
        _InfoRow(
          label: es ? 'Plan de desembolsos' : 'Disbursement plan',
          value: plot.milestones.isEmpty
              ? '—'
              : (es
                    ? '${plot.milestones} pagos por hitos'
                    : '${plot.milestones} milestone payments'),
        ),
      ],
    ),
  );
}

class _EscrowNote extends StatelessWidget {
  const _EscrowNote({required this.es});

  final bool es;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFD9ECFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline, color: MuyuColors.financedText),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            es
                ? 'Los fondos permanecen protegidos en custodia y se liberan cuando se aprueba cada hito.'
                : 'Funds are held in escrow and released after each approved milestone.',
          ),
        ),
      ],
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: MuyuColors.forest.withValues(alpha: .7)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: MuyuTextStyles.bodyBold),
          const SizedBox(height: 12),
        ],
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: MuyuColors.mutedFooter)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '—' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: MuyuColors.mutedFooter)),
      const SizedBox(height: 2),
      Text(value.isEmpty ? '—' : value, style: MuyuTextStyles.bodyBold),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: MuyuColors.approvedBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MuyuColors.forest),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: MuyuColors.approvedBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MuyuColors.forest),
      ),
    ),
  );
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final minor = Paint()
      ..color = const Color(0xFFC7D2D8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * .7), Offset(size.width, size.height * .28), road);
    canvas.drawLine(Offset(size.width * .2, 0), Offset(size.width * .45, size.height), minor);
    canvas.drawLine(Offset(size.width * .78, 0), Offset(size.width * .65, size.height), minor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
