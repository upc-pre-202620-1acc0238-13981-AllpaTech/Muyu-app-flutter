import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../escrow_custody/application/payment_history_controller.dart';
import '../../plot_approval/application/farmer_plots_controller.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/farmer_plot_repository.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../plot_financing/application/merchant_financing_controller.dart';
import '../../user_management/application/session_controller.dart';

/// Where the farmer was when the evidence was taken.
class EvidenceLocation {
  const EvidenceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final int accuracyMeters;
}

enum LocationFailure { disabled, denied, unavailable }

class EvidenceLocationException implements Exception {
  const EvidenceLocationException(this.failure);
  final LocationFailure failure;
}

/// Reads the device position. Tests replace it with a fixed location.
final evidenceLocatorProvider = Provider<Future<EvidenceLocation> Function()>(
  (ref) => _deviceLocation,
);

Future<EvidenceLocation> _deviceLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const EvidenceLocationException(LocationFailure.disabled);
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw const EvidenceLocationException(LocationFailure.denied);
  }
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 25),
      ),
    );
    return EvidenceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy.round(),
    );
  } on Exception {
    throw const EvidenceLocationException(LocationFailure.unavailable);
  }
}

/// Takes or picks a photo and returns it as a `data:` URL, the portable form
/// Kotlin stores so the merchant can see it from another device.
final evidencePhotoPickerProvider = Provider<Future<String?> Function(ImageSource source)>(
  (ref) => _pickPhoto,
);

Future<String?> _pickPhoto(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 70,
  );
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}

/// Records farmer evidence and merchant reviews on a plot's milestones,
/// writing the same fields Kotlin `BackendStateStore` writes.
class MilestoneEvidenceService {
  MilestoneEvidenceService(this._ref);
  final Ref _ref;

  Future<FarmerPlot> submitEvidence({
    required FarmerPlot plot,
    required String milestoneKey,
    required String photoUri,
    required String inputUsed,
    required String amountApplied,
    required String notes,
    required EvidenceLocation location,
  }) async {
    final current =
        plot.milestone(milestoneKey) ?? MilestoneState(key: milestoneKey, status: 'pending');
    final now = DateTime.now();
    final updated = current.copyWith(
      status: MilestoneState.statusSubmitted,
      notes: notes.trim(),
      extra: {
        'photoUri': photoUri,
        'inputUsed': inputUsed,
        'amountApplied': amountApplied.trim(),
        'recordedAt': DateFormat('d MMM yyyy', 'en_US').format(now),
        'submittedAtMillis': now.millisecondsSinceEpoch,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracyMeters': location.accuracyMeters,
        'reviewComment': '',
      },
    );
    final next = plot.withMilestone(updated);
    await _ref.read(farmerPlotsProvider.notifier).updatePlot(next);
    _ref.invalidate(paymentHistoryProvider);
    return next;
  }

  Future<FarmerPlot> review({
    required FarmerPlot plot,
    required String milestoneKey,
    required bool approved,
    String reason = '',
  }) async {
    final user = _ref.read(sessionProvider).user;
    if (user == null) throw const PlotException(PlotFailure.sessionExpired);
    final current = plot.milestone(milestoneKey);
    if (current == null || !current.isSubmitted) throw const PlotException(PlotFailure.rejected);

    final updated = current.copyWith(
      status: approved ? MilestoneState.statusApproved : MilestoneState.statusNeedsCorrection,
      extra: {
        'reviewedAtMillis': DateTime.now().millisecondsSinceEpoch,
        'reviewComment': approved ? '' : reason.trim(),
      },
    );
    final next = plot.withMilestone(updated);
    try {
      await _ref.read(farmerPlotRepositoryProvider).save(user.token, next);
    } on PlotException catch (error) {
      if (error.failure == PlotFailure.sessionExpired) {
        await _ref.read(sessionProvider.notifier).logout();
      }
      rethrow;
    }
    _ref.invalidate(paymentHistoryProvider);
    await _ref.read(merchantFinancingProvider.notifier).refresh();
    return next;
  }
}

final milestoneEvidenceServiceProvider = Provider<MilestoneEvidenceService>(
  MilestoneEvidenceService.new,
);
