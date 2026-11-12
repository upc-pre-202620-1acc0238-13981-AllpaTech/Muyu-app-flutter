import 'package:flutter/material.dart';

import '../../theme/muyu_colors.dart';

/// Displays the real plot photo used by the backend and falls back to the
/// same neutral state as the Kotlin client when the image cannot be loaded.
class PlotPhoto extends StatelessWidget {
  const PlotPhoto({
    super.key,
    required this.source,
    required this.description,
    this.height = 190,
    this.borderRadius,
  });

  final String? source;
  final String description;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final value = source?.trim() ?? '';
    final placeholder = ColoredBox(
      color: const Color(0xFFEAF9E9),
      child: const Center(child: Icon(Icons.image_outlined, size: 48, color: MuyuColors.action)),
    );
    final image = value.isEmpty
        ? placeholder
        : value.startsWith('assets/')
        ? Image.asset(
            value,
            fit: BoxFit.cover,
            semanticLabel: description,
            errorBuilder: (_, _, _) => placeholder,
          )
        : Image.network(
            value,
            fit: BoxFit.cover,
            semanticLabel: description,
            errorBuilder: (_, _, _) => placeholder,
          );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(width: double.infinity, height: height, child: image),
    );
  }
}
