import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/bank_card.dart';

class CardBrandMark extends StatelessWidget {
  const CardBrandMark({super.key, required this.brand, this.compact = false});

  final BankCardBrand brand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = compact ? 38.0 : 54.0;
    final height = compact ? 17.0 : 22.0;
    return switch (brand) {
      BankCardBrand.visa => Image.asset(
        'assets/images/visa_logo.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticLabel: l10n.bankAccountVisaLogo,
      ),
      BankCardBrand.mastercard => SizedBox(
        width: compact ? 34 : 42,
        height: compact ? 19 : 23,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _circle(compact ? 19 : 23, const Color(0xFFEB001B)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _circle(compact ? 19 : 23, const Color(0xFFF79E1B).withValues(alpha: 0.9)),
            ),
          ],
        ),
      ),
      BankCardBrand.unknown => Icon(
        Icons.credit_card_outlined,
        size: 28,
        color: const Color(0xFF6F806E),
        semanticLabel: l10n.addCardUnknownBrand,
      ),
    };
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
