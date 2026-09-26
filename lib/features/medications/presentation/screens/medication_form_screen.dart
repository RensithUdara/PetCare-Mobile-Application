import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/suggestion_field.dart';
import '../../../clinics/presentation/providers/clinic_providers.dart';
import '../../../pets/presentation/widgets/pet_selector.dart';
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
                  appBar: AppBar(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medication.name.trim()} ${_isEditing ? 'updated' : 'added'}')),
    );
    context.pop();
  }

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
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Medication' : 'Add Medication')),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              PetSelector(
                value: _petId,
                enabled: !_isEditing,
                onChanged: (id) => setState(() => _petId = id),
              ),
              gap,
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Medicine name'),
                decoration: const InputDecoration(
                  labelText: 'Medicine name *',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
              ),
              gap,
              TextFormField(
                controller: _dosage,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Dosage'),
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  hintText: 'e.g. 1 tablet, 5 ml',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final d in const ['1 tablet', '½ tablet', '1 capsule', '5 ml', '1 drop'])
                    ActionChip(label: Text(d), onPressed: () => setState(() => _dosage.text = d)),
                ],
              ),
              gap,
              DropdownButtonFormField<MedicationFrequency>(
                initialValue: _frequency,
                onChanged: (f) => _setFrequency(f!),
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: [
                  for (final f in MedicationFrequency.values)
                    DropdownMenuItem(value: f, child: Text(f.label)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Duration', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              DateField(
                label: 'Start date *',
                initialValue: _start,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 2),
                clearable: false,
                validator: (d) => d == null ? 'Start date is required' : null,
                onChanged: (d) => setState(() => _start = d),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ongoing (no end date)'),
                value: _ongoing,
                onChanged: (v) => setState(() => _ongoing = v),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final days in _durations)
                      ActionChip(label: Text('$days days'), onPressed: () => _setDuration(days)),
                  ],
                ),
              ],
              if (_frequency.isScheduled) ...[
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Reminders', style: theme.textTheme.titleSmall),
                  subtitle: const Text('Get notified when a dose is due'),
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                ),
                Text('Dose times', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _times.length; i++)
                      InputChip(
                        avatar: const Icon(Icons.schedule, size: 18),
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
              const SizedBox(height: 24),
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
              gap,
              SuggestionField(
                controller: _vet,
                suggestions: ref.watch(vetNameSuggestionsProvider),
                label: 'Prescribed by',
                icon: Icons.person_outline,
              ),
              gap,
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
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
                    : Text(_isEditing ? 'Save Changes' : 'Add Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
