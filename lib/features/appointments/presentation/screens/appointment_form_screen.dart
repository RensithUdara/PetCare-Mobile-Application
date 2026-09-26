import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/reminder_offset.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/suggestion_field.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../clinics/presentation/providers/clinic_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../pets/presentation/widgets/pet_choice_field.dart';
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
                  appBar: const BrandAppBar.page(title: 'Appointment'),
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

    await showSuccessDialog(
      context,
      title: _isEditing ? 'Appointment updated' : 'Appointment scheduled',
      message: '${appointment.type.label} on ${DateFormat.yMMMEd().add_jm().format(appointment.dateTime)}.',
    );
    if (mounted) context.pop();
  }

  static String _shortLabel(AppointmentType t) => switch (t) {
        AppointmentType.routineCheckup => 'Checkup',
        _ => t.label,
      };

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
    final pets = ref.watch(petsProvider).value ?? const [];
    final pet = pets.where((p) => p.id == _petId).firstOrNull;
    final reminderAt = _dateTime == null || _reminder == null
        ? null
        : Appointment(ownerId: '', petId: '', dateTime: _dateTime!, reminder: _reminder)
            .reminderDate;
    final white80 = Colors.white.withValues(alpha: 0.85);

    return Scaffold(
      appBar: BrandAppBar.page(title: _isEditing ? 'Edit Appointment' : 'New Appointment'),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Schedule Appointment',
        icon: _isEditing ? Icons.check_rounded : Icons.event_available_rounded,
        busy: busy,
        busyLabel: 'Saving…',
        onPressed: _save,
      ),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // Live summary of the visit being booked.
              GradientHeader(
                floating: true,
                margin: const EdgeInsets.only(top: 16),
                gradient: FeatureAccent.appointments.gradient,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: Icon(_type.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_type.label}${pet == null ? '' : ' · ${pet.name}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.event_rounded, size: 16, color: white80),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _date == null
                                      ? 'Pick a date'
                                      : DateFormat.yMMMEd().format(_date!),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: white80),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: white80),
                              const SizedBox(width: 6),
                              Text(
                                _time == null ? 'Pick a time' : _time!.format(context),
                                style: theme.textTheme.bodyMedium?.copyWith(color: white80),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FormSection(
                title: 'Which pet?',
                icon: Icons.pets,
                accent: FeatureAccent.pets,
                subtitle: _isEditing ? 'An appointment can’t be moved to another pet.' : null,
                children: [
                  PetChoiceField(
                    value: _petId,
                    enabled: !_isEditing,
                    onChanged: (id) => setState(() => _petId = id),
                  ),
                ],
              ),
              FormSection(
                title: 'Visit type',
                icon: Icons.medical_services_outlined,
                accent: FeatureAccent.appointments,
                children: [
                  TileGrid(
                    children: [
                      for (final t in AppointmentType.values)
                        SelectTile(
                          label: _shortLabel(t),
                          icon: t.icon,
                          accent: FeatureAccent.appointments,
                          selected: _type == t,
                          onTap: () => setState(() => _type = t),
                        ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'When',
                icon: Icons.event_outlined,
                accent: FeatureAccent.calendar,
                children: [
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FeatureAccent.documents.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, color: FeatureAccent.documents.deep),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('This date is in the past — it will be saved as a completed visit.'),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<ReminderOffset?>(
                    initialValue: _reminder,
                    isExpanded: true,
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
                ],
              ),
              FormSection(
                title: 'Where & who',
                icon: Icons.local_hospital_outlined,
                accent: FeatureAccent.clinics,
                children: [
                  SuggestionField(
                    controller: _clinic,
                    suggestions: ref.watch(clinicNameSuggestionsProvider),
                    label: 'Clinic',
                    icon: Icons.local_hospital_outlined,
                  ),
                  SuggestionField(
                    controller: _vet,
                    suggestions: ref.watch(vetNameSuggestionsProvider),
                    label: 'Veterinarian',
                    icon: Icons.person_outline,
                  ),
                  TextFormField(
                    controller: _reason,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'e.g. Annual checkup, limping',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                  ),
                ],
              ),
              FormSection(
                title: 'Notes',
                icon: Icons.sticky_note_2_outlined,
                accent: FeatureAccent.documents,
                children: [
                  TextFormField(
                    controller: _notes,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Questions to ask, things to bring…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
