import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/reminder_offset.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../pets/presentation/widgets/pet_selector.dart';
import '../../domain/entities/appointment.dart';
import '../controllers/appointment_editor_controller.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_status_badge.dart';

/// Create an appointment (optionally for [petId] on [initialDate]) or edit
/// [appointmentId].
class AppointmentFormScreen extends ConsumerWidget {
  const AppointmentFormScreen({super.key, this.petId, this.initialDate, this.appointmentId});

  final String? petId;
  final DateTime? initialDate;
  final String? appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointmentId == null) {
      return _AppointmentForm(initial: null, petId: petId, initialDate: initialDate);
    }
    return ref.watch(appointmentProvider(appointmentId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) =>
              const Scaffold(body: ErrorView(message: 'Could not load this appointment.')),
          data: (a) => a == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(icon: Icons.search_off, title: 'Appointment not found'),
                )
              : _AppointmentForm(initial: a, petId: a.petId),
        );
  }
}

class _AppointmentForm extends ConsumerStatefulWidget {
  const _AppointmentForm({required this.initial, this.petId, this.initialDate});

  final Appointment? initial;
  final String? petId;
  final DateTime? initialDate;

  @override
  ConsumerState<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<_AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final _clinic = TextEditingController(text: widget.initial?.clinic);
  late final _vet = TextEditingController(text: widget.initial?.veterinarian);
  late final _reason = TextEditingController(text: widget.initial?.reason);
  late final _notes = TextEditingController(text: widget.initial?.notes);

  late String? _petId = widget.petId;
  late AppointmentType _type = widget.initial?.type ?? AppointmentType.routineCheckup;
  late DateTime? _date = widget.initial?.dateTime ?? widget.initialDate;
  late TimeOfDay? _time =
      widget.initial == null ? null : TimeOfDay.fromDateTime(widget.initial!.dateTime);
  late ReminderOffset? _reminder =
      widget.initial == null ? ReminderOffset.oneDay : widget.initial!.reminder;

  bool get _isEditing => widget.initial != null;

  DateTime? get _dateTime => (_date == null || _time == null)
      ? null
      : DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

  @override
  void dispose() {
    for (final c in [_clinic, _vet, _reason, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial ??
        Appointment(ownerId: '', petId: _petId!, dateTime: _dateTime!);
    final appointment = base.copyWith(
      petId: _petId!,
      dateTime: _dateTime!,
      type: _type,
      clinic: _clinic.text,
      veterinarian: _vet.text,
      reason: _reason.text,
      notes: _notes.text,
      reminder: _reminder,
    );

    final id = await ref.read(appointmentEditorControllerProvider.notifier).save(appointment);
    if (id == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isEditing ? 'Appointment updated' : 'Appointment scheduled'),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appointmentEditorControllerProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error is Failure ? error.message : 'Something went wrong.'),
        ));
      }
    });
    final busy = ref.watch(appointmentEditorControllerProvider).isLoading;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final reminderAt = _dateTime == null || _reminder == null
        ? null
        : Appointment(ownerId: '', petId: '', dateTime: _dateTime!, reminder: _reminder)
            .reminderDate;
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Appointment' : 'New Appointment')),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              PetSelector(
                value: _petId,
                // Moving an appointment to another pet is not supported.
                enabled: !_isEditing,
                onChanged: (id) => setState(() => _petId = id),
              ),
              gap,
              Text('Type', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in AppointmentType.values)
                    ChoiceChip(
                      avatar: Icon(t.icon, size: 18),
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Date *',
                      initialValue: _date,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                      clearable: false,
                      validator: (d) => d == null ? 'Date is required' : null,
                      onChanged: (d) => setState(() => _date = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimeField(
                      label: 'Time *',
                      initialValue: _time,
                      validator: (t) => t == null ? 'Time is required' : null,
                      onChanged: (t) => setState(() => _time = t),
                    ),
                  ),
                ],
              ),
              if (!_isEditing && _dateTime != null && _dateTime!.isBefore(now))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'This date is in the past — it will be saved as a completed visit.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              gap,
              DropdownButtonFormField<ReminderOffset?>(
                initialValue: _reminder,
                onChanged: (r) => setState(() => _reminder = r),
                decoration: InputDecoration(
                  labelText: 'Reminder',
                  prefixIcon: const Icon(Icons.notifications_outlined),
                  helperText: reminderAt == null
                      ? null
                      : 'We’ll remind you ${DateFormat.MMMd().add_jm().format(reminderAt)}',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No reminder')),
                  for (final r in ReminderOffset.values)
                    DropdownMenuItem(
                      value: r,
                      child: Text(r == ReminderOffset.onTheDay ? '2 hours before' : r.label),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Where & who', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinic,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Clinic',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              gap,
              TextFormField(
                controller: _vet,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              gap,
              TextFormField(
                controller: _reason,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              gap,
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 6,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : _save,
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Schedule Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
