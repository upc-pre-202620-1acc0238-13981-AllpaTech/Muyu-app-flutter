import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/merchant_payment_controller.dart';
import '../../domain/bank_card.dart';
import 'card_brand_mark.dart';

const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
const _green = Color(0xFF2E7D32);
const _border = Color(0xFF6F9B61);

class AddBankCardScreen extends ConsumerStatefulWidget {
  const AddBankCardScreen({super.key});

  @override
  ConsumerState<AddBankCardScreen> createState() => _AddBankCardScreenState();
}

class _AddBankCardScreenState extends ConsumerState<AddBankCardScreen> {
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiration = TextEditingController();
  final _cvv = TextEditingController();
  BankCardType _type = BankCardType.debit;
  bool _isPrimary = true;

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    _expiration.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    await ref
        .read(merchantPaymentProvider.notifier)
        .saveCard(
          SavedBankCard(
            lastFour: digits.substring(digits.length - 4),
            holderName: _holder.text.trim(),
            expiration: _expiration.text,
            type: _type,
            brand: detectCardBrand(digits),
            isPrimary: _isPrimary,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    final brand = detectCardBrand(digits);
    final numberValid = passesLuhnCheck(digits) && brand != BankCardBrand.unknown;
    final expirationValid = validExpiration(_expiration.text);
    final holderValid = _holder.text.trim().length >= 3;
    final cvvValid = _cvv.text.length == 3;
    final canSave = numberValid && expirationValid && holderValid && cvvValid;
    final numberError = digits.length == 16 && !numberValid;

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.addCardTitle, onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.credit_card_outlined, color: Color(0xFF155B35), size: 32),
                    const SizedBox(width: 12),
                    Text(
                      l10n.addCardDataTitle,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF155B35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _Label(l10n.addCardNumber),
                TextField(
                  controller: _number,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
                  onChanged: (_) => setState(() {}),
                  decoration: _decoration(
                    hint: l10n.addCardNumberHint,
                    error: numberError ? l10n.addCardNumberError : null,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CardBrandMark(brand: brand, compact: true),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Label(l10n.addCardHolder),
                TextField(
                  controller: _holder,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  decoration: _decoration(hint: l10n.addCardHolderHint),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(l10n.addCardExpiration),
                          TextField(
                            controller: _expiration,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_ExpirationFormatter()],
                            onChanged: (_) => setState(() {}),
                            decoration: _decoration(
                              hint: l10n.addCardExpirationHint,
                              error: _expiration.text.length == 5 && !expirationValid ? ' ' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(l10n.addCardCvv),
                          TextField(
                            controller: _cvv,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            onChanged: (_) => setState(() {}),
                            decoration: _decoration(hint: '•••'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _Label(l10n.addCardType),
                Row(
                  children: [
                    Expanded(
                      child: _TypeOption(
                        label: l10n.addCardDebit,
                        selected: _type == BankCardType.debit,
                        onTap: () => setState(() => _type = BankCardType.debit),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeOption(
                        label: l10n.addCardCredit,
                        selected: _type == BankCardType.credit,
                        onTap: () => setState(() => _type = BankCardType.credit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _isPrimary = !_isPrimary),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isPrimary,
                        onChanged: (value) => setState(() => _isPrimary = value ?? false),
                        fillColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected) ? _green : Colors.white,
                        ),
                        side: const BorderSide(color: _border),
                      ),
                      Expanded(
                        child: Text(l10n.addCardPrimary, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5DA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: _green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.addCardSecurity,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF273326)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: canSave ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: canSave ? MuyuColors.olive : const Color(0xFFB8C7B9),
                      disabledBackgroundColor: const Color(0xFFB8C7B9),
                      foregroundColor: Colors.white,
                      shape: _shape,
                    ),
                    child: Text(
                      l10n.addCardSave,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({required String hint, String? error, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      errorText: error,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix == null ? null : UnconstrainedBox(child: suffix),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MuyuColors.errorBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MuyuColors.errorBorder),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF252525),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _green : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatCardNumberInput(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatExpiration(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
