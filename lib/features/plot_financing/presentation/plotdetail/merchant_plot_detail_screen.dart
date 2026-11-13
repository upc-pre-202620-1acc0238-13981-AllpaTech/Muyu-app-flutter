import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/contact/farmer_contact.dart';
import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/designsystem/components/plot_photo.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/plot_activity.dart';
import '../../../plot_approval/domain/plot_finance.dart';
import '../../../plot_approval/presentation/myplots/farmer_plot_display.dart';
import '../../../user_management/application/session_controller.dart';
import '../../application/merchant_financing_controller.dart';
import '../evidence/merchant_evidence_screens.dart';
import '../harvest/harvest_delivery_screens.dart';
import '../myplots/merchant_plot_support.dart';
import '../visit/visit_request_screen.dart';

/// Merchant plot detail from Kotlin `MerchantPlotDetailScreen` / `FundedPlotBody`.
class MerchantPlotDetailScreen extends ConsumerStatefulWidget {
  const MerchantPlotDetailScreen({super.key, required this.plot, this.onFund});

  final FarmerPlot plot;
  final VoidCallback? onFund;

  @override
  ConsumerState<MerchantPlotDetailScreen> createState() => _MerchantPlotDetailScreenState();
}

class _MerchantPlotDetailScreenState extends ConsumerState<MerchantPlotDetailScreen> {
  late FarmerPlot plot = widget.plot;

  Future<void> _viewEvidence() async {
    final updated = await Navigator.of(context).push<FarmerPlot>(
      MaterialPageRoute(
        builder: (_) =>
            MilestoneEvidenceReviewScreen(plot: plot, milestoneKey: plot.evidenceMilestoneKey),
      ),
    );
    if (updated != null && mounted) setState(() => plot = updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final funded = plot.status == 'funded';
    final area = formatPlotArea(plot.area);
    final deposit = PlotFinance.parseAmount(plot.amount);
    final steps = PlotFinance.disbursement(deposit);
    final states = plot.milestoneStatesOrSeed;
    final released = [
      for (var i = 0; i < states.length; i++)
        if (states[i].isApproved) (steps.elementAtOrNull(i) ?? 0.0) else 0.0,
    ].fold<double>(0, (sum, value) => sum + value);
    final approvedCount = states.where((item) => item.isApproved).length;
    final percent = states.isEmpty ? 0 : (approvedCount * 100) ~/ states.length;
    final harvestApproved = states.any((item) => item.key == 'harvest' && item.isApproved);
    final paymentValues = steps.map(PlotFinance.formatAmount).toSet().join(' / ');
    final user = ref.watch(sessionProvider).user;
    final funderName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : (user?.email ?? '—');
    final statusLabel = funded ? l10n.merchantStatusFundedChip : l10n.merchantAvailable;

    ref.listen(merchantFinancingProvider, (previous, next) {
      final updated = next.value?.where((item) => item.id == plot.id).firstOrNull;
      if (updated != null && updated != plot) setState(() => plot = updated);
    });

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.merchantPlotDetails, onBack: () => Navigator.pop(context)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                PlotPhoto(source: plot.imageUri, description: plot.name, height: 239),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DetailCard(
                        child: Column(
                          children: [
                            Text(
                              plot.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                                height: 27 / 21,
                                color: MuyuColors.forest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _StatusChip(label: statusLabel),
                            const SizedBox(height: 12),
                            Text(
                              [
                                plot.crop,
                                area,
                                plot.place,
                              ].where((value) => value.isNotEmpty).join(' · '),
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontSize: 16,
                                color: Color(0x80000000),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.merchantFarmerFunder(plot.ownerName, funderName, funderName),
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontSize: 16,
                                color: Color(0x80000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.merchantFinancialStatus,
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                                height: 27 / 21,
                                color: MuyuColors.forest,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FinancePair(
                              leftLabel: l10n.merchantEscrowDeposit,
                              leftValue: PlotFinance.formatAmount(deposit),
                              rightLabel: l10n.merchantFundingDate,
                              rightValue: plot.publishedAt.trim().isEmpty
                                  ? DateFormat.yMMMd(Localizations.localeOf(context).toString())
                                        .format(DateTime.now())
                                  : plot.publishedAt,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: ColoredBox(
                                color: MuyuColors.forest.withValues(alpha: 0.25),
                                child: const SizedBox(height: 1, width: double.infinity),
                              ),
                            ),
                            _FinancePair(
                              leftLabel: l10n.merchantFundsReleased,
                              leftValue: PlotFinance.formatAmount(released),
                              rightLabel: l10n.merchantEscrowBalance,
                              rightValue: PlotFinance.formatAmount(
                                (deposit - released).clamp(0, deposit),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.merchantApprovedProgress(
                                approvedCount,
                                states.isEmpty ? 1 : states.length,
                                percent,
                              ),
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < states.length; i++) ...[
                              if (i > 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: ColoredBox(
                                    color: MuyuColors.forest.withValues(alpha: 0.2),
                                    child: const SizedBox(height: 1, width: double.infinity),
                                  ),
                                ),
                              _MilestoneProgressRow(
                                approved: states[i].isApproved,
                                title: MilestoneState.title(states[i].key, es: es),
                                detail: _milestoneDetail(
                                  l10n,
                                  states[i],
                                  steps.elementAtOrNull(i) ?? 0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.merchantCropDetails,
                              style: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _CropValueRow(label: l10n.merchantCropLabel, value: plot.crop),
                            const SizedBox(height: 8),
                            _CropValueRow(label: l10n.merchantAreaLabel, value: area),
                            const SizedBox(height: 8),
                            _CropValueRow(
                              label: l10n.merchantHarvestLabel,
                              value: plot.harvestDate,
                            ),
                            const SizedBox(height: 8),
                            _CropValueRow(
                              label: l10n.merchantPaymentPerMilestone,
                              value: paymentValues,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FundedFarmerCard(name: plot.ownerName),
                      if (!funded) ...[
                        const SizedBox(height: 16),
                        _LocationCard(
                          place: plot.place,
                          hasGps: plot.latitude != null && plot.longitude != null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Material(
                        color: const Color(0xFFFFFEFE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: MuyuColors.forest),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => openFarmerContact(context, plot.ownerEmail),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                l10n.merchantContactFarmer(plot.ownerName),
                                style: const TextStyle(
                                  fontFamily: MuyuFonts.urbanist,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: MuyuColors.action,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (funded && harvestApproved) ...[
                        const SizedBox(height: 16),
                        HarvestDeliveryCard(
                          plot: plot,
                          onChanged: (updated) => setState(() => plot = updated),
                        ),
                      ],
                      if (funded && !harvestApproved) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.merchantHarvestReceiptPending,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 24 / 16,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 55,
                        child: FilledButton(
                          onPressed: funded ? _viewEvidence : widget.onFund,
                          style: FilledButton.styleFrom(
                            backgroundColor: MuyuColors.action,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            textStyle: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          child: Text(funded ? l10n.merchantViewEvidence : l10n.merchantFundPlot),
                        ),
                      ),
                      if (!funded) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () => openMerchantVisitFlow(context, ref, plot.toPlot()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MuyuColors.forest,
                              side: const BorderSide(color: MuyuColors.forest),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: MuyuFonts.urbanist,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            child: Text(l10n.merchantVisitRequestButton),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _milestoneDetail(AppLocalizations l10n, MilestoneState state, double amount) {
    final formatted = PlotFinance.formatAmount(amount);
    final millis = (state.raw['submittedAtMillis'] as num?)?.toInt() ?? 0;
    final date = millis > 0
        ? DateFormat('d MMM yyyy', 'en').format(DateTime.fromMillisecondsSinceEpoch(millis))
        : (state.raw['extensionDate'] as String? ??
                  state.raw['dueLabel'] as String? ??
                  state.recordedAt)
              .ifBlank(plot.harvestDate);
    if (state.isApproved) return l10n.merchantMilestoneApprovedLine(date, formatted);
    if (state.isSubmitted || state.isQueued) {
      final time = millis > 0
          ? DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(millis))
          : '—';
      return l10n.merchantMilestoneAwaitingLine(date, time, formatted);
    }
    return l10n.merchantMilestonePendingLine(date, formatted);
  }
}

extension on String {
  String ifBlank(String fallback) => trim().isEmpty ? fallback : this;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: MuyuColors.forest),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _FinancePair extends StatelessWidget {
  const _FinancePair({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontSize: 16,
                  color: MuyuColors.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                leftValue,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: MuyuColors.forest,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightLabel,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontSize: 16,
                  color: MuyuColors.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rightValue,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: MuyuColors.forest,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneProgressRow extends StatelessWidget {
  const _MilestoneProgressRow({required this.approved, required this.title, required this.detail});

  final bool approved;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: approved ? MuyuColors.approvedBg : MuyuColors.termsBg,
            shape: BoxShape.circle,
            border: approved ? null : Border.all(color: MuyuColors.forest, width: 2),
          ),
          child: approved ? const Icon(Icons.check, size: 14, color: MuyuColors.forest) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontSize: 14,
                  color: MuyuColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CropValueRow extends StatelessWidget {
  const _CropValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontSize: 16,
            color: MuyuColors.secondaryText,
          ),
        ),
        const Spacer(),
        Text(
          value.trim().isEmpty ? '—' : value,
          style: const TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: 16),
        ),
      ],
    );
  }
}

class _FundedFarmerCard extends StatelessWidget {
  const _FundedFarmerCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MuyuColors.forest),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          FarmerAvatar(name: name, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.merchantFarmerStats,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontSize: 16,
                    color: MuyuColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                  decoration: BoxDecoration(
                    color: MuyuColors.skip,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    l10n.merchantApprovalRate,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: MuyuColors.action,
                    ),
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.place, required this.hasGps});

  final String place;
  final bool hasGps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MuyuColors.forest),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantExactLocation,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                const Center(child: Icon(Icons.location_on, color: MuyuColors.action, size: 36)),
                if (hasGps)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: MuyuColors.approvedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'es'
                            ? 'GPS verificado'
                            : 'GPS verified',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MuyuColors.forest,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            place.isEmpty ? '—' : place,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: MuyuColors.forest,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MuyuColors.approvedBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: MuyuColors.forest,
        ),
      ),
    );
  }
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
