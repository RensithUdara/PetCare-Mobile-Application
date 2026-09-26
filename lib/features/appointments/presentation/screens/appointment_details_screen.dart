import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_overview.dart';
import '../../domain/logic/appointment_status.dart';
import '../controllers/appointment_editor_controller.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_status_badge.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appointmentProvider(appointmentId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: const BrandAppBar.page(title: 'Appointment'),
            body: const ErrorView(message: 'Could not load this appointment.'),
          ),
          data: (a) => a == null
              ? Scaffold(
                  appBar: const BrandAppBar.page(title: 'Appointment'),
                  body: const EmptyState(
                    icon: Icons.search_off,
                    title: 'Appointment not found',
                    message: 'It may have been deleted.',
                  ),
                )
              : _Details(appointment: a),
        );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.appointment});

  final Appointment appointment;

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    final result = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: action,
      cancelLabel: 'Back',
      icon: destructive ? Icons.event_busy_rounded : Icons.help_outline_rounded,
      accent: FeatureAccent.appointments,
      destructive: destructive,
    );
    return result;
  }

  void _showError(BuildContext context, WidgetRef ref, String fallback) {
    final error = ref.read(appointmentEditorControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error is Failure ? error.message : fallback)),
    );
  }

  Future<void> _setStatus(BuildContext context, WidgetRef ref, AppointmentStatus status) async {
    if (status == AppointmentStatus.cancelled &&
        !await _confirm(
          context,
          title: 'Cancel appointment?',
          message: 'The appointment stays in history as cancelled and its reminder is removed.',
          action: 'Cancel appointment',
          destructive: true,
        )) {
      return;
    }
    if (!context.mounted) return;
    final ok =
        await ref.read(appointmentEditorControllerProvider.notifier).setStatus(appointment, status);
    if (!context.mounted) return;
    if (!ok) _showError(context, ref, 'Could not update appointment.');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (!await _confirm(
      context,
      title: 'Delete appointment?',
      message: 'This removes the appointment permanently.',
      action: 'Delete',
      destructive: true,
    )) {
      return;
    }
    if (!context.mounted) return;
    final router = GoRouter.of(context);
    final navContext = Navigator.of(context, rootNavigator: true).context;
    if (await ref.read(appointmentEditorControllerProvider.notifier).delete(appointment.id)) {
      router.pop();
      if (navContext.mounted) await showSuccessDialog(navContext, title: 'Appointment deleted');
    } else if (context.mounted) {
      _showError(context, ref, 'Could not delete appointment.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final status = appointmentDisplayStatus(appointment, now);
    final petName = ref.watch(petProvider(appointment.petId)).value?.name;
    final busy = ref.watch(appointmentEditorControllerProvider).isLoading;
    final started = !appointment.dateTime.isAfter(now);

    final rows = <(IconData, String, String?)>[
      (Icons.pets, 'Pet', petName),
      (Icons.event, 'Date', DateFormat.yMMMMEEEEd().format(appointment.dateTime)),
      (Icons.schedule, 'Time', DateFormat.jm().format(appointment.dateTime)),
      (Icons.local_hospital_outlined, 'Clinic', appointment.clinic),
      (Icons.person_outline, 'Veterinarian', appointment.veterinarian),
      (Icons.info_outline, 'Reason', appointment.reason),
      (
        Icons.notifications_outlined,
        'Reminder',
        appointment.reminderDate == null
            ? 'Off'
            : DateFormat.MMMd().add_jm().format(appointment.reminderDate!),
      ),
    ];

    return Scaffold(
      appBar: BrandAppBar.page(
        title: 'Appointment',
        actions: [
          if (appointment.isScheduled)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: busy ? null : () => context.push(AppRoutes.appointmentEdit(appointment.id)),
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
              CircleAvatar(
                backgroundColor: status.color(context).withValues(alpha: 0.14),
                child: Icon(appointment.type.icon, color: status.color(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appointment.type.label,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              AppointmentStatusBadge(status: status),
            ],
          ),
          if (status == AppointmentDisplayStatus.past) ...[
            const SizedBox(height: 16),
            Card(
              color: status.color(context).withValues(alpha: 0.08),
              child: const ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Did this visit happen?'),
                subtitle: Text('Mark it completed or cancelled to keep history accurate.'),
              ),
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
          if (appointment.notes != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(appointment.notes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (appointment.isScheduled) ...[
            if (started)
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => _setStatus(context, ref, AppointmentStatus.completed),
                icon: const Icon(Icons.check),
                label: const Text('Mark as Completed'),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _setStatus(context, ref, AppointmentStatus.cancelled),
              icon: const Icon(Icons.event_busy_outlined),
              label: const Text('Cancel Appointment'),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: busy ? null : () => _setStatus(context, ref, AppointmentStatus.scheduled),
              icon: const Icon(Icons.undo),
              label: const Text('Reopen'),
            ),
        ],
      ),
    );
  }
}
