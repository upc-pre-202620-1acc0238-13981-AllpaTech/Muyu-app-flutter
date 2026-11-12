import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/farmer_plot.dart';
import '../../domain/plot_activity.dart';

/// Display rules for the farmer's plot lists, from Kotlin `FarmerPlotListSupport.kt`.
extension FarmerPlotDisplay on FarmerPlot {
  /// Kotlin `isFundedPlot`: a merchant already financed it.
  bool get isFundedPlot => status == 'funded' || status == 'approved';

  int get approvedMilestoneCount => milestoneStates.where((item) => item.isApproved).length;

  /// The title of the milestone in progress, or null when the plot is not funded.
  String? stageTitle({required bool es}) {
    if (!isFundedPlot) return null;
    MilestoneState? current;
    for (final item in milestoneStates) {
      if (item.isQueued || item.isSubmitted) {
        current = item;
        break;
      }
    }
    current ??= milestoneStates.where((item) => item.needsCorrection).firstOrNull;
    current ??= milestoneStates
        .where((item) => item.status == MilestoneState.statusPending)
        .firstOrNull;
    return current == null ? null : MilestoneState.title(current.key, es: es);
  }

  /// Kotlin `hasHeavyRainRisk`: funded plots in Cusco get the rain warning.
  bool get hasHeavyRainRisk {
    final value = place.toLowerCase();
    return isFundedPlot && (value.contains('cusco') || value.contains('cuzco'));
  }

  /// Kotlin `matchesSearch`: name, crop, place or GPS coordinates.
  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [name, crop, place].any((value) => value.toLowerCase().contains(q)) ||
        [latitude, longitude].whereType<double>().any((value) => value.toString().contains(q));
  }
}

/// Kotlin `formatPlotArea`.
String formatPlotArea(String area) {
  final trimmed = area.trim();
  if (trimmed.isEmpty) return '—';
  if (trimmed.toLowerCase().contains('ha')) return trimmed;
  return '$trimmed ha';
}

/// Plot photo with the Kotlin `PlotPhoto` placeholder when there is none.
class PlotPhoto extends StatelessWidget {
  const PlotPhoto({super.key, required this.uri, this.fallbackAsset});

  final String? uri;

  /// Shown instead of the placeholder icon, as the Home crop photos.
  final String? fallbackAsset;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() {
      final asset = fallbackAsset;
      if (asset != null) {
        return Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true);
      }
      return const ColoredBox(
        color: Color(0xFFEAF9E9),
        child: Center(child: Icon(Icons.image, size: 48, color: Color(0xFF4A7C1E))),
      );
    }

    final value = uri?.trim() ?? '';
    if (value.startsWith('data:')) {
      try {
        return Image.memory(
          base64Decode(value.substring(value.indexOf(',') + 1)),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => placeholder(),
        );
      } on FormatException {
        return placeholder();
      }
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => placeholder(),
      );
    }
    return placeholder();
  }
}
