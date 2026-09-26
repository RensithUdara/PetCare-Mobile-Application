import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/entities/vaccination_overview.dart';
import '../controllers/vaccination_editor_controller.dart';
import '../providers/vaccination_providers.dart';
import '../widgets/vaccination_formatters.dart';
import '../widgets/vaccination_status_badge.dart';

class VaccinationDetailsScreen extends ConsumerWidget {
  const VaccinationDetailsScreen({super.key, required this.vaccinationId});

  final String vaccinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(vaccinationProvider(vaccinationId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Could not load this vaccination.'),
          ),
          data: (v) => v == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.search_off,
                    title: 'Record not found',
                    message: 'This vaccination may have been deleted.',
                  ),
                )
              : _Details(vaccination: v),
        );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.vaccination});

  final Vaccination vaccination;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete vaccination?'),
        content: Text('This removes the ${vaccination.vaccineName} record permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final controller = ref.read(vaccinationEditorControllerProvider.notifier);
    if (await controller.delete(vaccination.id)) {
      router.pop();
      messenger.showSnackBar(SnackBar(content: Text('${vaccination.vaccineName} deleted')));
    } else {
      final error = ref.read(vaccinationEditorControllerProvider).error;
      messenger.showSnackBar(SnackBar(
        content: Text(error is Failure ? error.message : 'Could not delete vaccination.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final date = DateFormat.yMMMd();
    final busy = ref.watch(vaccinationEditorControllerProvider).isLoading;

    // Status depends on sibling doses (superseded ⇒ completed), so read it
    // from the pet's overview rather than recomputing it here.
    final status = ref
        .watch(petVaccinationOverviewProvider(vaccination.petId))
        .value
        ?.historyByYear
        .expand((y) => y.$2)
        .where((e) => e.vaccination.id == vaccination.id)
        .firstOrNull
        ?.status;

    final rows = <(IconData, String, String?)>[
      (Icons.category_outlined, 'Category', vaccination.category.label),
      (Icons.event_available_outlined, 'Administered', date.format(vaccination.dateAdministered)),
      (
        Icons.event_repeat_outlined,
        'Next due',
        vaccination.nextDueDate == null ? 'No booster needed' : date.format(vaccination.nextDueDate!),
      ),
      (
        Icons.notifications_outlined,
        'Reminder',
        vaccination.reminderDate == null
            ? 'Off'
            : '${vaccination.reminder!.label} (${date.format(vaccination.reminderDate!)})',
      ),
      (Icons.person_outline, 'Veterinarian', vaccination.veterinarian),
      (Icons.local_hospital_outlined, 'Clinic', vaccination.clinic),
      (Icons.qr_code_2, 'Batch number', vaccination.batchNumber),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: busy
                ? null
                : () => context.push(AppRoutes.vaccinationEdit(vaccination.id)),
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
                  vaccination.vaccineName,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (status != null) VaccinationStatusBadge(status: status),
            ],
          ),
          if (vaccination.nextDueDate != null && status != VaccinationStatus.completed) ...[
            const SizedBox(height: 4),
            Text(
              dueLabel(vaccination.nextDueDate!, now),
              style: theme.textTheme.titleSmall?.copyWith(color: status?.color(context)),
            ),
          ],
          if (status == VaccinationStatus.completed) ...[
            const SizedBox(height: 4),
            Text(
              'Superseded by a later dose',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 20),
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
          if (vaccination.notes != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(vaccination.notes!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
