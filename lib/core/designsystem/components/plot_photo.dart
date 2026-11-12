import 'dart:convert';

import 'package:flutter/material.dart';

import '../../theme/muyu_colors.dart';

/// Displays the real plot photo used by the backend and falls back to the
/// same neutral state as the Kotlin `PlotPhoto` when there is none or it fails.
///
/// Kotlin uploads photos as `data:image/...;base64,` URLs, so those are decoded
/// here; web URLs and bundled assets are loaded as they are.
class PlotPhoto extends StatelessWidget {
  const PlotPhoto({
    super.key,
    required this.source,
    required this.description,
    this.height = 190,
    this.borderRadius,
    this.fallbackAsset,
  });

  final String? source;
  final String description;

  /// Fixed height, or null to fill the space the parent gives it.
  final double? height;
  final BorderRadius? borderRadius;

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
        child: Center(child: Icon(Icons.image_outlined, size: 48, color: MuyuColors.action)),
      );
    }

    final value = source?.trim() ?? '';
    Widget image;
    if (value.startsWith('data:')) {
      try {
        image = Image.memory(
          base64Decode(value.substring(value.indexOf(',') + 1)),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          semanticLabel: description,
          errorBuilder: (_, _, _) => placeholder(),
        );
      } on FormatException {
        image = placeholder();
      }
    } else if (value.startsWith('assets/')) {
      image = Image.asset(
        value,
        fit: BoxFit.cover,
        semanticLabel: description,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else if (value.startsWith('http://') || value.startsWith('https://')) {
      image = Image.network(
        value,
        fit: BoxFit.cover,
        semanticLabel: description,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else {
      // Empty, or a phone-only path such as content:// that other devices cannot open.
      image = placeholder();
    }

    final sized = height == null
        ? SizedBox.expand(child: image)
        : SizedBox(width: double.infinity, height: height, child: image);
    return ClipRRect(borderRadius: borderRadius ?? BorderRadius.zero, child: sized);
  }
}
