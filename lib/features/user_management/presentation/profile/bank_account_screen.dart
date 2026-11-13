import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../escrow_custody/application/payment_history_controller.dart';
import '../../../escrow_custody/domain/payment_record.dart';
import '../../application/farmer_payment_controller.dart';
import '../../application/merchant_payment_controller.dart';
import '../../domain/bank_card.dart';
import '../../domain/merchant_wallet.dart';
import 'add_bank_card_screen.dart';
import 'card_brand_mark.dart';
import 'edit_digital_wallet_screen.dart';

const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
const _border = Color(0xFF6F806E);
const _secondary = Color(0xFF777777);

class BankAccountScreen extends ConsumerWidget {
  const BankAccountScreen({super.key});

  Future<void> _open(BuildContext context, Widget page) {
    return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final card = ref.watch(merchantPaymentProvider).card;
    final wallets = ref.watch(farmerPaymentProvider);
    final balance =
        ref
            .watch(paymentHistoryProvider)
            .value
            ?.where((item) => item.status == PaymentStatus.completed)
            .fold<double>(0, (sum, item) => sum + item.amount) ??
        0.0;

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          ColoredBox(
            color: MuyuColors.navBar,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: l10n.bankAccountBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.bankAccountTitle,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              children: [
                if (card != null)
                  _DebitCard(card: card, balance: balance)
                else
                  _EmptyCard(balance: balance),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _open(context, const AddBankCardScreen()),
                  icon: const Icon(Icons.add),
                  label: Text(card == null ? l10n.bankAccountAddCard : l10n.bankAccountReplaceCard),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MuyuColors.olive,
                    side: const BorderSide(color: MuyuColors.olive, width: 1.5),
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.white,
                    shape: _shape,
                    textStyle: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.bankAccountDetails,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _DetailsCard(card: card),
                const SizedBox(height: 24),
                Text(
                  l10n.bankAccountDigitalWallets,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _WalletRow(
                  asset: 'assets/images/yape_logo.jpg',
                  title: l10n.bankAccountYape,
                  subtitle: _walletSubtitle(l10n, wallets.yape, isYape: true),
                  onTap: () => _open(
                    context,
                    const EditDigitalWalletScreen(
                      provider: DigitalWalletProvider.yape,
                      forMerchant: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _WalletRow(
                  asset: 'assets/images/plin_logo.png',
                  title: l10n.bankAccountPlin,
                  subtitle: _walletSubtitle(l10n, wallets.plin, isYape: false),
                  onTap: () => _open(
                    context,
                    const EditDigitalWalletScreen(
                      provider: DigitalWalletProvider.plin,
                      forMerchant: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.bankAccountWalletLimitNote,
                  style: const TextStyle(color: _secondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _walletSubtitle(
    AppLocalizations l10n,
    DigitalWalletAccount? account, {
    required bool isYape,
  }) {
    if (account == null) return isYape ? l10n.yapeNotLinked : l10n.plinNotLinked;
    final masked = maskWalletPhone(account.phone);
    return account.isPrimary
        ? l10n.bankAccountYapeLinkedDefaultValue(masked)
        : l10n.bankAccountYapeLinkedValue(masked);
  }
}

class _DebitCard extends StatelessWidget {
  const _DebitCard({required this.card, required this.balance});

  final SavedBankCard card;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 172,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF263B6D), Color(0xFF5756AE)]),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                card.type == BankCardType.debit
                    ? l10n.bankAccountDebitLabel
                    : l10n.bankAccountCreditLabel,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Spacer(),
              CardBrandMark(brand: card.brand),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            maskedCardNumber(card.lastFour),
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.bankAccountExpirationValue(card.expiration),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Text(
                l10n.bankAccountCvvMasked,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            l10n.bankAccountBalance(formatReleasedBalance(balance)),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 172),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card_outlined, color: MuyuColors.olive, size: 32),
          const SizedBox(height: 8),
          Text(
            l10n.bankAccountNoCardTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.bankAccountNoCardBody, style: const TextStyle(color: _secondary, fontSize: 14)),
          const SizedBox(height: 16),
          Text(
            l10n.bankAccountBalance(formatReleasedBalance(balance)),
            style: const TextStyle(
              color: MuyuColors.olive,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.card});

  final SavedBankCard? card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: card == null
          ? Text(
              l10n.bankAccountNoDetails,
              style: const TextStyle(color: Color(0xFF557052), fontSize: 13),
            )
          : Column(
              children: [
                _row(
                  l10n.bankAccountHolderLabel,
                  card!.holderName.isEmpty ? '—' : card!.holderName,
                ),
                const SizedBox(height: 9),
                _row(l10n.bankAccountCardLabel, bankCardSummary(card!)),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: const TextStyle(color: Color(0xFF557052), fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFF557052), fontSize: 13)),
        ),
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  asset,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  semanticLabel: title,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: _secondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF333333)),
            ],
          ),
        ),
      ),
    );
  }
}
