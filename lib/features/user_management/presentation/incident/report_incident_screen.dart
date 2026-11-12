import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/support_controller.dart';
import 'incident_style.dart';

enum _IncidentType { technical, payment, plot, other }

/// Farmer incident form from Kotlin `ReportIncidentScreen`. The report is sent
/// to the backend (`mobile/incidents`), which stores its type and description.
class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _description = TextEditingController();
  final _descriptionFocus = FocusNode();
  var _type = _IncidentType.technical;
  bool _sending = false;
  SupportFailure? _failure;

  @override
  void initState() {
    super.initState();
    _descriptionFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _description.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, _IncidentType type) => switch (type) {
    _IncidentType.technical => l10n.reportTypeTechnical,
    _IncidentType.payment => l10n.reportTypePayment,
    _IncidentType.plot => l10n.reportTypePlot,
    _IncidentType.other => l10n.reportTypeOther,
  };

  Future<void> _send() async {
    final es = Localizations.localeOf(context).languageCode == 'es';
    setState(() {
      _sending = true;
      _failure = null;
    });
    try {
      final report = await ref
          .read(supportServiceProvider)
          .reportIncident(type: _type.name, description: _description.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            es
                ? 'Reporte #${report.id} enviado. El equipo de soporte lo revisará.'
                : 'Report #${report.id} sent. The support team will review it.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on SupportException catch (error) {
      if (mounted) {
        setState(() {
          _sending = false;
          _failure = error.failure;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final canSend = _description.text.trim().isNotEmpty;
    final focused = _descriptionFocus.hasFocus;

    return Theme(
      data: IncidentStyle.theme(context),
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        body: Column(
          children: [
            GreenTitleHeader(title: l10n.reportTitle, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  if (_failure != null) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: IncidentStyle.offlineBg,
                        borderRadius: BorderRadius.circular(IncidentStyle.radius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          switch (_failure!) {
                            SupportFailure.network =>
                              es
                                  ? 'Sin conexión. Tu reporte no se envió; inténtalo cuando tengas señal.'
                                  : 'No connection. Your report was not sent; try again when you have signal.',
                            SupportFailure.sessionExpired =>
                              es
                                  ? 'Tu sesión expiró. Vuelve a iniciar sesión.'
                                  : 'Your session expired. Sign in again.',
                            SupportFailure.rejected =>
                              es
                                  ? 'El servidor no aceptó el reporte. Revisa la descripción.'
                                  : 'The server did not accept the report. Check the description.',
                          },
                          style: IncidentStyle.body.copyWith(
                            fontSize: 14,
                            color: IncidentStyle.offlineBody,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(l10n.reportTypeLabel, style: IncidentStyle.label),
                  const SizedBox(height: 8),
                  _TypeField(
                    label: _typeLabel(l10n, _type),
                    options: [
                      for (final type in _IncidentType.values) (type, _typeLabel(l10n, type)),
                    ],
                    onSelected: (value) {
                      if (!_sending) setState(() => _type = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.reportDescriptionLabel, style: IncidentStyle.label),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 130,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: IncidentStyle.fieldFill,
                        borderRadius: BorderRadius.circular(IncidentStyle.radius),
                        border: Border.all(
                          color: focused ? IncidentStyle.green : IncidentStyle.fieldBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _description,
                          focusNode: _descriptionFocus,
                          enabled: !_sending,
                          maxLength: 2000,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (_) => setState(() {}),
                          style: IncidentStyle.body,
                          cursorColor: IncidentStyle.green,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            counterText: '',
                            hintText: l10n.reportDescriptionHint,
                            hintStyle: IncidentStyle.body.copyWith(color: const Color(0x99000000)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IncidentButton(
                    label: _sending ? (es ? 'Enviando…' : 'Sending…') : l10n.reportSend,
                    filled: true,
                    enabled: canSend && !_sending,
                    onPressed: _send,
                  ),
                  const SizedBox(height: 24),
                  const _MyReports(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField({required this.label, required this.options, required this.onSelected});

  final String label;
  final List<(_IncidentType, String)> options;
  final ValueChanged<_IncidentType> onSelected;

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final selected = await showMenu<_IncidentType>(
      context: context,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IncidentStyle.radius)),
      constraints: BoxConstraints(minWidth: box.size.width, maxWidth: box.size.width),
      position: RelativeRect.fromLTRB(
        topLeft.dx,
        topLeft.dy + box.size.height,
        overlay.size.width - topLeft.dx - box.size.width,
        overlay.size.height - topLeft.dy - box.size.height,
      ),
      items: [
        for (final (type, text) in options)
          PopupMenuItem(
            value: type,
            child: Text(text, style: IncidentStyle.body),
          ),
      ],
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _open(context),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: IncidentStyle.fieldFill,
              borderRadius: BorderRadius.circular(IncidentStyle.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: IncidentStyle.body)),
                  const Text(
                    '⌄',
                    style: TextStyle(
                      fontFamily: MuyuFonts.urbanist,
                      color: IncidentStyle.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Incidents the user already sent, so they can see their report reached support.
class _MyReports extends ConsumerWidget {
  const _MyReports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(myIncidentsProvider).value ?? const <IncidentReport>[];
    if (reports.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final locale = Localizations.localeOf(context).toString();
    String typeLabel(String type) => switch (type) {
      'technical' => l10n.reportTypeTechnical,
      'payment' => l10n.reportTypePayment,
      'plot' => l10n.reportTypePlot,
      _ => l10n.reportTypeOther,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(es ? 'Mis reportes' : 'My reports', style: IncidentStyle.label),
        const SizedBox(height: 8),
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(IncidentStyle.radius),
                border: Border.all(color: IncidentStyle.fieldBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${report.id} · ${typeLabel(report.type)}'
                      '${report.createdAt == null ? '' : ' · ${DateFormat.yMMMd(locale).format(report.createdAt!)}'}',
                      style: IncidentStyle.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(report.description, style: IncidentStyle.body.copyWith(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
