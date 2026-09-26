import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/reminder_offset.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/suggestion_field.dart';
import '../../../clinics/presentation/providers/clinic_providers.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/logic/common_vaccines.dart';
import '../controllers/vaccination_editor_controller.dart';
import '../providers/vaccination_providers.dart';

/// Add a vaccination for [petId], or edit [vaccinationId].
class VaccinationFormScreen extends ConsumerWidget {
  const VaccinationFormScreen({super.key, this.petId, this.vaccinationId})
      : assert(petId != null || vaccinationId != null);

  final String? petId;
  final String? vaccinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PetSpecies speciesOf(String petId) =>
        ref.watch(petProvider(petId)).value?.species ?? PetSpecies.other;

    if (vaccinationId == null) {
      return _VaccinationForm(petId: petId!, species: speciesOf(petId!), initial: null);
    }
    return ref.watch(vaccinationProvider(vaccinationId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) =>
              const Scaffold(body: ErrorView(message: 'Could not load this vaccination.')),
          data: (v) => v == null
              ? Scaffold(
                  appBar: const BrandAppBar.page(title: 'Vaccination'),
                  body: const EmptyState(icon: Icons.search_off, title: 'Record not found'),
                )
              : _VaccinationForm(petId: v.petId, species: speciesOf(v.petId), initial: v),
        );
  }
}

class _VaccinationForm extends ConsumerStatefulWidget {
  const _VaccinationForm({required this.petId, required this.species, required this.initial});

  final String petId;
  final PetSpecies species;
  final Vaccination? initial;

  @override
  ConsumerState<_VaccinationForm> createState() => _VaccinationFormState();
}

class _VaccinationFormState extends ConsumerState<_VaccinationForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.vaccineName);
  late final _vet = TextEditingController(text: widget.initial?.veterinarian);
  late final _clinic = TextEditingController(text: widget.initial?.clinic);
  late final _batch = TextEditingController(text: widget.initial?.batchNumber);
  late final _notes = TextEditingController(text: widget.initial?.notes);

  late VaccineCategory _category = widget.initial?.category ?? VaccineCategory.core;
  late DateTime? _administered =
      widget.initial?.dateAdministered ?? dateOnly(ref.read(clockProvider)());
  late DateTime? _nextDue = widget.initial?.nextDueDate;
  late ReminderOffset? _reminder =
      widget.initial == null ? ReminderOffset.sevenDays : widget.initial!.reminder;

  /// Bumped when the due date is set programmatically so the field
  /// re-initializes with the new value.
  int _dueFieldVersion = 0;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_name, _vet, _clinic, _batch, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applySuggestion(CommonVaccine vaccine) {
    setState(() {
      _name.text = vaccine.name;
      _category = vaccine.category;
      if (_nextDue == null && vaccine.boosterMonths != null && _administered != null) {
        _setDue(addMonths(_administered!, vaccine.boosterMonths!));
      }
    });
  }

  void _setDue(DateTime? due) {
    _nextDue = due;
    _dueFieldVersion++;
  }

  String? _validateDue(DateTime? due) {
    if (due == null || _administered == null) return null;
    if (!dateOnly(due).isAfter(dateOnly(_administered!))) {
      return 'Must be after the date administered';
    }
    return null;
  }

  static String? _clean(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial ??
        Vaccination(
          ownerId: '',
          petId: widget.petId,
          vaccineName: '',
          dateAdministered: _administered!,
        );
    final vaccination = base.copyWith(
      vaccineName: _name.text.trim(),
      category: _category,
      dateAdministered: _administered!,
      nextDueDate: _nextDue,
      veterinarian: _clean(_vet),
      clinic: _clean(_clinic),
      batchNumber: _clean(_batch),
      notes: _clean(_notes),
      reminder: _reminder,
    );

    final id = await ref.read(vaccinationEditorControllerProvider.notifier).save(vaccination);
    if (id == null || !mounted) return;

    await showSuccessDialog(
      context,
      title: '${vaccination.vaccineName} ${_isEditing ? 'updated' : 'added'}',
      message: vaccination.nextDueDate == null
          ? null
          : 'Next dose due ${DateFormat.yMMMd().format(vaccination.nextDueDate!)}.',
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(vaccinationEditorControllerProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error is Failure ? error.message : 'Something went wrong.'),
        ));
      }
    });
    final busy = ref.watch(vaccinationEditorControllerProvider).isLoading;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final suggestions = commonVaccinesFor(widget.species);
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: BrandAppBar.page(title: _isEditing ? 'Edit Vaccination' : 'Add Vaccination'),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Vaccine name'),
                decoration: const InputDecoration(
                  labelText: 'Vaccine name *',
                  prefixIcon: Icon(Icons.vaccines_outlined),
                ),
              ),
              if (suggestions.isNotEmpty && !_isEditing) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in suggestions)
                      ActionChip(label: Text(s.name), onPressed: () => _applySuggestion(s)),
                  ],
                ),
              ],
              gap,
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<VaccineCategory>(
                segments: [
                  for (final c in VaccineCategory.values) ButtonSegment(value: c, label: Text(c.label)),
                ],
                selected: {_category},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _category = s.first),
              ),
              gap,
              DateField(
                label: 'Date administered *',
                initialValue: _administered,
                firstDate: DateTime(1990),
                lastDate: now,
                clearable: false,
                icon: Icons.event_available_outlined,
                validator: (d) => d == null
                    ? 'Date administered is required'
                    : Validators.notInFuture(d, now: now),
                onChanged: (d) => setState(() => _administered = d),
              ),
              gap,
              DateField(
                key: ValueKey('due-$_dueFieldVersion'),
                label: 'Next due date',
                initialValue: _nextDue,
                firstDate: DateTime(1990),
                lastDate: DateTime(now.year + 10),
                icon: Icons.event_repeat_outlined,
                validator: _validateDue,
                onChanged: (d) => setState(() => _nextDue = d),
              ),
              if (_administered != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (label, months) in const [
                      ('+ 1 month', 1),
                      ('+ 6 months', 6),
                      ('+ 1 year', 12),
                      ('+ 3 years', 36),
                    ])
                      ActionChip(
                        label: Text(label),
                        onPressed: () =>
                            setState(() => _setDue(addMonths(_administered!, months))),
                      ),
                  ],
                ),
              ],
              gap,
              DropdownButtonFormField<ReminderOffset?>(
                initialValue: _nextDue == null ? null : _reminder,
                onChanged: _nextDue == null ? null : (r) => setState(() => _reminder = r),
                decoration: InputDecoration(
                  labelText: 'Reminder',
                  prefixIcon: const Icon(Icons.notifications_outlined),
                  helperText: _nextDue == null
                      ? 'Set a next due date to enable reminders'
                      : _reminder == null
                          ? null
                          : 'We’ll remind you on '
                              '${DateFormat.yMMMd().format(_reminder!.reminderDateFor(_nextDue!))}',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No reminder')),
                  for (final r in ReminderOffset.values)
                    DropdownMenuItem(value: r, child: Text(r.label)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Administered by', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              SuggestionField(
                controller: _vet,
                suggestions: ref.watch(vetNameSuggestionsProvider),
                label: 'Veterinarian',
                icon: Icons.person_outline,
              ),
              gap,
              SuggestionField(
                controller: _clinic,
                suggestions: ref.watch(clinicNameSuggestionsProvider),
                label: 'Clinic',
                icon: Icons.local_hospital_outlined,
              ),
              gap,
              TextFormField(
                controller: _batch,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Batch number',
                  prefixIcon: Icon(Icons.qr_code_2),
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
                    : Text(_isEditing ? 'Save Changes' : 'Add Vaccination'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
