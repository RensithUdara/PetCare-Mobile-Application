import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/suggestion_field.dart';
import '../../../clinics/presentation/providers/clinic_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../pets/presentation/widgets/pet_choice_field.dart';
import '../../domain/entities/dose_time.dart';
import '../../domain/entities/medication.dart';
import '../controllers/medication_editor_controller.dart';
import '../providers/medication_providers.dart';
import '../widgets/medication_widgets.dart';

/// Add a medication (optionally for [petId]) or edit [medicationId].
class MedicationFormScreen extends ConsumerWidget {
  const MedicationFormScreen({super.key, this.petId, this.medicationId});

  final String? petId;
  final String? medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (medicationId == null) return _MedicationForm(initial: null, petId: petId);
    return ref.watch(medicationProvider(medicationId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) =>
              const Scaffold(body: ErrorView(message: 'Could not load this medication.')),
          data: (m) => m == null
              ? Scaffold(
                  appBar: const BrandAppBar.page(title: 'Medication'),
                  body: const EmptyState(icon: Icons.search_off, title: 'Medication not found'),
                )
              : _MedicationForm(initial: m, petId: m.petId),
        );
  }
}

class _MedicationForm extends ConsumerStatefulWidget {
  const _MedicationForm({required this.initial, required this.petId});

  final Medication? initial;
  final String? petId;

  @override
  ConsumerState<_MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends ConsumerState<_MedicationForm> {
  static const _durations = [5, 7, 10, 14, 30];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _dosage = TextEditingController(text: widget.initial?.dosage);
  late final _instructions = TextEditingController(text: widget.initial?.instructions);
  late final _vet = TextEditingController(text: widget.initial?.veterinarian);
  late final _notes = TextEditingController(text: widget.initial?.notes);

  late String? _petId = widget.petId;
  late MedicationFrequency _frequency = widget.initial?.frequency ?? MedicationFrequency.onceDaily;
  late DateTime? _start = widget.initial?.startDate ?? dateOnly(ref.read(clockProvider)());
  late DateTime? _end = widget.initial?.endDate;
  late bool _ongoing = widget.initial != null && widget.initial!.isOngoing;
  late List<DoseTime> _times = [...?widget.initial?.doseTimes];
  late bool _reminders = widget.initial?.remindersEnabled ?? true;

  /// Bumped when the end date is set programmatically.
  int _endFieldVersion = 0;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_times.isEmpty) _times = [..._frequency.defaultTimes];
  }

  @override
  void dispose() {
    for (final c in [_name, _dosage, _instructions, _vet, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setFrequency(MedicationFrequency f) => setState(() {
        final wasDefault = _listEquals(_times, _frequency.defaultTimes);
        _frequency = f;
        // Only replace times the user hasn't customised.
        if (wasDefault || _times.isEmpty) _times = [...f.defaultTimes];
      });

  void _setDuration(int days) => setState(() {
        _ongoing = false;
        _end = DateTime(_start!.year, _start!.month, _start!.day + days - 1);
        _endFieldVersion++;
      });

  Future<void> _editTime({int? index}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: index == null ? const TimeOfDay(hour: 12, minute: 0) : _times[index].toTimeOfDay(),
    );
    if (picked == null) return;
    setState(() {
      final time = picked.toDoseTime();
      if (index == null) {
        if (!_times.contains(time)) _times.add(time);
      } else {
        _times[index] = time;
      }
      _times = _times.toSet().toList()..sort();
    });
  }

  static bool _listEquals(List<DoseTime> a, List<DoseTime> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial ??
        Medication(ownerId: '', petId: _petId!, name: '', dosage: '', startDate: _start!);
    final medication = base.copyWith(
      petId: _petId!,
      name: _name.text,
      dosage: _dosage.text,
      frequency: _frequency,
      startDate: _start!,
      endDate: _ongoing ? null : _end,
      doseTimes: _times,
      remindersEnabled: _reminders,
      instructions: _instructions.text,
      veterinarian: _vet.text,
      notes: _notes.text,
    );

    final id = await ref.read(medicationEditorControllerProvider.notifier).save(medication);
    if (id == null || !mounted) return;
    await showSuccessDialog(
      context,
      title: '${medication.name.trim()} ${_isEditing ? 'updated' : 'added'}',
    );
    if (mounted) context.pop();
  }

  static String _shortLabel(MedicationFrequency f) => switch (f) {
        MedicationFrequency.threeTimesDaily => '3× daily',
        MedicationFrequency.everyOtherDay => 'Every 2 days',
        MedicationFrequency.weekly => 'Weekly',
        _ => f.label,
      };

  static IconData _frequencyIcon(MedicationFrequency f) => switch (f) {
        MedicationFrequency.onceDaily => Icons.looks_one_outlined,
        MedicationFrequency.twiceDaily => Icons.looks_two_outlined,
        MedicationFrequency.threeTimesDaily => Icons.looks_3_outlined,
        MedicationFrequency.everyOtherDay => Icons.event_repeat_outlined,
        MedicationFrequency.weekly => Icons.date_range_outlined,
        MedicationFrequency.asNeeded => Icons.pan_tool_alt_outlined,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(medicationEditorControllerProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error is Failure ? error.message : 'Something went wrong.'),
        ));
      }
    });
    final busy = ref.watch(medicationEditorControllerProvider).isLoading;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final pets = ref.watch(petsProvider).value ?? const [];
    final pet = pets.where((p) => p.id == _petId).firstOrNull;
    final date = DateFormat.MMMd();
    final white80 = Colors.white.withValues(alpha: 0.85);
    const accent = FeatureAccent.medications;
    final name = _name.text.trim();
    final summary = [
      if (_dosage.text.trim().isNotEmpty) _dosage.text.trim(),
      _frequency.label,
      if (pet != null) 'for ${pet.name}',
    ].join(' · ');
    final schedule = _frequency.isScheduled && _times.isNotEmpty
        ? _times.map((t) => t.format(context)).join(' · ')
        : _frequency.isScheduled
            ? 'No dose times yet'
            : 'Given when needed';
    final duration = _start == null
        ? 'Pick a start date'
        : _ongoing || _end == null
            ? 'From ${date.format(_start!)} · ongoing'
            : '${date.format(_start!)} → ${date.format(_end!)}';

    Widget heroLine(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Icon(icon, size: 16, color: white80),
              const SizedBox(width: 6),
              Flexible(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: white80)),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: BrandAppBar.page(title: _isEditing ? 'Edit Medication' : 'Add Medication'),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Add Medication',
        icon: _isEditing ? Icons.check_rounded : Icons.medication_rounded,
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
              // Live summary of the prescription.
              GradientHeader(
                floating: true,
                margin: const EdgeInsets.only(top: 16),
                gradient: accent.gradient,
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
                      child: const Icon(Icons.medication_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'New medication' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          heroLine(Icons.medication_liquid_outlined, summary),
                          heroLine(Icons.schedule_rounded, schedule),
                          heroLine(Icons.date_range_rounded, duration),
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
                subtitle: _isEditing ? 'A medication can’t be moved to another pet.' : null,
                children: [
                  PetChoiceField(
                    value: _petId,
                    enabled: !_isEditing,
                    onChanged: (id) => setState(() => _petId = id),
                  ),
                ],
              ),
              FormSection(
                title: 'Medicine',
                icon: Icons.medication_outlined,
                accent: accent,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => Validators.required(v, field: 'Medicine name'),
                    decoration: const InputDecoration(
                      labelText: 'Medicine name *',
                      hintText: 'e.g. Amoxicillin',
                      prefixIcon: Icon(Icons.medication_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: _dosage,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => Validators.required(v, field: 'Dosage'),
                    decoration: const InputDecoration(
                      labelText: 'Dosage *',
                      hintText: 'e.g. 1 tablet, 5 ml',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in const ['1 tablet', '½ tablet', '1 capsule', '5 ml', '1 drop'])
                        ActionChip(
                          label: Text(d),
                          backgroundColor: _dosage.text.trim() == d ? accent.color.withValues(alpha: 0.18) : null,
                          onPressed: () => setState(() => _dosage.text = d),
                        ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Schedule',
                icon: Icons.schedule_rounded,
                accent: FeatureAccent.appointments,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('How often'),
                      TileGrid(
                        children: [
                          for (final f in MedicationFrequency.values)
                            SelectTile(
                              label: _shortLabel(f),
                              icon: _frequencyIcon(f),
                              accent: FeatureAccent.appointments,
                              selected: _frequency == f,
                              onTap: () => _setFrequency(f),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (_frequency.isScheduled) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FieldLabel('Dose times'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < _times.length; i++)
                              InputChip(
                                avatar: Icon(Icons.alarm_rounded, size: 18, color: FeatureAccent.appointments.color),
                                label: Text(_times[i].format(context)),
                                onPressed: () => _editTime(index: i),
                                onDeleted: () => setState(() => _times.removeAt(i)),
                              ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 18),
                              label: const Text('Add time'),
                              onPressed: _editTime,
                            ),
                          ],
                        ),
                        if (_reminders && _times.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Add at least one time to receive reminders',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: FeatureAccent.appointments.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        secondary: Icon(
                          _reminders ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                          color: FeatureAccent.appointments.color,
                        ),
                        title: const Text('Dose reminders', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Get notified when a dose is due'),
                        value: _reminders,
                        onChanged: (v) => setState(() => _reminders = v),
                      ),
                    ),
                  ],
                ],
              ),
              FormSection(
                title: 'Duration',
                icon: Icons.date_range_outlined,
                accent: FeatureAccent.calendar,
                children: [
                  DateField(
                    label: 'Start date *',
                    initialValue: _start,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 2),
                    clearable: false,
                    validator: (d) => d == null ? 'Start date is required' : null,
                    onChanged: (d) => setState(() => _start = d),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: FeatureAccent.calendar.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      secondary: Icon(Icons.all_inclusive_rounded, color: FeatureAccent.calendar.color),
                      title: const Text('Ongoing (no end date)', style: TextStyle(fontWeight: FontWeight.w700)),
                      value: _ongoing,
                      onChanged: (v) => setState(() => _ongoing = v),
                    ),
                  ),
                  if (!_ongoing) ...[
                    DateField(
                      key: ValueKey('end-$_endFieldVersion'),
                      label: 'End date',
                      initialValue: _end,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                      validator: (d) {
                        if (d == null) return 'Choose an end date or mark as ongoing';
                        if (_start != null && dateOnly(d).isBefore(dateOnly(_start!))) {
                          return 'Cannot be before the start date';
                        }
                        return null;
                      },
                      onChanged: (d) => setState(() => _end = d),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final days in _durations)
                          ActionChip(
                            avatar: Icon(Icons.timelapse_rounded, size: 16, color: FeatureAccent.calendar.color),
                            label: Text('$days days'),
                            onPressed: () => _setDuration(days),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              FormSection(
                title: 'Details',
                icon: Icons.sticky_note_2_outlined,
                accent: FeatureAccent.documents,
                children: [
                  TextFormField(
                    controller: _instructions,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'e.g. Give with food',
                      alignLabelWithHint: true,
                    ),
                  ),
                  SuggestionField(
                    controller: _vet,
                    suggestions: ref.watch(vetNameSuggestionsProvider),
                    label: 'Prescribed by',
                    icon: Icons.person_outline,
                  ),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Side effects to watch for, how your pet takes it…',
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
