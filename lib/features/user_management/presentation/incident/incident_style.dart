import 'package:flutter/material.dart';

import '../../../../core/theme/muyu_theme.dart';

/// Colors and shapes from Kotlin `ReportIncidentScreen` / `ReportIncidentPhotoScreen`.
abstract final class IncidentStyle {
  static const green = Color(0xFF2E7D32);
  static const fieldFill = Color(0xFFE7F5E8);
  static const fieldBorder = Color(0xFFA8C9AA);
  static const disabled = Color(0xFFB8C7B9);
  static const offlineBg = Color(0xFFFFF3DF);
  static const offlineTitle = Color(0xFF9A5A00);
  static const offlineBody = Color(0xFF6F4A16);
  static const radius = 14.0;
  static const photoRadius = 16.0;

  static const label = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.black,
  );

  static const body = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Colors.black,
  );

  static const button = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(primary: green),
    );
  }
}

class IncidentButton extends StatelessWidget {
  const IncidentButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onPressed,
    this.enabled = true,
    this.radius = IncidentStyle.radius,
    this.bordered = true,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final double radius;
  final bool bordered;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = !enabled
        ? IncidentStyle.disabled
        : filled
        ? IncidentStyle.green
        : Colors.white;
    final radius = BorderRadius.circular(this.radius);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: bordered ? Border.all(color: IncidentStyle.green, width: 1) : null,
        ),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: IncidentStyle.button.copyWith(
                color: filled ? Colors.white : IncidentStyle.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
