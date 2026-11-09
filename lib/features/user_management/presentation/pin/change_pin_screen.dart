import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/designsystem/components/auth_components.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _newPin = List<TextEditingController>.generate(4, (_) => TextEditingController());
  final _confirmPin = List<TextEditingController>.generate(4, (_) => TextEditingController());
  final _newFocus = List<FocusNode>.generate(4, (_) => FocusNode());
  final _confirmFocus = List<FocusNode>.generate(4, (_) => FocusNode());
  var _confirming = false;
  var _mismatch = false;
  var _complete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _newFocus.first.requestFocus());
  }

  @override
  void dispose() {
    for (final controller in [..._newPin, ..._confirmPin]) {
      controller.dispose();
    }
    for (final node in [..._newFocus, ..._confirmFocus]) {
      node.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _active => _confirming ? _confirmPin : _newPin;
  List<FocusNode> get _activeFocus => _confirming ? _confirmFocus : _newFocus;

  bool get _filled => _active.every((controller) => controller.text.length == 1);

  void _goBack() {
    if (_confirming) {
      setState(() {
        _confirming = false;
        _mismatch = false;
        for (final controller in _confirmPin) {
          controller.clear();
        }
      });
      _newFocus.first.requestFocus();
      return;
    }
    Navigator.of(context).pop();
  }

  void _continue() {
    if (!_confirming) {
      setState(() {
        _confirming = true;
        _mismatch = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _confirmFocus.first.requestFocus());
      return;
    }
    final pin = _newPin.map((c) => c.text).join();
    final confirm = _confirmPin.map((c) => c.text).join();
    if (pin != confirm) {
      setState(() => _mismatch = true);
      return;
    }
    for (final controller in [..._newPin, ..._confirmPin]) {
      controller.clear();
    }
    setState(() => _complete = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_complete) {
      return _PinComplete(onContinue: () => Navigator.of(context).pop());
    }

    return PopScope(
      canPop: !_confirming,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AuthHeader(
                title: _confirming ? l10n.changePinConfirmTitle : l10n.changePinTitle,
                onBack: _goBack,
              ),
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/pin_hero.png',
                height: 180,
                semanticLabel: l10n.passwordHeroDescription,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AuthSheet(
                  child: ListView(
                    children: [
                      Text(
                        _confirming ? l10n.changePinConfirmHeading : l10n.changePinHeading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          for (var i = 0; i < 4; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: _PinBox(
                                controller: _active[i],
                                focusNode: _activeFocus[i],
                                error: _mismatch,
                                label: l10n.changePinDigitLabel(i + 1),
                                onChanged: (value) {
                                  setState(() => _mismatch = false);
                                  if (value.isNotEmpty && i < 3) _activeFocus[i + 1].requestFocus();
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_mismatch)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            l10n.changePinMismatch,
                            style: const TextStyle(
                              fontFamily: MuyuFonts.urbanist,
                              fontWeight: FontWeight.w600,
                              color: MuyuColors.errorText,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.changePinDemoNotice,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                      ),
                      const SizedBox(height: 28),
                      AuthPrimaryButton(
                        text: _confirming ? l10n.changePinConfirm : l10n.changePinContinue,
                        onPressed: _filled ? _continue : null,
                      ),
                      TextButton(
                        onPressed: _goBack,
                        child: Text(
                          _confirming ? l10n.changePinEdit : l10n.changePinCancel,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: error ? const Color(0xFFB3261E) : Colors.black),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            semanticCounterText: label,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PinComplete extends StatelessWidget {
  const _PinComplete({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeader(title: l10n.changePinCompleteTitle, onBack: onContinue),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/pin_hero.png',
              height: 180,
              semanticLabel: l10n.passwordHeroDescription,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AuthSheet(
                child: Column(
                  children: [
                    Text(
                      l10n.changePinCompleteBody,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(text: l10n.passwordBackProfile, onPressed: onContinue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
