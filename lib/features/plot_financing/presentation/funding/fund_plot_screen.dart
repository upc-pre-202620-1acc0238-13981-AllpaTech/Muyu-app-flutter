import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../plot_approval/domain/farmer_plot_repository.dart';
import '../../../plot_approval/domain/plot.dart';
import '../../../plot_approval/domain/plot_finance.dart';
import '../../../plot_approval/presentation/myplots/farmer_plot_display.dart';
import '../../application/merchant_financing_controller.dart';
import '../../domain/payment_method.dart';
import 'receipt_pdf.dart';

enum _FundingStage { summary, payment }

class FundPlotScreen extends ConsumerStatefulWidget {
  const FundPlotScreen({super.key, required this.plot});

  final Plot plot;

  @override
  ConsumerState<FundPlotScreen> createState() => _FundPlotScreenState();
}

class _FundPlotScreenState extends ConsumerState<FundPlotScreen> {
  _FundingStage stage = _FundingStage.summary;
  PaymentMethod method = PaymentMethod.card;
  bool accepted = false;
  bool sending = false;
  bool failed = false;

  String get _amountLabel => PlotFinance.displayAmount(widget.plot.amount);

  void _goBack() {
    if (stage == _FundingStage.payment) {
      setState(() => stage = _FundingStage.summary);
      return;
    }
    Navigator.pop(context);
  }

  Future<void> confirm() async {
    if (!accepted || sending) return;
    setState(() {
      sending = true;
      failed = false;
    });
    try {
      final result = await ref
          .read(merchantFinancingProvider.notifier)
          .fundPlot(widget.plot.id, method);
      if (!mounted) return;
      final nav = Navigator.of(context);
      await nav.push<void>(
        MaterialPageRoute(
          builder: (_) => FundSuccessScreen(
            plot: widget.plot,
            result: result,
            onViewPlot: () {
              nav.pop();
              nav.pop();
            },
          ),
        ),
      );
    } on PlotException {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = stage == _FundingStage.summary;
    final canPay = accepted && !sending;
    final buttonEnabled = summary || canPay;
    final buttonLabel = sending
        ? l10n.merchantContinue
        : summary
        ? l10n.merchantContinue
        : accepted
        ? l10n.merchantConfirmAndPay(_amountLabel)
        : l10n.merchantAcceptFirst;

    return PopScope(
      canPop: summary,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        body: Column(
          children: [
            GreenTitleHeader(title: l10n.merchantFundTitle, onBack: _goBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: [
                  if (summary) ...[
                    _FundBanner(plot: widget.plot, amount: _amountLabel),
                    const SizedBox(height: 12),
                    _ListedAmountRow(label: l10n.merchantListedAmount, chip: l10n.merchantFixedAmount),
                    const SizedBox(height: 12),
                    _DisbursementCard(total: PlotFinance.parseAmount(widget.plot.amount)),
                    const SizedBox(height: 12),
                    const _EscrowProtectCard(),
                  ] else ...[
                    _PaymentMethodCard(
                      method: method,
                      onMethod: sending ? null : (value) => setState(() => method = value),
                    ),
                    const SizedBox(height: 16),
                    _TermsCard(
                      accepted: accepted,
                      onChanged: sending ? null : (value) => setState(() => accepted = value),
                    ),
                  ],
                  if (failed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        l10n.merchantPayFailed,
                        style: const TextStyle(color: MuyuColors.errorBorder),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _FundButton(
                    enabled: buttonEnabled,
                    loading: sending,
                    label: buttonLabel,
                    onTap: summary
                        ? () => setState(() => stage = _FundingStage.payment)
                        : confirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FundSuccessScreen extends StatelessWidget {
  const FundSuccessScreen({
    super.key,
    required this.plot,
    required this.result,
    required this.onViewPlot,
  });

  final Plot plot;
  final FinancingResult result;
  final VoidCallback onViewPlot;

  String get _amount => PlotFinance.displayAmount(plot.amount);

  Future<void> _download(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final method = _payLabel(l10n, result.paymentMethod);
    final status = l10n.merchantHeldInEscrow;
    try {
      final pdf = buildFundingReceiptPdf(
        title: l10n.merchantFundsSecured,
        plotName: plot.name,
        amount: _amount,
        paymentMethod: method,
        status: status,
      );
      final safeName = plot.name.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final fileName = 'muyu_receipt_${safeName.isEmpty ? 'plot' : safeName}.pdf';
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdf, flush: true);
      if (!context.mounted) return;
      final opened = await launchUrl(Uri.file(file.path));
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.merchantReceiptSaved(file.path))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.merchantReceiptSaveFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final method = _payLabel(l10n, result.paymentMethod);
    final date = DateFormat('d MMM yyyy', locale).format(DateTime.now());
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: l10n.merchantFundSuccessTitle,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/merchant_success_mascot.png',
                    width: 128,
                    height: 120,
                    fit: BoxFit.contain,
                    semanticLabel: l10n.merchantFundsSecured,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.merchantFundsSecured,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.merchantSuccessBody(
                    plot.name,
                    plot.ownerName.trim().isEmpty ? plot.ownerEmail : plot.ownerName,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontSize: 16,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: MuyuColors.forest),
                  ),
                  child: Column(
                    children: [
                      _ReceiptRow(
                        label: l10n.merchantAmountFunded,
                        value: _amount,
                        extraBold: true,
                      ),
                      const Divider(height: 1, color: Color(0x33213D09)),
                      _ReceiptRow(label: l10n.merchantPaymentMethodLabel, value: method),
                      const Divider(height: 1, color: Color(0x33213D09)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.merchantReceiptStatus,
                                style: const TextStyle(
                                  fontFamily: MuyuFonts.urbanist,
                                  fontSize: 16,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            ),
                            Container(
                              height: 23,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: MuyuColors.approvedBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.merchantHeldInEscrow,
                                style: const TextStyle(
                                  fontFamily: MuyuFonts.urbanist,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: MuyuColors.forest,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0x33213D09)),
                      _ReceiptRow(label: l10n.merchantReceiptDate, value: date),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: MuyuColors.escrowNote,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    l10n.merchantReleaseNote,
                    style: const TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: MuyuColors.infoBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SuccessButton(
                  label: l10n.merchantViewFinancedPlot,
                  filled: true,
                  onTap: onViewPlot,
                ),
                const SizedBox(height: 14),
                _SuccessButton(
                  label: l10n.merchantDownloadReceipt,
                  filled: false,
                  onTap: () => _download(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value, this.extraBold = false});

  final String label;
  final String value;
  final bool extraBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontSize: 16,
                color: Color(0xFF777777),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: extraBold ? FontWeight.w900 : FontWeight.w600,
              fontSize: 15,
              color: MuyuColors.receiptGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessButton extends StatelessWidget {
  const _SuccessButton({required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? MuyuColors.olive : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(filled ? 16 : 20),
        side: filled ? BorderSide.none : const BorderSide(color: MuyuColors.forest),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 62,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: filled ? const Color(0xFFFFFEFE) : MuyuColors.forest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FundBanner extends StatelessWidget {
  const _FundBanner({required this.plot, required this.amount});

  final Plot plot;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: MuyuColors.fundBanner,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantTotalInvestment,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xB3FFFFFF),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: MuyuFonts.fredoka,
              fontWeight: FontWeight.w600,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          Text(
            '${plot.name}  ·  ${plot.crop}  ·  ${formatPlotArea(plot.area)}',
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xB3FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListedAmountRow extends StatelessWidget {
  const _ListedAmountRow({required this.label, required this.chip});

  final String label;
  final String chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: MuyuColors.skip,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Container(
            height: 23,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: MuyuColors.grayChip,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              chip,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: MuyuColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisbursementCard extends StatelessWidget {
  const _DisbursementCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = PlotFinance.disbursement(total);
    final titles = [
      l10n.publishPlanPlanting,
      l10n.publishPlanIrrigation,
      l10n.publishPlanFertilization,
      l10n.publishPlanHarvest,
    ];
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantDisbursement,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++) ...[
            _PlanRow(
              step: i + 1,
              title: titles[i],
              amount: PlotFinance.formatAmount(steps[i]),
              percent: _percentLabel(steps[i], total),
            ),
            if (i < steps.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0x33213D09)),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.step,
    required this.title,
    required this.amount,
    required this.percent,
  });

  final int step;
  final String title;
  final String amount;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MuyuColors.forest),
            ),
            child: Text(
              '$step',
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: MuyuColors.forest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: MuyuColors.forest,
                ),
              ),
              Text(
                percent,
                style: TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EscrowProtectCard extends StatelessWidget {
  const _EscrowProtectCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MuyuColors.escrowInfo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantEscrowHow,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _EscrowStep(number: '1', label: l10n.merchantEscrowSafe)),
              Expanded(child: _EscrowStep(number: '2', label: l10n.merchantEscrowApprove)),
              Expanded(child: _EscrowStep(number: '3', label: l10n.merchantEscrowHarvest)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EscrowStep extends StatelessWidget {
  const _EscrowStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: MuyuColors.escrowStep,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFFFFFEFE),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.method, required this.onMethod});

  final PaymentMethod method;
  final ValueChanged<PaymentMethod>? onMethod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantPaymentMethodTitle,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in PaymentMethod.values)
                      _MethodChip(
                        label: _payLabel(l10n, option),
                        selected: method == option,
                        onTap: onMethod == null ? null : () => onMethod!(option),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/merchant_pago.png',
                width: 114,
                height: 107,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MuyuColors.olive : MuyuColors.grayChip,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MuyuColors.termsBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: MuyuColors.forest),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!accepted),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accepted ? MuyuColors.olive : MuyuColors.checkbox,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: accepted
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).merchantFundTerms,
                  style: const TextStyle(
                    fontFamily: MuyuFonts.urbanist,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FundButton extends StatelessWidget {
  const _FundButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? MuyuColors.olive : MuyuColors.termsBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: Center(
            child: loading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: enabled ? Colors.white : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MuyuColors.forest),
      ),
      child: child,
    );
  }
}

String _payLabel(AppLocalizations l10n, PaymentMethod method) => switch (method) {
  PaymentMethod.card => l10n.merchantPayCard,
  PaymentMethod.wallet => l10n.merchantPayWallet,
  PaymentMethod.agentDeposit => l10n.merchantPayAgent,
  PaymentMethod.bankTransfer => l10n.merchantPayBank,
};

String _percentLabel(double amount, double total) {
  if (total <= 0) return '0.00%';
  return '${((amount / total) * 100).toStringAsFixed(2)}%';
}
