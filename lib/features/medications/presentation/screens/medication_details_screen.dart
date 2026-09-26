import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/medication.dart';
import '../../domain/logic/medication_schedule.dart';
import '../controllers/medication_editor_controller.dart';
import '../providers/medication_providers.dart';
import '../widgets/medication_widgets.dart';

class MedicationDetailsScreen extends ConsumerWidget {
  const MedicationDetailsScreen({super.key, required this.medicationId});

  final String medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(medicationProvider(medicationId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Could not load this medication.'),
          ),
          data: (m) => m == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.search_off,
                    title: 'Medication not found',
                    message: 'It may have been deleted.',
                  ),
                )
              : _Details(medication: m),
        );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.medication});

  final Medication medication;

  Future<bool> _confirm(BuildContext context, String title, String message, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showError(BuildContext context, WidgetRef ref, String fallback) {
    final error = ref.read(medicationEditorControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error is Failure ? error.message : fallback)),
    );
  }

  Future<void> _stop(BuildContext context, WidgetRef ref) async {
    if (!await _confirm(
      context,
      'Stop ${medication.name}?',
      'The course ends today and no further reminders are sent.',
      'Stop',
    )) {
      return;
    }
    if (!context.mounted) return;
    final ok = await ref.read(medicationEditorControllerProvider.notifier).stop(medication);
    if (!ok && context.mounted) _showError(context, ref, 'Could not stop medication.');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (!await _confirm(
      context,
      'Delete medication?',
      'This removes ${medication.name} and its schedule permanently.',
      'Delete',
    )) {
      return;
    }
    if (!context.mounted) return;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await ref.read(medicationEditorControllerProvider.notifier).delete(medication.id)) {
      router.pop();
      messenger.showSnackBar(SnackBar(content: Text('${medication.name} deleted')));
    } else if (context.mounted) {
      _showError(context, ref, 'Could not delete medication.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final status = medicationStatus(medication, now);
    final next = nextDose(medication, now);
    final progress = courseProgress(medication, now);
    final petName = ref.watch(petProvider(medication.petId)).value?.name;
    final busy = ref.watch(medicationEditorControllerProvider).isLoading;
    final date = DateFormat.yMMMd();

    final rows = <(IconData, String, String?)>[
      (Icons.pets, 'Pet', petName),
      (Icons.scale_outlined, 'Dosage', medication.dosage),
      (Icons.repeat, 'Schedule', scheduleLabel(context, medication)),
      (Icons.event_available_outlined, 'Start', date.format(medication.startDate)),
      (
        Icons.event_busy_outlined,
        'End',
        medication.endDate == null ? 'Ongoing' : date.format(medication.endDate!),
      ),
      if (medication.frequency.isScheduled)
        (Icons.notifications_outlined, 'Reminders', medication.remindersEnabled ? 'On' : 'Off'),
      (Icons.person_outline, 'Prescribed by', medication.veterinarian),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: busy ? null : () => context.push(AppRoutes.medicationEdit(medication.id)),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: busy ? null : () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (busy) const LinearProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: Text(
                  medication.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(label: status.label, tone: status.tone),
            ],
          ),
          if (next != null && status == MedicationStatus.active) ...[
            const SizedBox(height: 4),
            Text(
              'Next dose: ${nextDoseLabel(next, now)}',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          if (progress != null && status == MedicationStatus.active) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress.fraction, minHeight: 8),
            ),
            const SizedBox(height: 6),
            Text(
              'Day ${progress.day} of ${progress.totalDays} · '
              '${progress.daysLeft} day${progress.daysLeft == 1 ? '' : 's'} left',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final (icon, label, value) in rows)
                  if (value != null && value.isNotEmpty)
                    ListTile(
                      leading: Icon(icon),
                      title: Text(label, style: theme.textTheme.bodySmall),
                      subtitle: Text(value, style: theme.textTheme.bodyLarge),
                    ),
              ],
            ),
          ),
          for (final (title, text) in [
            ('Instructions', medication.instructions),
            ('Notes', medication.notes),
          ])
            if (text != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(text),
                    ],
                  ),
                ),
              ),
            ],
          if (status == MedicationStatus.active) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _stop(context, ref),
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop Medication'),
            ),
          ],
        ],
      ),
    );
  }
}
