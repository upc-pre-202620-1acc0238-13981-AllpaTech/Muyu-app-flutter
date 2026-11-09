import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'incident_style.dart';
import 'report_incident_photo_screen.dart';

enum _IncidentType { technical, payment, plot, other }

/// Farmer incident form from Kotlin `ReportIncidentScreen`.
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _description = TextEditingController();
  final _descriptionFocus = FocusNode();
  var _type = _IncidentType.technical;
  String? _photoPath;

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

  Future<void> _attachPhoto() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ReportIncidentPhotoScreen(initialPath: _photoPath)),
    );
    if (path != null && mounted) setState(() => _photoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: IncidentStyle.offlineBg,
                      borderRadius: BorderRadius.circular(IncidentStyle.radius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reportNoConnection,
                            style: IncidentStyle.label.copyWith(color: IncidentStyle.offlineTitle),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.reportOfflineBody,
                            style: IncidentStyle.body.copyWith(
                              fontSize: 14,
                              color: IncidentStyle.offlineBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.reportTypeLabel, style: IncidentStyle.label),
                  const SizedBox(height: 8),
                  _TypeField(
                    label: _typeLabel(l10n, _type),
                    options: [
                      for (final type in _IncidentType.values) (type, _typeLabel(l10n, type)),
                    ],
                    onSelected: (value) => setState(() => _type = value),
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
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (_) => setState(() {}),
                          style: IncidentStyle.body,
                          cursorColor: IncidentStyle.green,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: l10n.reportDescriptionHint,
                            hintStyle: IncidentStyle.body.copyWith(color: const Color(0x99000000)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IncidentButton(
                    label: _photoPath == null ? l10n.reportAttachPhoto : l10n.reportPhotoAttached,
                    filled: false,
                    onPressed: _attachPhoto,
                  ),
                  const SizedBox(height: 12),
                  IncidentButton(
                    label: l10n.reportSend,
                    filled: true,
                    enabled: canSend,
                    onPressed: () => Navigator.of(context).pop(),
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
