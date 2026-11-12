import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../plot_approval/domain/plot_activity.dart';

/// Shows an evidence photo stored as a `data:` URL (Kotlin and Flutter) or a
/// web address, with a neutral placeholder when there is none.
class EvidencePhoto extends StatelessWidget {
  const EvidencePhoto({super.key, required this.uri, this.height = 220});

  final String uri;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
      height: height,
      color: MuyuColors.pageGray,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: MuyuColors.mutedFooter,
        size: 40,
      ),
    );

    Widget image;
    if (uri.startsWith('data:')) {
      final comma = uri.indexOf(',');
      try {
        image = Image.memory(
          base64Decode(uri.substring(comma + 1)),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => placeholder(),
        );
      } on FormatException {
        image = placeholder();
      }
    } else if (uri.startsWith('http')) {
      image = Image.network(
        uri,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else {
      image = placeholder();
    }
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: image);
  }
}

/// Label and colors for a milestone status, shared by farmer and merchant.
class MilestoneStatusChip extends StatelessWidget {
  const MilestoneStatusChip({super.key, required this.milestone});
  final MilestoneState milestone;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final (label, background, foreground) = switch (milestone.status) {
      MilestoneState.statusApproved => (
        es ? 'Aprobado' : 'Approved',
        MuyuColors.approvedBg,
        MuyuColors.forest,
      ),
      MilestoneState.statusSubmitted => (
        es ? 'En revisión' : 'In review',
        MuyuColors.financedBackground,
        MuyuColors.financedText,
      ),
      MilestoneState.statusNeedsCorrection => (
        es ? 'Por corregir' : 'Needs correction',
        MuyuColors.dangerBackground,
        MuyuColors.dangerMessage,
      ),
      _ => (es ? 'Pendiente' : 'Pending', MuyuColors.pendingBackground, MuyuColors.pendingText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// The plot's milestone plan, with an optional action on each milestone.
class MilestonePlanCard extends StatelessWidget {
  const MilestonePlanCard({super.key, required this.milestones, this.actionLabel, this.onAction});

  final List<MilestoneState> milestones;

  /// Text of the button for a milestone, or null when it has no action.
  final String? Function(MilestoneState milestone)? actionLabel;
  final void Function(MilestoneState milestone)? onAction;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MuyuColors.forest),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            es ? 'Hitos de producción' : 'Production milestones',
            style: MuyuTextStyles.bodyBold,
          ),
          const SizedBox(height: 6),
          for (final (index, milestone) in milestones.indexed) ...[
            if (index > 0) const Divider(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: MuyuColors.skip,
                  child: Text('${index + 1}', style: const TextStyle(color: MuyuColors.forest)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    MilestoneState.title(milestone.key, es: es),
                    style: MuyuTextStyles.bodySemiBold,
                  ),
                ),
                MilestoneStatusChip(milestone: milestone),
              ],
            ),
            if (milestone.needsCorrection && milestone.reviewComment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 40),
                child: Text(
                  '${es ? 'Motivo' : 'Reason'}: ${milestone.reviewComment}',
                  style: const TextStyle(color: MuyuColors.dangerMessage),
                ),
              ),
            if (actionLabel?.call(milestone) case final label?)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    onPressed: onAction == null ? null : () => onAction!(milestone),
                    child: Text(label),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Coordinates written like Kotlin `PlotFinance.formatCoordinates`: `13.5310 S, 71.9670 W`.
String formatCoordinates(double latitude, double longitude) {
  final lat = '${latitude.abs().toStringAsFixed(4)} ${latitude < 0 ? 'S' : 'N'}';
  final lng = '${longitude.abs().toStringAsFixed(4)} ${longitude < 0 ? 'W' : 'E'}';
  return '$lat, $lng';
}
