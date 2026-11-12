import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/designsystem/components/green_title_header.dart';
import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/farmer_plot_repository.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../application/milestone_evidence_service.dart';
import 'milestone_widgets.dart';

/// Farmer evidence for one milestone: photo, input, amount, notes and GPS,
/// as Kotlin `RecordEvidenceScreen`. Pops with the updated plot when sent.
class RecordEvidenceScreen extends ConsumerStatefulWidget {
  const RecordEvidenceScreen({super.key, required this.plot, required this.milestoneKey});

  final FarmerPlot plot;
  final String milestoneKey;

  @override
  ConsumerState<RecordEvidenceScreen> createState() => _RecordEvidenceScreenState();
}

class _RecordEvidenceScreenState extends ConsumerState<RecordEvidenceScreen> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String _photo = '';
  String? _input;
  EvidenceLocation? _location;
  LocationFailure? _locationFailure;
  bool _locating = false;
  bool _sending = false;
  String? _error;

  bool get _es => Localizations.localeOf(context).languageCode == 'es';

  MilestoneState? get _milestone => widget.plot.milestone(widget.milestoneKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationFailure = null;
    });
    try {
      final location = await ref.read(evidenceLocatorProvider)();
      if (mounted) setState(() => _location = location);
    } on EvidenceLocationException catch (error) {
      if (mounted) setState(() => _locationFailure = error.failure);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    final photo = await ref.read(evidencePhotoPickerProvider)(source);
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  bool get _ready =>
      _photo.isNotEmpty &&
      _input != null &&
      _amount.text.trim().isNotEmpty &&
      _location != null &&
      !_sending;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(milestoneEvidenceServiceProvider)
          .submitEvidence(
            plot: widget.plot,
            milestoneKey: widget.milestoneKey,
            photoUri: _photo,
            inputUsed: _input!,
            amountApplied: _amount.text,
            notes: _notes.text,
            location: _location!,
          );
      if (mounted) Navigator.of(context).pop(updated);
    } on PlotException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = switch (error.failure) {
          PlotFailure.network =>
            _es
                ? 'Sin conexión. Tu evidencia no se envió; inténtalo cuando tengas señal.'
                : 'No connection. Your evidence was not sent; try again when you have signal.',
          PlotFailure.sessionExpired =>
            _es
                ? 'Tu sesión expiró. Vuelve a iniciar sesión.'
                : 'Your session expired. Sign in again.',
          PlotFailure.rejected =>
            _es ? 'El servidor rechazó la evidencia.' : 'The server rejected the evidence.',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = _es;
    final key = widget.milestoneKey;
    final milestone = _milestone;
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: es ? 'Registrar evidencia' : 'Record evidence',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${widget.plot.name} · ${MilestoneState.title(key, es: es)}',
                  style: MuyuTextStyles.bodyBold,
                ),
                const SizedBox(height: 4),
                Text(
                  MilestoneState.hint(key, es: es),
                  style: const TextStyle(color: MuyuColors.mutedFooter),
                ),
                if (milestone != null &&
                    milestone.needsCorrection &&
                    milestone.reviewComment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Banner(
                    color: MuyuColors.dangerBackground,
                    textColor: MuyuColors.dangerMessage,
                    text:
                        '${es ? 'El comerciante pidió corregir' : 'The merchant asked for a correction'}: '
                        '${milestone.reviewComment}',
                  ),
                ],
                const SizedBox(height: 16),
                if (_photo.isNotEmpty) ...[EvidencePhoto(uri: _photo), const SizedBox(height: 10)],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _photo.isEmpty
                              ? (es ? 'Tomar foto' : 'Take photo')
                              : (es ? 'Otra foto' : 'Retake'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending ? null : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(es ? 'Galería' : 'Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LocationCard(
                  locating: _locating,
                  location: _location,
                  failure: _locationFailure,
                  onRetry: _sending ? null : _locate,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _input,
                  decoration: InputDecoration(
                    labelText: es ? 'Insumo utilizado' : 'Input used',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    for (final option in MilestoneState.inputOptions(key, es: es))
                      DropdownMenuItem(value: option, child: Text(option)),
                  ],
                  onChanged: _sending ? null : (value) => setState(() => _input = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amount,
                  enabled: !_sending,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: es ? 'Cantidad aplicada' : 'Amount applied',
                    hintText: es ? 'Ej. 50 kg' : 'e.g. 50 kg',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  enabled: !_sending,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: es ? 'Notas (opcional)' : 'Notes (optional)',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: MuyuColors.errorBorder)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _ready ? _send : null,
                  child: _sending
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(es ? 'Enviar evidencia' : 'Send evidence'),
                ),
                const SizedBox(height: 8),
                Text(
                  es
                      ? 'El comerciante revisará la foto, la ubicación y la fecha antes de liberar el pago.'
                      : 'The merchant reviews the photo, location and date before releasing the payment.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: MuyuColors.mutedFooter),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locating,
    required this.location,
    required this.failure,
    required this.onRetry,
  });

  final bool locating;
  final EvidenceLocation? location;
  final LocationFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    if (locating) {
      return _Banner(
        color: MuyuColors.financedBackground,
        textColor: MuyuColors.financedText,
        text: es ? 'Obteniendo tu ubicación GPS…' : 'Getting your GPS location…',
      );
    }
    final current = location;
    if (current != null) {
      return _Banner(
        color: MuyuColors.statCard,
        textColor: MuyuColors.forest,
        text:
            '${es ? 'Ubicación registrada' : 'Location recorded'}: '
            '${formatCoordinates(current.latitude, current.longitude)} (±${current.accuracyMeters} m)',
      );
    }
    final message = switch (failure) {
      LocationFailure.disabled =>
        es ? 'Activa la ubicación del teléfono.' : 'Turn on the phone location.',
      LocationFailure.denied =>
        es ? 'Muyu necesita permiso de ubicación.' : 'Muyu needs location permission.',
      _ => es ? 'No se pudo obtener la ubicación.' : 'The location could not be read.',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MuyuColors.offlineBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: MuyuColors.offlineText)),
          ),
          TextButton(onPressed: onRetry, child: Text(es ? 'Reintentar' : 'Retry')),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.textColor, required this.text});

  final Color color;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
    child: Text(text, style: TextStyle(color: textColor)),
  );
}
