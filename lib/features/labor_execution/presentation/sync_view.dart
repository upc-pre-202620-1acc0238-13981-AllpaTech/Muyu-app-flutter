import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/designsystem/components/green_title_header.dart';
import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../../plot_approval/presentation/myplots/farmer_plot_display.dart';
import '../application/evidence_queue.dart';

const _lightGreen = Color(0xFFDCF0DD);
const _darkGreenText = Color(0xFF2E6930);
const _grayChip = Color(0xFFE0E0E0);
const _grayChipText = Color(0xFF616161);
const _uploadingChip = Color(0xFFE8EAF6);
const _uploadingChipText = Color(0xFF283593);

TextStyle _text(double size, FontWeight weight, Color color) =>
    TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: size, fontWeight: weight, color: color);

/// The farmer's Sync tab, as Kotlin `SyncScreen`: evidence recorded without
/// signal, a button to send it and the history of what was already sent.
class SyncView extends ConsumerStatefulWidget {
  const SyncView({super.key, this.bottomInset = 0, this.onBack});

  final double bottomInset;

  /// Back arrow of the header; without it the view has no header.
  final VoidCallback? onBack;

  @override
  ConsumerState<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends ConsumerState<SyncView> {
  bool _historyExpanded = false;

  bool get _es => Localizations.localeOf(context).languageCode == 'es';

  @override
  void initState() {
    super.initState();
    // Like Kotlin, try to send what is waiting as soon as the tab opens.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync(quiet: true));
  }

  Future<void> _sync({bool quiet = false}) async {
    final controller = ref.read(evidenceQueueProvider.notifier);
    if (ref.read(evidenceQueueProvider).queue.isEmpty) return;
    final sent = await controller.syncAll();
    if (!mounted || (quiet && sent == 0)) return;
    final offline = ref.read(evidenceQueueProvider).offline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent > 0
              ? (_es ? '$sent evidencia(s) enviada(s).' : '$sent evidence item(s) sent.')
              : offline
              ? (_es ? 'Todavía no hay señal.' : 'Still no signal.')
              : (_es
                    ? 'No se pudo enviar. Inténtalo más tarde.'
                    : 'It could not be sent. Try later.'),
        ),
      ),
    );
  }

  /// Kotlin `formatSyncItemDate`: short date and time.
  String _when(int millis) {
    if (millis <= 0) return '—';
    final locale = Localizations.localeOf(context).toString();
    return DateFormat(
      'd MMM yyyy, HH:mm',
      locale,
    ).format(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  @override
  Widget build(BuildContext context) {
    final es = _es;
    final state = ref.watch(evidenceQueueProvider);
    final queue = state.queue;
    final online = !state.offline;
    final contextLine = queue.isEmpty
        ? (es ? 'Todas tus parcelas financiadas' : 'All your funded plots')
        : '${queue.first.plotName} - ${queue.first.crop} · ${DateTime.now().year}';
    final canSync = online && queue.isNotEmpty && !state.syncing;
    // Without a connectivity check, a failed attempt must still be retryable.
    final canTap = queue.isNotEmpty && !state.syncing;

    final body = RefreshIndicator(
      onRefresh: _sync,
      color: MuyuColors.action,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 16, 20, widget.bottomInset + 20),
        children: [
          Text(contextLine, style: _text(14, FontWeight.w500, Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  es ? '${queue.length} evidencias pendientes' : '${queue.length} pending proofs',
                  style: _text(20, FontWeight.w700, _darkGreenText),
                ),
                const SizedBox(height: 6),
                Text(
                  es
                      ? 'Las fotos se guardan en tu teléfono y se envían automáticamente cuando vuelve la señal. Sigue trabajando sin buscar cobertura.'
                      : 'Photos are saved on your phone and sent automatically when your signal returns. Keep working without searching for coverage.',
                  style: _text(
                    13,
                    FontWeight.w400,
                    _darkGreenText.withValues(alpha: 0.8),
                  ).copyWith(height: 18 / 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (queue.isEmpty)
            Text(
              online
                  ? (es
                        ? 'No hay evidencias pendientes de sincronizar.'
                        : 'No evidence waiting to sync.')
                  : (es ? 'Sin conexión · inténtalo más tarde' : 'Offline · try again later'),
              style: _text(15, FontWeight.w400, Colors.black.withValues(alpha: 0.55)),
            )
          else
            for (final (index, item) in queue.indexed) ...[
              _SyncItemCard(
                item: item,
                es: es,
                when: _when(
                  (item.milestone['submittedAtMillis'] as num?)?.toInt() ?? item.queuedAtMillis,
                ),
                waitingForSignal: !online,
                uploading: state.syncing && index == 0,
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 8),
          Material(
            color: canSync ? MuyuColors.action : _lightGreen.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: canSync
                  ? BorderSide.none
                  : BorderSide(color: _darkGreenText.withValues(alpha: 0.6)),
            ),
            child: InkWell(
              onTap: canTap ? _sync : null,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    !online
                        ? (es ? 'Sin conexión · inténtalo más tarde' : 'Offline · try again later')
                        : queue.isEmpty
                        ? (es ? 'Todo está sincronizado' : 'Everything is synced')
                        : state.syncing
                        ? (es ? 'Subiendo...' : 'Uploading...')
                        : (es ? 'Sincronizar ahora' : 'Sync now'),
                    style: _text(16, FontWeight.w700, canSync ? Colors.white : _darkGreenText),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
            ),
            child: InkWell(
              onTap: () => setState(() => _historyExpanded = !_historyExpanded),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                es ? 'HISTORIAL' : 'HISTORY',
                                style: _text(12, FontWeight.w700, Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                es
                                    ? '${state.history.length} evidencias sincronizadas'
                                    : '${state.history.length} proofs synced',
                                style: _text(15, FontWeight.w600, Colors.black),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _historyExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            semanticLabel: es ? 'Ampliar historial' : 'Expand history',
                          ),
                        ),
                      ],
                    ),
                    if (_historyExpanded) ...[
                      const SizedBox(height: 12),
                      if (state.history.isEmpty)
                        Text(
                          es
                              ? 'Aún no hay sincronizaciones sin señal. Las evidencias guardadas offline aparecerán aquí cuando se envíen.'
                              : 'No offline sync yet. Proofs saved without signal will appear here after they upload.',
                          style: _text(14, FontWeight.w400, Colors.black.withValues(alpha: 0.55)),
                        )
                      else
                        for (final entry in state.history) ...[
                          _SyncHistoryRow(
                            entry: entry,
                            es: es,
                            queuedAt: _when(entry.queuedAtMillis),
                            syncedAt: _when(entry.syncedAtMillis),
                          ),
                          const SizedBox(height: 10),
                        ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final onBack = widget.onBack;
    if (onBack == null) return body;
    return Column(
      children: [
        GreenTitleHeader(
          title: es ? 'Sincronización' : 'Synchronization',
          onBack: onBack,
          trailing: _ConnectionChip(online: online, es: es),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  const _ConnectionChip({required this.online, required this.es});

  final bool online;
  final bool es;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: online ? _lightGreen : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      online ? (es ? 'Conectado' : 'Connected') : (es ? 'Sin conexión' : 'Offline'),
      style: _text(13, FontWeight.w700, online ? _darkGreenText : const Color(0xFF424242)),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.background, required this.color});

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: _text(12, FontWeight.w600, color)),
  );
}

/// Kotlin `SyncItemCard`: photo, sending state, GPS and capture time.
class _SyncItemCard extends StatelessWidget {
  const _SyncItemCard({
    required this.item,
    required this.es,
    required this.when,
    required this.waitingForSignal,
    required this.uploading,
  });

  final QueuedEvidence item;
  final bool es;
  final String when;
  final bool waitingForSignal;
  final bool uploading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MuyuColors.forest.withValues(alpha: 0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${item.plotName} · ${MilestoneState.title(item.milestoneKey, es: es)}',
          style: _text(15, FontWeight.w700, Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: PlotPhoto(uri: item.milestone['photoUri'] as String?),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusChip(
                    text: uploading
                        ? (es ? 'Subiendo...' : 'Uploading...')
                        : waitingForSignal
                        ? (es ? 'Esperando señal' : 'Waiting for signal')
                        : (es ? 'Sincronizar ahora' : 'Sync now'),
                    background: uploading ? _uploadingChip : _grayChip,
                    color: uploading ? _uploadingChipText : _grayChipText,
                  ),
                  const SizedBox(height: 6),
                  _StatusChip(
                    text: item.hasLocation
                        ? (es ? 'Ubicación registrada' : 'Location recorded')
                        : (es ? 'GPS no registrado' : 'GPS not recorded'),
                    background: _lightGreen,
                    color: _darkGreenText,
                  ),
                  const SizedBox(height: 6),
                  _StatusChip(text: when, background: _lightGreen, color: _darkGreenText),
                ],
              ),
            ),
          ],
        ),
        if (uploading) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              minHeight: 6,
              color: _darkGreenText,
              backgroundColor: _lightGreen,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Kotlin `SyncHistoryRow`.
class _SyncHistoryRow extends StatelessWidget {
  const _SyncHistoryRow({
    required this.entry,
    required this.es,
    required this.queuedAt,
    required this.syncedAt,
  });

  final SyncHistoryEntry entry;
  final bool es;
  final String queuedAt;
  final String syncedAt;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _lightGreen.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${entry.plotName} · ${MilestoneState.title(entry.milestoneKey, es: es)}',
          style: _text(14, FontWeight.w700, Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          es
              ? 'Guardada en el teléfono · enviada al recuperar señal'
              : 'Saved on device · sent when signal returned',
          style: _text(12, FontWeight.w400, _darkGreenText),
        ),
        const SizedBox(height: 2),
        Text(
          es
              ? 'En cola: $queuedAt · Sincronizada: $syncedAt'
              : 'Queued: $queuedAt · Synced: $syncedAt',
          style: _text(12, FontWeight.w400, Colors.black.withValues(alpha: 0.65)),
        ),
      ],
    ),
  );
}
