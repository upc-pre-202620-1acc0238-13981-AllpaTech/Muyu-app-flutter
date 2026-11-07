import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/muyu_colors.dart';
import '../../theme/muyu_theme.dart';
import 'language_toggle_button.dart';

const _fieldRadius = BorderRadius.all(Radius.circular(10));

/// Centered Fredoka title with optional back arrow and the language toggle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    tooltip: AppLocalizations.of(context).back,
                    icon: const Icon(Icons.arrow_back, color: MuyuColors.forest),
                  ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, textAlign: TextAlign.center, style: MuyuTextStyles.screenTitle),
            ),
          ),
          const SizedBox(width: 56, child: Center(child: LanguageToggleButton())),
        ],
      ),
    );
  }
}

/// Dark green sheet with large rounded top corners that holds auth forms.
class AuthSheet extends StatelessWidget {
  const AuthSheet({super.key, required this.child, this.topPadding = 28});

  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    // A Material (not a DecoratedBox) so ink from tiles and buttons shows.
    return Material(
      color: MuyuColors.forest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(63)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: EdgeInsets.fromLTRB(30, topPadding, 30, 24), child: child),
      ),
    );
  }
}

/// White label + field + optional error, the building block of auth forms.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.onToggleObscure,
    this.error,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  /// When set, shows the eye button that reveals or hides the text.
  final VoidCallback? onToggleObscure;
  final String? error;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final borderColor = error == null ? Colors.black : MuyuColors.errorBorder;
    final borderWidth = error == null ? 1.0 : 2.0;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: _fieldRadius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The visible label sits above the field, so it is hidden from screen
        // readers here and given to the TextField instead.
        ExcludeSemantics(child: Text(label, style: MuyuTextStyles.sheetLabel)),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            style: MuyuTextStyles.field,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: MuyuColors.field,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: MuyuColors.forest),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      onPressed: onToggleObscure,
                      tooltip: obscureText ? l10n.loginShowPassword : l10n.loginHidePassword,
                      icon: Icon(
                        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: MuyuColors.forest,
                      ),
                    ),
              enabledBorder: border(borderColor, borderWidth),
              focusedBorder: border(error == null ? MuyuColors.lime : MuyuColors.errorBorder, 2),
            ),
          ),
        ),
        FieldError(error),
      ],
    );
  }
}

/// Error line shown under a field, with an icon so color is not the only cue.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 18, color: MuyuColors.errorText),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: MuyuTextStyles.sheetLabel.copyWith(
                  fontSize: 14,
                  color: MuyuColors.errorText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width rounded button used for Login, Register and Next.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.background = MuyuColors.lime,
    this.foreground = Colors.black,
    this.loading = false,
    this.loadingLabel,
  });

  final String text;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.5),
          disabledForegroundColor: foreground.withValues(alpha: 0.5),
          shape: const RoundedRectangleBorder(borderRadius: _fieldRadius),
          textStyle: MuyuTextStyles.primaryButton,
        ),
        child: loading
            ? Semantics(
                label: loadingLabel,
                child: SizedBox.square(
                  dimension: 26,
                  child: CircularProgressIndicator(strokeWidth: 3, color: foreground),
                ),
              )
            : Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

/// "Question? Action" row at the bottom of the auth sheets.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          question,
          style: MuyuTextStyles.sheetLabel.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            textStyle: MuyuTextStyles.sheetLabel.copyWith(decoration: TextDecoration.underline),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
