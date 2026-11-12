import 'package:flutter/material.dart';

import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';

/// Initials chip used on plot cards when the farmer has no photo.
class FarmerAvatar extends StatelessWidget {
  const FarmerAvatar({super.key, required this.name, this.size = 22, this.imageAsset});

  final String name;
  final double size;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final photo = imageAsset;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: MuyuColors.action,
        child: photo == null || photo.isEmpty
            ? Text(
                initialsOf(name),
                style: TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.4,
                  color: Colors.white,
                  height: 1,
                ),
              )
            : Image.asset(photo, width: size, height: size, fit: BoxFit.cover, semanticLabel: name),
      ),
    );
  }
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
  if (parts.isEmpty) return '?';
  return parts.map((part) => part[0].toUpperCase()).join();
}
