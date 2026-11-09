import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../../domain/farmer_plot_repository.dart';
import '../../domain/plot_finance.dart';

const _cycleOptions = [3, 6, 9, 12];
const _stepCount = 3;

/// Three-step publish flow: plot information, location and financing.
/// Pops with `true` once the plot is saved on the backend.
class PublishPlotScreen extends ConsumerStatefulWidget {
  const PublishPlotScreen({super.key});

  @override
  ConsumerState<PublishPlotScreen> createState() => _PublishPlotScreenState();
}

class _PublishPlotScreenState extends ConsumerState<PublishPlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _crop = TextEditingController();
  final _area = TextEditingController();
  final _region = TextEditingController();
  final _province = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _harvest;
  bool _harvestMissing = false;
  int _cycleMonths = 6;
  bool _acceptedCustody = false;
  bool _publishing = false;
  int _step = 0;
  PlotFailure? _failure;

  @override
  void dispose() {
    for (final c in [_name, _crop, _area, _region, _province, _district, _address, _amount]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickHarvest() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvest ?? today.add(const Duration(days: 90)),
      firstDate: today.add(const Duration(days: 1)),
      lastDate: DateTime(today.year + 5, today.month, today.day),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        _harvest = picked;
        _harvestMissing = false;
      });
    }
  }

  void _next() {
    final valid = _formKey.currentState!.validate();
    final harvestOk = _step != 0 || _harvest != null;
    setState(() => _harvestMissing = !harvestOk);
    if (valid && harvestOk) setState(() => _step++);
  }

  void _back() {
    if (_step == 0 || _publishing) {
      if (!_publishing) Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _step--;
      _failure = null;
    });
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _publishing = true;
      _failure = null;
    });
    final place = [
      _address,
      _district,
      _province,
      _region,
    ].map((c) => c.text.trim()).where((part) => part.isNotEmpty).join(', ');
    try {
      await ref
          .read(farmerPlotsProvider.notifier)
          .publish(
            NewFarmerPlot(
              name: _name.text.trim(),
              crop: _crop.text.trim(),
              area: '${_area.text.trim()} ha',
              // Same language-independent formats the Kotlin app stores.
              harvestDate: DateFormat('d MMM yyyy', 'en_US').format(_harvest!),
              place: place,
              amount: PlotFinance.formatAmount(PlotFinance.parseAmount(_amount.text)),
              cycle: '$_cycleMonths months',
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on PlotException catch (e) {
      if (mounted) setState(() => _failure = e.failure);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? AppLocalizations.of(context).publishRequired : null;

  String? _positiveNumber(String? value) => PlotFinance.parseAmount(value ?? '') > 0
      ? null
      : AppLocalizations.of(context).publishNumberInvalid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final section = [l10n.publishStepInfo, l10n.publishStepLocation, l10n.publishStepFinancing];

    return PopScope(
      canPop: _step == 0 && !_publishing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        body: Column(
          children: [
            GreenTitleHeader(title: l10n.publishTitle, onBack: _back),
            Expanded(
              child: SafeArea(
                top: false,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          '${l10n.publishStep(_step + 1, _stepCount)} · ${section[_step]}',
                          style: const TextStyle(
                            fontFamily: MuyuFonts.urbanist,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: MuyuColors.action,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (_step + 1) / _stepCount,
                        color: MuyuColors.action,
                        backgroundColor: MuyuColors.skip,
                      ),
                      const SizedBox(height: 18),
                      ...switch (_step) {
                        0 => _infoStep(l10n),
                        1 => _locationStep(l10n),
                        _ => _financingStep(l10n),
                      },
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _infoStep(AppLocalizations l10n) => [
    _Field(label: l10n.publishPlotName, controller: _name, validator: _required),
    _Field(label: l10n.publishCrop, controller: _crop, validator: _required),
    _Field(
      label: l10n.publishArea,
      controller: _area,
      validator: _positiveNumber,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    ),
    _HarvestField(
      label: l10n.publishHarvest,
      hint: l10n.publishHarvestHint,
      value: _harvest,
      error: _harvestMissing ? l10n.publishRequired : null,
      onTap: _pickHarvest,
    ),
    const SizedBox(height: 12),
    AuthPrimaryButton(
      text: l10n.publishNextLocation,
      background: MuyuColors.action,
      foreground: Colors.white,
      onPressed: _next,
    ),
  ];

  List<Widget> _locationStep(AppLocalizations l10n) => [
    _Field(label: l10n.publishRegion, controller: _region, validator: _required),
    _Field(label: l10n.publishProvince, controller: _province, validator: _required),
    _Field(label: l10n.publishDistrict, controller: _district, validator: _required),
    _Field(label: l10n.publishAddress, controller: _address, validator: _required),
    const SizedBox(height: 12),
    AuthPrimaryButton(
      text: l10n.publishNextFinancing,
      background: MuyuColors.action,
      foreground: Colors.white,
      onPressed: _next,
    ),
  ];

  List<Widget> _financingStep(AppLocalizations l10n) {
    final amounts = PlotFinance.disbursement(PlotFinance.parseAmount(_amount.text));
    final names = [
      l10n.publishPlanPlanting,
      l10n.publishPlanIrrigation,
      l10n.publishPlanFertilization,
      l10n.publishPlanHarvest,
    ];
    return [
      _Field(
        label: l10n.publishTotal,
        controller: _amount,
        validator: _positiveNumber,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}),
      ),
      DropdownButtonFormField<int>(
        initialValue: _cycleMonths,
        decoration: _decoration(l10n.publishCycle),
        items: [
          for (final months in _cycleOptions)
            DropdownMenuItem(value: months, child: Text(l10n.publishCycleMonths(months))),
        ],
        onChanged: (months) => setState(() => _cycleMonths = months ?? _cycleMonths),
      ),
      const SizedBox(height: 14),
      Text(l10n.publishMilestones, style: MuyuTextStyles.bodySemiBold),
      const SizedBox(height: 14),
      Text(
        l10n.publishPlan,
        style: const TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: MuyuColors.forest,
        ),
      ),
      const SizedBox(height: 6),
      for (var i = 0; i < names.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text('${i + 1}. ${names[i]}')),
              Text(
                PlotFinance.formatAmount(amounts[i]),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      const SizedBox(height: 14),
      Text(l10n.publishFundsHeld),
      CheckboxListTile(
        value: _acceptedCustody,
        onChanged: (value) => setState(() => _acceptedCustody = value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: MuyuColors.action,
        title: Text(l10n.publishAcceptCustody),
      ),
      if (_failure != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Semantics(
            liveRegion: true,
            child: Text(
              _failure == PlotFailure.network ? l10n.loginNetworkError : l10n.publishRejected,
              style: const TextStyle(color: MuyuColors.errorBorder, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      AuthPrimaryButton(
        text: l10n.publishConfirm,
        background: MuyuColors.olive,
        foreground: Colors.white,
        loading: _publishing,
        onPressed: _acceptedCustody ? _publish : null,
      ),
    ];
  }
}

InputDecoration _decoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: MuyuColors.field,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
);

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        decoration: _decoration(label),
      ),
    );
  }
}

class _HarvestField extends StatelessWidget {
  const _HarvestField({
    required this.label,
    required this.hint,
    required this.value,
    required this.error,
    required this.onTap,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: _decoration(label).copyWith(
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_today_outlined, color: MuyuColors.forest),
          ),
          child: Text(
            date == null ? hint : MaterialLocalizations.of(context).formatMediumDate(date),
            style: TextStyle(color: date == null ? Colors.black54 : Colors.black),
          ),
        ),
      ),
    );
  }
}
