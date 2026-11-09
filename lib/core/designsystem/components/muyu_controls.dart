import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';

/// White pill search field from the farmer Home and My Plots screens.
class MuyuSearchField extends StatelessWidget {
  const MuyuSearchField({super.key, required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: MuyuTextStyles.body.copyWith(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: MuyuTextStyles.body.copyWith(color: MuyuColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: Colors.black, size: 20),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Filter pill: dark green when selected, soft green otherwise.
class MuyuFilterChip extends StatelessWidget {
  const MuyuFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? MuyuColors.navBar : MuyuColors.skip,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              label,
              style: MuyuTextStyles.bodyBold.copyWith(
                color: selected ? Colors.white : MuyuColors.nearText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Peru flag shown next to the country in the role headers.
class PeruFlag extends StatelessWidget {
  const PeruFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).farmerFlagPeru,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: const SizedBox(
          width: 28,
          height: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ColoredBox(color: Color(0xFFD22F27))),
              Expanded(child: ColoredBox(color: Colors.white)),
              Expanded(child: ColoredBox(color: Color(0xFFD22F27))),
            ],
          ),
        ),
      ),
    );
  }
}
