import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/muyu_colors.dart';
import '../../../core/theme/muyu_theme.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../application/evidence_queue.dart';

/// The farmer's Sync tab, as Kotlin `SyncScreen`: evidence recorded without
/// signal, a button to send it and the history of what was already sent.
class SyncView extends ConsumerStatefulWidget {
  const SyncView({super.key, this.bottomInset = 0});
  final double bottomInset;

  @override
  ConsumerState<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends ConsumerState<SyncView> {
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
    final es = Localizations.localeOf(context).languageCode == 'es';
    final offline = ref.read(evidenceQueueProvider).offline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent > 0
              ? (es ? '$sent evidencia(s) enviada(s).' : '$sent evidence item(s) sent.')
              : offline
              ? (es ? 'Todavía no hay señal.' : 'Still no signal.')
              : (es
                    ? 'No se pudo enviar. Inténtalo más tarde.'
                    : 'It could not be sent. Try later.'),
        ),
      ),
    );
  }

  String _when(int millis, String locale) => millis <= 0
      ? '—'
      : DateFormat.yMMMd(locale).add_Hm().format(DateTime.fromMillisecondsSinceEpoch(millis));

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    final locale = Localizations.localeOf(context).toString();
    final state = ref.watch(evidenceQueueProvider);
    final pending = state.queue;
    return RefreshIndicator(
      onRefresh: _sync,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, widget.bottomInset + 20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: pending.isEmpty ? MuyuColors.statCard : MuyuColors.offlineBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pending.isEmpty
                      ? (es ? 'Todo está al día' : 'Everything is up to date')
                      : (es
                            ? '${pending.length} evidencia(s) sin enviar'
                            : '${pending.length} evidence item(s) not sent'),
                  style: MuyuTextStyles.bodyBold.copyWith(
                    color: pending.isEmpty ? MuyuColors.forest : MuyuColors.offlineText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pending.isEmpty
                      ? (es
                            ? 'Si registras una evidencia sin señal, quedará guardada aquí hasta que puedas enviarla.'
                            : 'Evidence recorded without signal stays here until you can send it.')
                      : (es
                            ? 'Se guardaron en tu teléfono porque no había señal. Envíalas cuando tengas conexión.'
                            : 'They were saved on your phone because there was no signal. Send them when you are online.'),
                  style: TextStyle(
                    color: pending.isEmpty ? MuyuColors.forest : MuyuColors.offlineText,
                  ),
                ),
              ],
            ),
          ),
          for (final item in pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MuyuColors.forest),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.plotName} · ${MilestoneState.title(item.milestoneKey, es: es)}',
                    style: MuyuTextStyles.bodySemiBold,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${es ? 'Guardada' : 'Saved'}: ${_when(item.queuedAtMillis, locale)}',
                    style: const TextStyle(color: MuyuColors.mutedFooter),
                  ),
                  Text(
                    item.hasLocation
                        ? (es ? 'Ubicación GPS registrada' : 'GPS location recorded')
                        : (es ? 'Sin ubicación GPS' : 'No GPS location'),
                    style: const TextStyle(color: MuyuColors.mutedFooter),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: pending.isEmpty || state.syncing ? null : _sync,
            icon: state.syncing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              state.syncing
                  ? (es ? 'Enviando…' : 'Sending…')
                  : pending.isEmpty
                  ? (es ? 'Todo enviado' : 'All sent')
                  : (es ? 'Sincronizar ahora' : 'Sync now'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            es
                ? 'Evidencias sincronizadas (${state.history.length})'
                : 'Synced evidence (${state.history.length})',
            style: MuyuTextStyles.bodyBold,
          ),
          const SizedBox(height: 8),
          if (state.history.isEmpty)
            Text(
              es
                  ? 'Aún no se sincronizó ninguna evidencia guardada sin señal.'
                  : 'No evidence saved without signal has been synced yet.',
              style: const TextStyle(color: MuyuColors.mutedFooter),
            )
          else
            for (final entry in state.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: MuyuColors.olive, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.plotName} · ${MilestoneState.title(entry.milestoneKey, es: es)} · '
                        '${_when(entry.syncedAtMillis, locale)}',
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
