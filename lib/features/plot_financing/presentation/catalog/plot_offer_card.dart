import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/plot.dart';

class PlotOfferCard extends StatelessWidget {
  const PlotOfferCard({super.key, required this.plot, this.onTap});

  final Plot plot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [plot.crop, plot.area, plot.place].where((part) => part.isNotEmpty).join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlotPhoto(imageAsset: plot.imageAsset, description: plot.name),
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
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
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
                      FarmerAvatar(name: plot.ownerName, imageAsset: plot.ownerImageAsset),
                      const SizedBox(width: 8),
                      Text(
                        plot.ownerName,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
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

class _PlotPhoto extends StatelessWidget {
  const _PlotPhoto({required this.imageAsset, required this.description});

  final String? imageAsset;
  final String description;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;
    return SizedBox(
      height: 168,
      width: double.infinity,
      child: asset == null || asset.isEmpty
          ? const ColoredBox(
              color: Color(0xFFEAF9E9),
              child: Center(child: Icon(Icons.image, size: 48, color: MuyuColors.action)),
            )
          : Image.asset(asset, fit: BoxFit.cover, semanticLabel: description),
    );
  }
}
