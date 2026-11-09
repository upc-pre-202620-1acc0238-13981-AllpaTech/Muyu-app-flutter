import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../plot_approval/domain/farmer_plot_repository.dart';
import '../../../plot_approval/domain/plot.dart';
import '../../application/merchant_financing_controller.dart';
import '../../domain/payment_method.dart';

class FundPlotScreen extends ConsumerStatefulWidget {
  const FundPlotScreen({super.key, required this.plot});

  final Plot plot;

  @override
  ConsumerState<FundPlotScreen> createState() => _FundPlotScreenState();
}

class _FundPlotScreenState extends ConsumerState<FundPlotScreen> {
  PaymentMethod method = PaymentMethod.card;
  bool accepted = false;
  bool sending = false;
  bool failed = false;

  bool get es => Localizations.localeOf(context).languageCode == 'es';

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
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FinancingSuccessScreen(plot: widget.plot, result: result),
        ),
      );
    } on PlotException {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MuyuColors.background,
    body: Column(
      children: [
        GreenTitleHeader(
          title: es ? 'Financiar parcela' : 'Fund plot',
          onBack: () => Navigator.pop(context),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Summary(plot: widget.plot),
              const SizedBox(height: 16),
              _Panel(
                title: es ? 'Método de pago' : 'Payment method',
                child: Column(
                  children: [
                    for (final option in PaymentMethod.values)
                      ListTile(
                        enabled: !sending,
                        onTap: sending ? null : () => setState(() => method = option),
                        leading: Icon(
                          option == method ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: MuyuColors.action,
                        ),
                        title: Text(option.label(es)),
                        subtitle: Text(
                          option.requiresVerification
                              ? (es ? 'El pago será verificado' : 'Payment will be verified')
                              : (es ? 'Confirmación inmediata' : 'Immediate confirmation'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                title: es ? 'Términos y condiciones' : 'Terms and conditions',
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: accepted,
                  onChanged: sending ? null : (value) => setState(() => accepted = value ?? false),
                  title: Text(
                    es
                        ? 'Acepto que el monto se mantenga en custodia y se libere por hitos.'
                        : 'I accept that funds are held in escrow and released by milestones.',
                  ),
                ),
              ),
              if (failed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    es ? 'No se pudo registrar el pago.' : 'The payment could not be registered.',
                    style: const TextStyle(color: MuyuColors.errorBorder),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: accepted && !sending ? confirm : null,
                child: sending
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        es
                            ? 'Confirmar y pagar ${widget.plot.amount}'
                            : 'Confirm and pay ${widget.plot.amount}',
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class FinancingSuccessScreen extends StatelessWidget {
  const FinancingSuccessScreen({super.key, required this.plot, required this.result});

  final Plot plot;
  final FinancingResult result;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final pending = result.pendingVerification;
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pending ? Icons.hourglass_top_rounded : Icons.lock_outline_rounded,
                size: 90,
                color: pending ? MuyuColors.pendingText : MuyuColors.forest,
              ),
              const SizedBox(height: 24),
              Text(
                pending
                    ? (es ? 'Pago en verificación' : 'Payment under verification')
                    : (es ? 'Financiamiento confirmado' : 'Financing confirmed'),
                textAlign: TextAlign.center,
                style: MuyuTextStyles.screenTitle,
              ),
              const SizedBox(height: 12),
              Text(
                pending
                    ? (es
                          ? 'Validaremos el pago de ${plot.name} antes de mover los fondos a custodia.'
                          : 'We will verify the payment for ${plot.name} before moving funds to escrow.')
                    : (es
                          ? '${plot.name} ya está financiada y los fondos están en custodia.'
                          : '${plot.name} is funded and the funds are held in escrow.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(es ? 'Volver a mis parcelas' : 'Back to my plots'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.plot});
  final Plot plot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: MuyuColors.navBar, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(plot.name, style: MuyuTextStyles.headerTitle),
        const SizedBox(height: 8),
        Text(
          '${plot.crop} · ${plot.area} · ${plot.place}',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(plot.amount, style: MuyuTextStyles.headerTitle),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: MuyuColors.forest),
      borderRadius: BorderRadius.circular(18),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MuyuTextStyles.bodyBold),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}
