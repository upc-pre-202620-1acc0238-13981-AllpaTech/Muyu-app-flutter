import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/designsystem/components/plot_photo.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/farmer_plot.dart';
import '../../../plot_approval/presentation/myplots/farmer_plot_display.dart';

class PlotOfferCard extends StatelessWidget {
  const PlotOfferCard({super.key, required this.plot, this.onTap});

  final FarmerPlot plot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [
      plot.crop,
      formatPlotArea(plot.area),
      plot.place,
    ].where((part) => part.isNotEmpty && part != '—').join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlotPhoto(source: plot.imageUri, description: plot.name, height: 168),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plot.amount,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: MuyuColors.forest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FarmerAvatar(name: plot.ownerName, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plot.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: MuyuColors.approvedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      details,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: MuyuColors.forest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        l10n.merchantVerified,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontSize: 13,
                          color: MuyuColors.mutedFooter,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.merchantMilestones,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontSize: 13,
                          color: MuyuColors.mutedFooter,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
