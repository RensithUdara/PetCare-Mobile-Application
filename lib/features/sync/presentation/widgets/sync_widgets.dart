import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/pending_write_tracker.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/sync_providers.dart';

/// Thin banner above the tab content: offline, syncing, or failed writes.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider);
    final sync = ref.watch(syncStateProvider).value ?? SyncState.idle;
    final colors = StatusColors.of(context);

    final (IconData icon, String text, Color color, VoidCallback? onTap)? banner;
    if (sync.failed.isNotEmpty) {
      final n = sync.failed.length;
      banner = (
        Icons.sync_problem,
        '$n change${n == 1 ? '' : 's'} couldn’t be saved · Tap to review',
        colors.danger,
        () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _FailedWritesSheet(),
            ),
      );
    } else if (offline) {
      banner = (
        Icons.cloud_off,
        sync.pending > 0
            ? 'Offline · ${sync.pending} change${sync.pending == 1 ? '' : 's'} will sync when you’re back online'
            : 'You’re offline · Saved data is still available',
        colors.warning,
        null,
      );
    } else if (sync.pending > 0) {
      banner = (Icons.cloud_upload_outlined, 'Syncing ${sync.pending} change${sync.pending == 1 ? '' : 's'}…', colors.info, null);
    } else {
      banner = null;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: banner == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: banner.$3.withValues(alpha: 0.15),
              child: InkWell(
                onTap: banner.$4,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(banner.$1, size: 18, color: banner.$3),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            banner.$2,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: banner.$3,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _FailedWritesSheet extends ConsumerWidget {
  const _FailedWritesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(syncStateProvider).value?.failed ?? const [];
    final tracker = ref.read(pendingWriteTrackerProvider);
    final theme = Theme.of(context);
    if (failed.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
    }
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Changes that couldn’t be saved', style: theme.textTheme.titleMedium),
          ),
          for (final f in failed)
            ListTile(
              leading: Icon(Icons.error_outline, color: theme.colorScheme.error),
              title: Text(f.label),
              subtitle: Text(f.message),
              trailing: Wrap(
                spacing: 4,
                children: [
                  TextButton(onPressed: () => tracker.dismiss(f), child: const Text('Dismiss')),
                  FilledButton.tonal(onPressed: () => tracker.retry(f), child: const Text('Retry')),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Small "Pending sync" marker for a record with unsynced local changes.
class PendingSyncBadge extends ConsumerWidget {
  const PendingSyncBadge({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isPendingSyncProvider(id))) return const SizedBox.shrink();
    final color = StatusColors.of(context).warning;
    return Tooltip(
      message: 'Saved on this device · will sync when online',
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 14, color: color),
            const SizedBox(width: 3),
            Text('Pending sync',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
