import 'package:flutter/material.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';

const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
const _green = Color(0xFF2E7D32);

enum _IncidentType { technical, payment, plot, other }

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _description = TextEditingController();
  var _type = _IncidentType.technical;
  var _photoAttached = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, _IncidentType type) => switch (type) {
    _IncidentType.technical => l10n.reportTypeTechnical,
    _IncidentType.payment => l10n.reportTypePayment,
    _IncidentType.plot => l10n.reportTypePlot,
    _IncidentType.other => l10n.reportTypeOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.reportTitle, onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3DF), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reportNoConnection,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF9A5A00)),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.reportOfflineBody, style: const TextStyle(fontSize: 14, color: Color(0xFF6F4A16))),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(l10n.reportTypeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                PopupMenuButton<_IncidentType>(
                  onSelected: (value) => setState(() => _type = value),
                  itemBuilder: (context) => [
                    for (final type in _IncidentType.values)
                      PopupMenuItem(value: type, child: Text(_label(l10n, type))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(color: const Color(0xFFE7F5E8), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(child: Text(_label(l10n, _type))),
                        const Text('⌄', style: TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(l10n.reportDescriptionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _description,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.reportDescriptionHint,
                    filled: true,
                    fillColor: const Color(0xFFE7F5E8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFA8C9AA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _green),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _photoAttached = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _green,
                      side: const BorderSide(color: _green),
                      backgroundColor: Colors.white,
                      shape: _shape,
                    ),
                    child: Text(_photoAttached ? l10n.reportPhotoAttached : l10n.reportAttachPhoto),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _description.text.trim().isEmpty ? null : () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      disabledBackgroundColor: const Color(0xFFB8C7B9),
                      foregroundColor: Colors.white,
                      shape: _shape,
                      textStyle: const TextStyle(fontFamily: MuyuFonts.urbanist, fontWeight: FontWeight.w700),
                    ),
                    child: Text(l10n.reportSend),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
