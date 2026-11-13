import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/merchant_bottom_bar.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/domain/plot_activity.dart';
import '../../../user_management/application/session_controller.dart';
import '../../application/merchant_financing_controller.dart';
import '../myplots/merchant_plot_support.dart';
import '../plotdetail/merchant_plot_detail_screen.dart';

/// Kotlin `MerchantMyPlotsScreen`: header, rain banner, review-first toggle and funded cards.
class MerchantFundedPlotsView extends ConsumerStatefulWidget {
  const MerchantFundedPlotsView({super.key});

  @override
  ConsumerState<MerchantFundedPlotsView> createState() => _MerchantFundedPlotsViewState();
}

class _MerchantFundedPlotsViewState extends ConsumerState<MerchantFundedPlotsView> {
  bool _reviewFirst = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(sessionProvider).user?.email.toLowerCase() ?? '';
    final state = ref.watch(merchantFinancingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: MuyuColors.navBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.navMyPlots,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.merchantActiveFundedPlots(
                      (state.value ?? const [])
                          .where(
                            (plot) => plot.fundedByEmail?.toLowerCase() == email && plot.isFunded,
                          )
                          .length,
                    ),
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFFFEFEFE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator(color: MuyuColors.forest)),
            error: (_, _) => Center(
              child: OutlinedButton(
                onPressed: ref.read(merchantFinancingProvider.notifier).refresh,
                child: Text(l10n.plotsRetry),
              ),
            ),
            data: (all) {
              final plots = all
                  .where((plot) => plot.fundedByEmail?.toLowerCase() == email && plot.isFunded)
                  .toList();
              final display = [...plots]
                ..sort((a, b) {
                  if (_reviewFirst) {
                    final byReview = a.sortPriorityNeedsReview.compareTo(b.sortPriorityNeedsReview);
                    if (byReview != 0) return byReview;
                  }
                  return a.name.compareTo(b.name);
                });
              return RefreshIndicator(
                color: MuyuColors.forest,
                onRefresh: ref.read(merchantFinancingProvider.notifier).refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, merchantScrollBottomInset),
                  children: [
                    if (plots.isNotEmpty) ...[
                      _RainRiskBanner(plotCount: plots.length),
                      const SizedBox(height: 16),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ReviewFirstToggle(
                        enabled: _reviewFirst,
                        onChanged: (value) => setState(() => _reviewFirst = value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (display.isEmpty)
                      Text(
                        l10n.merchantNoFunded,
                        style: TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontSize: 16,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      for (final plot in display) ...[
                        _FundedPlotCard(
                          plot: plot,
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute(builder: (_) => MerchantPlotDetailScreen(plot: plot)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RainRiskBanner extends StatelessWidget {
  const _RainRiskBanner({required this.plotCount});

  final int plotCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [MuyuColors.weatherBannerStart, MuyuColors.weatherBannerEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/weather_rain.png',
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.merchantRainRiskTitle,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 24 / 16,
                      color: Color(0xFFFEFEFE),
                    ),
                  ),
                  Text(
                    plotCount == 1
                        ? l10n.merchantRainRiskBody(plotCount)
                        : l10n.merchantRainRiskBodyPlural(plotCount),
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontSize: 14,
                      height: 20 / 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MuyuColors.verifiedChipBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                l10n.merchantRainRiskTemp,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: MuyuColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewFirstToggle extends StatelessWidget {
  const _ReviewFirstToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MuyuColors.pageGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.merchantShowReviewFirst,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontSize: 16,
                height: 24 / 16,
                color: MuyuColors.onSurface,
              ),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? MuyuColors.action
                  : MuyuColors.cardOutline,
            ),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _FundedPlotCard extends StatelessWidget {
  const _FundedPlotCard({required this.plot, required this.onTap});

  final FarmerPlot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final states = plot.milestoneStatesOrSeed;
    final approved = states.where((item) => item.isApproved).length;
    final progress = plot.progress.clamp(0, 100);
    final needsReview = plot.needsMerchantReview;
    final milestoneKey = plot.currentMilestoneLabelKey;
    final milestoneTitle = milestoneKey == null ? '' : MilestoneState.title(milestoneKey, es: es);
    final nextDue = plot.dueLabel;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MuyuColors.cardOutline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.name,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plot.crop}  ·  ${plot.ownerName.isEmpty ? '—' : plot.ownerName}',
                          style: TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    label: needsReview ? l10n.merchantInProgress : l10n.merchantStatusFundedChip,
                    needsReview: needsReview,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.merchantMilestonesFraction(approved, MilestoneState.planKeys.length),
                    style: _mutedLabel,
                  ),
                  const Spacer(),
                  Text('$progress%', style: _mutedLabel),
                ],
              ),
              const SizedBox(height: 8),
              _ProgressBar(progress: progress),
              if (milestoneTitle.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  needsReview ? l10n.merchantCurrentMilestone : l10n.merchantNextMilestone,
                  style: _mutedLabel,
                ),
                if (needsReview) ...[
                  const SizedBox(height: 8),
                  _StatusChip(label: l10n.merchantNeedsYourReview, needsReview: true),
                ],
                const SizedBox(height: 8),
                Text(
                  milestoneTitle,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontSize: 16,
                    height: 24 / 16,
                    color: MuyuColors.onSurface,
                  ),
                ),
                if (!needsReview && nextDue.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: MuyuColors.grayChip,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      nextDue,
                      style: TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.needsReview});

  final String label;
  final bool needsReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: needsReview ? MuyuColors.pendingBackground : MuyuColors.financedBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: needsReview ? MuyuColors.pendingText : MuyuColors.financedText,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 12,
        child: ColoredBox(
          color: MuyuColors.grayChip,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress / 100,
              heightFactor: 1,
              child: const ColoredBox(color: MuyuColors.action),
            ),
          ),
        ),
      ),
    );
  }
}

const _mutedLabel = TextStyle(
  fontFamily: MuyuFonts.urbanist,
  fontSize: 14,
  height: 20 / 14,
  color: Color(0x80000000),
);
