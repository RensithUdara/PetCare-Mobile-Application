import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/reminder_offset.dart';
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
    final date = DateFormat.yMMMd();
    final white80 = Colors.white.withValues(alpha: 0.85);
    const accent = FeatureAccent.vaccinations;
    final name = _name.text.trim();

    return Scaffold(
      appBar: BrandAppBar.page(title: _isEditing ? 'Edit Vaccination' : 'Add Vaccination'),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Add Vaccination',
        icon: _isEditing ? Icons.check_rounded : Icons.vaccines_outlined,
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
              // Live summary of the dose being recorded.
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
                      child: const Icon(Icons.vaccines_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name.isEmpty ? 'New vaccination' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_category.label,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.event_available_rounded, size: 16, color: white80),
                              const SizedBox(width: 6),
                              Text(_administered == null ? 'Pick the date given' : 'Given ${date.format(_administered!)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: white80)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.event_repeat_rounded, size: 16, color: white80),
                              const SizedBox(width: 6),
                              Text(_nextDue == null ? 'No next dose set' : 'Next due ${date.format(_nextDue!)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: white80)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FormSection(
                title: 'Vaccine',
                icon: Icons.vaccines_outlined,
                accent: accent,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => Validators.required(v, field: 'Vaccine name'),
                    decoration: const InputDecoration(
                      labelText: 'Vaccine name *',
                      prefixIcon: Icon(Icons.vaccines_outlined),
                    ),
                  ),
                  if (suggestions.isNotEmpty && !_isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FieldLabel('Common vaccines'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in suggestions)
                              ActionChip(
                                avatar: Icon(Icons.bolt_rounded, size: 16, color: accent.color),
                                label: Text(s.name),
                                backgroundColor: _name.text.trim() == s.name ? accent.color.withValues(alpha: 0.18) : null,
                                onPressed: () => _applySuggestion(s),
                              ),
                          ],
                        ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Category'),
                      TileGrid(
                        children: [
                          for (final c in VaccineCategory.values)
                            SelectTile(
                              label: c.label,
                              icon: switch (c) {
                                VaccineCategory.core => Icons.verified_user_outlined,
                                VaccineCategory.nonCore => Icons.shield_outlined,
                                VaccineCategory.other => Icons.more_horiz_rounded,
                              },
                              accent: accent,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Dates & reminder',
                icon: Icons.event_outlined,
                accent: FeatureAccent.calendar,
                children: [
                  DateField(
                    label: 'Date administered *',
                    initialValue: _administered,
                    firstDate: DateTime(1990),
                    lastDate: now,
                    clearable: false,
                    icon: Icons.event_available_outlined,
                    validator: (d) => d == null ? 'Date administered is required' : Validators.notInFuture(d, now: now),
                    onChanged: (d) => setState(() => _administered = d),
                  ),
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
                  if (_administered != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (label, months) in const [
                          ('+ 1 month', 1),
                          ('+ 6 months', 6),
                          ('+ 1 year', 12),
                          ('+ 3 years', 36),
                        ])
                          ActionChip(
                            avatar: Icon(Icons.add_alarm_rounded, size: 16, color: FeatureAccent.calendar.color),
                            label: Text(label.substring(2)),
                            onPressed: () => setState(() => _setDue(addMonths(_administered!, months))),
                          ),
                      ],
                    ),
                  DropdownButtonFormField<ReminderOffset?>(
                    initialValue: _nextDue == null ? null : _reminder,
                    isExpanded: true,
                    onChanged: _nextDue == null ? null : (r) => setState(() => _reminder = r),
                    decoration: InputDecoration(
                      labelText: 'Reminder',
                      prefixIcon: const Icon(Icons.notifications_outlined),
                      helperMaxLines: 2,
                      helperText: _nextDue == null
                          ? 'Set a next due date to enable reminders'
                          : _reminder == null
                              ? null
                              : 'We’ll remind you on ${date.format(_reminder!.reminderDateFor(_nextDue!))}',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No reminder')),
                      for (final r in ReminderOffset.values) DropdownMenuItem(value: r, child: Text(r.label)),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Administered by',
                icon: Icons.local_hospital_outlined,
                accent: FeatureAccent.clinics,
                children: [
                  SuggestionField(
                    controller: _vet,
                    suggestions: ref.watch(vetNameSuggestionsProvider),
                    label: 'Veterinarian',
                    icon: Icons.person_outline,
                  ),
                  SuggestionField(
                    controller: _clinic,
                    suggestions: ref.watch(clinicNameSuggestionsProvider),
                    label: 'Clinic',
                    icon: Icons.local_hospital_outlined,
                  ),
                  TextFormField(
                    controller: _batch,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Batch number',
                      hintText: 'From the vaccine sticker',
                      prefixIcon: Icon(Icons.qr_code_2),
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
                      hintText: 'Reactions, advice from the vet…',
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
