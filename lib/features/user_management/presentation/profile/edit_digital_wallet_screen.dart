import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/farmer_payment_controller.dart';
import '../../application/merchant_payment_controller.dart';
import '../../application/session_controller.dart';
import '../../domain/merchant_wallet.dart';

const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
const _green = Color(0xFF2E7D32);
const _border = Color(0xFF6F9B61);
const _danger = Color(0xFFC93434);

class EditDigitalWalletScreen extends ConsumerStatefulWidget {
  const EditDigitalWalletScreen({super.key, required this.provider, this.forMerchant = true});

  final DigitalWalletProvider provider;
  final bool forMerchant;

  @override
  ConsumerState<EditDigitalWalletScreen> createState() => _EditDigitalWalletScreenState();
}

class _EditDigitalWalletScreenState extends ConsumerState<EditDigitalWalletScreen> {
  late final TextEditingController _phone;
  late String _phoneDigits;
  late bool _verified;
  var _isPrimary = true;
  var _verificationAttempted = false;
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (widget.forMerchant) {
      final saved = ref.read(merchantPaymentProvider).wallet;
      final match = saved?.provider == widget.provider ? saved : null;
      _phoneDigits = walletPhoneDigits(match?.phone ?? '');
      _verified = match != null && isValidWalletPhone(_phoneDigits);
    } else {
      final saved = ref.read(farmerPaymentProvider).accountFor(widget.provider);
      _phoneDigits = walletPhoneDigits(saved?.phone ?? '');
      _verified = saved != null && isValidWalletPhone(_phoneDigits);
      _isPrimary = saved?.isPrimary ?? true;
    }
    _phone.text = formatWalletPhone(_phoneDigits);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save(String holderName) async {
    if (widget.forMerchant) {
      await ref.read(merchantPaymentProvider.notifier).saveWallet(
        MerchantWallet(provider: widget.provider, phone: _phoneDigits, holderName: holderName),
      );
    } else {
      await ref.read(farmerPaymentProvider.notifier).saveAccount(
        widget.provider,
        DigitalWalletAccount(
          phone: _phoneDigits,
          holderName: holderName,
          isPrimary: _isPrimary,
          isVerified: true,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _unlink() async {
    if (widget.forMerchant) {
      await ref.read(merchantPaymentProvider.notifier).unlinkWallet();
    } else {
      await ref.read(farmerPaymentProvider.notifier).unlinkAccount(widget.provider);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final isYape = widget.provider == DigitalWalletProvider.yape;
    final merchantSaved = ref.watch(merchantPaymentProvider).wallet;
    final farmerSaved = ref.watch(farmerPaymentProvider).accountFor(widget.provider);
    final linked = widget.forMerchant
        ? merchantSaved?.provider == widget.provider
        : farmerSaved != null;
    final savedHolder = widget.forMerchant
        ? (merchantSaved?.provider == widget.provider ? merchantSaved?.holderName : null)
        : farmerSaved?.holderName;
    final holderName = (savedHolder?.trim().isNotEmpty ?? false)
        ? savedHolder!
        : (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : '';
    final phoneValid = isValidWalletPhone(_phoneDigits);

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: isYape ? l10n.yapeEditTitle : l10n.plinEditTitle,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD8DDD8)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          isYape ? 'assets/images/yape_logo.jpg' : 'assets/images/plin_logo.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          semanticLabel: isYape ? l10n.bankAccountYape : l10n.bankAccountPlin,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  isYape ? l10n.bankAccountYape : l10n.bankAccountPlin,
                                  style: const TextStyle(
                                    fontFamily: MuyuFonts.urbanist,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: Color(0xFF064E25),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE4F4DC),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    linked ? l10n.yapeLinked : l10n.yapeNotLinked,
                                    style: const TextStyle(
                                      fontFamily: MuyuFonts.urbanist,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: _green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              maskWalletPhone(_phoneDigits).isEmpty ? l10n.yapeNoPhone : maskWalletPhone(_phoneDigits),
                              style: const TextStyle(fontSize: 17, color: Color(0xFF555555)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.yapeAccountData,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0xFF155B35),
                  ),
                ),
                const SizedBox(height: 18),
                _Label(l10n.yapePhoneLabel),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [_WalletPhoneFormatter()],
                  onChanged: (value) {
                    setState(() {
                      _phoneDigits = walletPhoneDigits(value);
                      _verified = false;
                      _verificationAttempted = false;
                    });
                  },
                  decoration: InputDecoration(
                    prefixText: '+51 ',
                    errorText: _verificationAttempted && !phoneValid ? l10n.yapePhoneError : null,
                    filled: true,
                    fillColor: Colors.white,
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
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _verificationAttempted = true;
                      _verified = phoneValid;
                    }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF155B35),
                      side: const BorderSide(color: _green, width: 1.5),
                      shape: _shape,
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    child: Text(l10n.yapeVerifyPhone),
                  ),
                ),
                if (_verified) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5DA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: _green, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.yapePhoneVerified,
                            style: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF234B22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _Label(l10n.yapeHolderLabel),
                InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F2F1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD0D5D0)),
                    ),
                  ),
                  child: Text(holderName, style: const TextStyle(color: Color(0xFF222222), fontSize: 16)),
                ),
                if (!widget.forMerchant) ...[
                  const SizedBox(height: 14),
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
                          child: Text(
                            isYape ? l10n.yapePrimary : l10n.plinPrimary,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5DA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF155B35), size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.forMerchant ? l10n.merchantWalletPaymentInfo : l10n.yapeDisbursementInfo,
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
                    onPressed: _verified ? () => _save(holderName) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _verified ? MuyuColors.olive : const Color(0xFFB8C7B9),
                      disabledBackgroundColor: const Color(0xFFB8C7B9),
                      foregroundColor: Colors.white,
                      shape: _shape,
                    ),
                    child: Text(
                      l10n.yapeSaveChanges,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                if (linked) ...[
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: _unlink,
                      child: Text(
                        isYape ? l10n.yapeUnlink : l10n.plinUnlink,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: _danger,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletPhoneFormatter extends TextInputFormatter {
  const _WalletPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatWalletPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
