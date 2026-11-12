import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/user_preferences.dart';
import '../../escrow_custody/application/payment_history_controller.dart';
import '../../plot_approval/application/farmer_plots_controller.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/farmer_plot_repository.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';

/// Evidence recorded without signal, kept on the phone until it can be sent,
/// as Kotlin keeps milestones with status `queued`.
class QueuedEvidence {
  const QueuedEvidence({
    required this.plotId,
    required this.plotName,
    required this.crop,
    required this.milestone,
    required this.queuedAtMillis,
  });

  final int plotId;
  final String plotName;
  final String crop;

  /// The milestone exactly as it will be sent, already marked `submitted`.
  final Map<String, dynamic> milestone;
  final int queuedAtMillis;

  String get milestoneKey => milestone['key'] as String? ?? '';
  bool get hasLocation => milestone['latitude'] != null && milestone['longitude'] != null;

  factory QueuedEvidence.fromJson(Map<String, dynamic> json) => QueuedEvidence(
    plotId: (json['plotId'] as num?)?.toInt() ?? 0,
    plotName: json['plotName'] as String? ?? '',
    crop: json['crop'] as String? ?? '',
    milestone: Map<String, dynamic>.from(json['milestone'] as Map? ?? const {}),
    queuedAtMillis: (json['queuedAtMillis'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'plotId': plotId,
    'plotName': plotName,
    'crop': crop,
    'milestone': milestone,
    'queuedAtMillis': queuedAtMillis,
  };
}

/// One queued evidence that reached the server, as Kotlin `SyncHistoryRecord`.
class SyncHistoryEntry {
  const SyncHistoryEntry({
    required this.plotName,
    required this.milestoneKey,
    required this.queuedAtMillis,
    required this.syncedAtMillis,
  });

  final String plotName;
  final String milestoneKey;
  final int queuedAtMillis;
  final int syncedAtMillis;

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) => SyncHistoryEntry(
    plotName: json['plotName'] as String? ?? '',
    milestoneKey: json['milestoneKey'] as String? ?? '',
    queuedAtMillis: (json['queuedAtMillis'] as num?)?.toInt() ?? 0,
    syncedAtMillis: (json['syncedAtMillis'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'plotName': plotName,
    'milestoneKey': milestoneKey,
    'queuedAtMillis': queuedAtMillis,
    'syncedAtMillis': syncedAtMillis,
  };
}

class EvidenceQueueState {
  const EvidenceQueueState({
    this.queue = const [],
    this.history = const [],
    this.syncing = false,
    this.offline = false,
  });

  final List<QueuedEvidence> queue;
  final List<SyncHistoryEntry> history;
  final bool syncing;

  /// The last attempt could not reach the server.
  final bool offline;

  EvidenceQueueState copyWith({
    List<QueuedEvidence>? queue,
    List<SyncHistoryEntry>? history,
    bool? syncing,
    bool? offline,
  }) => EvidenceQueueState(
    queue: queue ?? this.queue,
    history: history ?? this.history,
    syncing: syncing ?? this.syncing,
    offline: offline ?? this.offline,
  );
}

/// The farmer's evidence waiting for signal and the ones already synced,
/// stored per user on the phone.
class EvidenceQueueController extends Notifier<EvidenceQueueState> {
  static const _queueKey = 'evidence_queue';
  static const _historyKey = 'evidence_sync_history';
  static const _historyLimit = 50;

  String? get _email => ref.read(sessionProvider).user?.email;

  @override
  EvidenceQueueState build() {
    final email = ref.watch(sessionProvider.select((session) => session.user?.email));
    if (email == null) return const EvidenceQueueState();
    final prefs = ref.read(userPreferencesProvider);
    return EvidenceQueueState(
      queue: _decode(prefs.loadString(email, _queueKey)).map(QueuedEvidence.fromJson).toList(),
      history: _decode(prefs.loadString(email, _historyKey))
          .map(SyncHistoryEntry.fromJson)
          .toList(),
    );
  }

  /// Keeps [milestone] of [plot] on the phone, replacing an earlier copy of it.
  Future<void> enqueue(FarmerPlot plot, MilestoneState milestone) async {
    final item = QueuedEvidence(
      plotId: plot.id,
      plotName: plot.name,
      crop: plot.crop,
      milestone: milestone.toJson(),
      queuedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    final queue = [
      for (final existing in state.queue)
        if (existing.plotId != plot.id || existing.milestoneKey != milestone.key) existing,
      item,
    ];
    state = state.copyWith(queue: queue, offline: true);
    await _persist();
  }

  /// [plot] with the evidence still waiting on the phone shown as `queued`,
  /// so the farmer does not record the same milestone twice.
  FarmerPlot withQueued(FarmerPlot plot) {
    var shown = plot;
    for (final item in state.queue.where((item) => item.plotId == plot.id)) {
      final current = shown.milestone(item.milestoneKey);
      if (current == null || current.isSubmitted || current.isApproved) continue;
      shown = shown.withMilestone(current.copyWith(status: MilestoneState.statusQueued));
    }
    return shown;
  }

  /// Sends every queued evidence. Returns how many reached the server.
  Future<int> syncAll() async {
    final user = ref.read(sessionProvider).user;
    if (user == null || state.queue.isEmpty || state.syncing) return 0;
    state = state.copyWith(syncing: true);
    var sent = 0;
    try {
      final repository = ref.read(farmerPlotRepositoryProvider);
      final plots = await repository.getAll(user.token);
      final remaining = <QueuedEvidence>[];
      final history = [...state.history];
      for (final item in state.queue) {
        final plot = plots.where((candidate) => candidate.id == item.plotId).firstOrNull;
        if (plot == null) {
          remaining.add(item);
          continue;
        }
        try {
          await repository.save(
            user.token,
            plot.withMilestone(MilestoneState.fromJson(item.milestone)),
          );
          sent++;
          history.insert(
            0,
            SyncHistoryEntry(
              plotName: item.plotName,
              milestoneKey: item.milestoneKey,
              queuedAtMillis: item.queuedAtMillis,
              syncedAtMillis: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        } on PlotException catch (error) {
          remaining.add(item);
          if (error.failure == PlotFailure.network) {
            remaining.addAll(state.queue.skipWhile((queued) => queued != item).skip(1));
            break;
          }
        }
      }
      state = state.copyWith(
        queue: remaining,
        history: history.take(_historyLimit).toList(),
        offline: false,
      );
    } on PlotException catch (error) {
      state = state.copyWith(offline: error.failure == PlotFailure.network);
      if (error.failure == PlotFailure.sessionExpired) {
        await ref.read(sessionProvider.notifier).logout();
      }
    } finally {
      state = state.copyWith(syncing: false);
      await _persist();
    }
    if (sent > 0) {
      ref.invalidate(farmerPlotsProvider);
      ref.invalidate(paymentHistoryProvider);
    }
    return sent;
  }

  Future<void> _persist() async {
    final email = _email;
    if (email == null) return;
    final prefs = ref.read(userPreferencesProvider);
    await prefs.saveString(
      email,
      _queueKey,
      jsonEncode([for (final item in state.queue) item.toJson()]),
    );
    await prefs.saveString(
      email,
      _historyKey,
      jsonEncode([for (final item in state.history) item.toJson()]),
    );
  }

  static List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } on FormatException {
      return const [];
    }
  }
}

final evidenceQueueProvider = NotifierProvider<EvidenceQueueController, EvidenceQueueState>(
  EvidenceQueueController.new,
);
