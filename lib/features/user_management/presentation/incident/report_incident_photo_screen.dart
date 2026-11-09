import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'incident_style.dart';

/// Optional photo step from Kotlin `ReportIncidentPhotoScreen`.
class ReportIncidentPhotoScreen extends StatefulWidget {
  const ReportIncidentPhotoScreen({super.key, this.initialPath});

  final String? initialPath;

  @override
  State<ReportIncidentPhotoScreen> createState() => _ReportIncidentPhotoScreenState();
}

class _ReportIncidentPhotoScreenState extends State<ReportIncidentPhotoScreen> {
  late String? _path = widget.initialPath;

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _path = picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = _path;
    final hasPhoto = path != null && path.isNotEmpty;
    final radius = BorderRadius.circular(IncidentStyle.photoRadius);

    return Theme(
      data: IncidentStyle.theme(context),
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        body: Column(
          children: [
            GreenTitleHeader(
              title: l10n.reportAttachPhoto,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pick,
                      child: SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
                            ),
                            if (hasPhoto)
                              Padding(
                                padding: const EdgeInsets.all(1),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    IncidentStyle.photoRadius - 1,
                                  ),
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    semanticLabel: l10n.reportPhotoAttached,
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: Text(
                                  l10n.reportAttachPhoto,
                                  textAlign: TextAlign.center,
                                  style: IncidentStyle.button.copyWith(color: IncidentStyle.green),
                                ),
                              ),
                            IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: radius,
                                  border: Border.all(color: IncidentStyle.fieldBorder),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    IncidentButton(
                      label: l10n.reportSendRequest,
                      filled: true,
                      enabled: hasPhoto,
                      bordered: false,
                      radius: IncidentStyle.photoRadius,
                      onPressed: () => Navigator.of(context).pop(path),
                    ),
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
