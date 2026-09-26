import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/photo_change.dart';
import '../controllers/pet_editor_controller.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_card.dart';
import '../widgets/pet_photo_picker.dart';

/// Add a pet (no [petId]) or edit an existing one.
class PetFormScreen extends ConsumerWidget {
  const PetFormScreen({super.key, this.petId});

  final String? petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (petId == null) return const _PetForm(initial: null);

    return ref.watch(petProvider(petId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => const Scaffold(
            body: ErrorView(message: 'Could not load this pet.'),
          ),
          data: (pet) => pet == null
              ? Scaffold(
                  appBar: const BrandAppBar.page(title: 'Pet'),
                  body: const EmptyState(icon: Icons.search_off, title: 'Pet not found'),
                )
              : _PetForm(initial: pet),
        );
  }
}

class _PetForm extends ConsumerStatefulWidget {
  const _PetForm({required this.initial});

  final Pet? initial;

  @override
  ConsumerState<_PetForm> createState() => _PetFormState();
}

class _PetFormState extends ConsumerState<_PetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _breed = TextEditingController(text: widget.initial?.breed);
  late final _weight = TextEditingController(
    text: widget.initial?.weightKg == null ? '' : formatWeight(widget.initial!.weightKg!),
  );
  late final _color = TextEditingController(text: widget.initial?.color);
  late final _microchip = TextEditingController(text: widget.initial?.microchipId);
  late final _registration =
      TextEditingController(text: widget.initial?.registrationNumber);
  late final _notes = TextEditingController(text: widget.initial?.notes);

  late PetSpecies? _species = widget.initial?.species;
  late PetGender _gender = widget.initial?.gender ?? PetGender.unknown;
  late DateTime? _dateOfBirth = widget.initial?.dateOfBirth;
  PhotoChange _photo = const PhotoUnchanged();

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_name, _breed, _weight, _color, _microchip, _registration, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? _clean(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final weightText = _clean(_weight);
    final base = widget.initial ??
        const Pet(ownerId: '', name: '', species: PetSpecies.other);
    final pet = base.copyWith(
      name: _name.text.trim(),
      species: _species!,
      breed: _clean(_breed),
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      weightKg: weightText == null ? null : double.parse(weightText.replaceAll(',', '.')),
      color: _clean(_color),
      microchipId: _clean(_microchip),
      registrationNumber: _clean(_registration),
      notes: _clean(_notes),
    );

    final id = await ref.read(petEditorControllerProvider.notifier).save(
          pet,
          photo: _photo,
          logWeight: pet.weightKg != null && pet.weightKg != widget.initial?.weightKg,
        );
    if (id == null || !mounted) return;

    await showSuccessDialog(
      context,
      title: _isEditing ? 'Changes saved' : '${pet.name} added!',
      message: _isEditing
          ? '${pet.name}’s profile is up to date.'
          : 'Welcome to the family, ${pet.name}. You can now add vaccinations, visits and more.',
    );
    if (!mounted) return;
    if (_isEditing) {
      context.pop();
    } else {
      context.go(AppRoutes.petDetails(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(petEditorControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });
    final editor = ref.watch(petEditorControllerProvider);
    final theme = Theme.of(context);
    final title = _isEditing ? 'Edit ${widget.initial!.name}' : 'Add Pet';

    return Scaffold(
      appBar: BrandAppBar.page(title: title),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Add Pet',
        icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
        busy: editor.isBusy,
        busyLabel: editor.uploadProgress == null
            ? 'Saving…'
            : 'Uploading photo ${(editor.uploadProgress! * 100).round()}%',
        onPressed: _save,
      ),
      body: AbsorbPointer(
        absorbing: editor.isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              GradientHeader(
                floating: true,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    PetPhotoPicker(
                      species: _species ?? PetSpecies.other,
                      existingUrl: widget.initial?.photoUrl,
                      change: _photo,
                      onChanged: (change) => setState(() => _photo = change),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isEditing ? 'Update ${widget.initial!.name}’s details' : 'Let’s meet your pet',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the photo to add a picture',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              FormSection(
                title: 'Basics',
                icon: Icons.pets,
                accent: FeatureAccent.pets,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 40,
                    validator: (v) => Validators.required(v, field: 'Pet name'),
                    decoration: const InputDecoration(
                      labelText: 'Pet name *',
                      prefixIcon: Icon(Icons.pets),
                      counterText: '',
                    ),
                  ),
                  _SpeciesField(
                    initialValue: _species,
                    onChanged: (s) => setState(() => _species = s),
                  ),
                  TextFormField(
                    controller: _breed,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      hintText: 'e.g. Golden Retriever',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                ],
              ),
              FormSection(
                title: 'About',
                icon: Icons.favorite_outline,
                accent: FeatureAccent.weight,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Gender'),
                      TileGrid(
                        children: [
                          for (final g in PetGender.values)
                            SelectTile(
                              label: g.label,
                              icon: switch (g) {
                                PetGender.male => Icons.male_rounded,
                                PetGender.female => Icons.female_rounded,
                                PetGender.unknown => Icons.question_mark_rounded,
                              },
                              accent: switch (g) {
                                PetGender.male => FeatureAccent.appointments,
                                PetGender.female => FeatureAccent.weight,
                                PetGender.unknown => FeatureAccent.settings,
                              },
                              selected: _gender == g,
                              onTap: () => setState(() => _gender = g),
                            ),
                        ],
                      ),
                    ],
                  ),
                  DateField(
                    label: 'Date of birth',
                    initialValue: _dateOfBirth,
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                    icon: Icons.cake_outlined,
                    validator: Validators.notInFuture,
                    onChanged: (d) => _dateOfBirth = d,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weight,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          validator: Validators.weight,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            suffixText: 'kg',
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                            errorMaxLines: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _color,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Color',
                            prefixIcon: Icon(Icons.palette_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Identification',
                icon: Icons.badge_outlined,
                accent: FeatureAccent.documents,
                subtitle: 'Helps reunite you if your pet gets lost.',
                children: [
                  TextFormField(
                    controller: _microchip,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Microchip ID',
                      prefixIcon: Icon(Icons.memory),
                    ),
                  ),
                  TextFormField(
                    controller: _registration,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Registration number',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                  ),
                ],
              ),
              FormSection(
                title: 'Notes',
                icon: Icons.sticky_note_2_outlined,
                accent: FeatureAccent.calendar,
                children: [
                  TextFormField(
                    controller: _notes,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Allergies, temperament, favourite treats…',
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

/// Required species choice rendered as colourful tiles.
class _SpeciesField extends FormField<PetSpecies> {
  _SpeciesField({super.initialValue, required ValueChanged<PetSpecies> onChanged})
      : super(
          validator: (v) => v == null ? 'Choose a species' : null,
          builder: (field) {
            final theme = Theme.of(field.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FieldLabel('Species *'),
                TileGrid(
                  children: [
                    for (final s in PetSpecies.values)
                      SelectTile(
                        label: s.label,
                        emoji: s.emoji,
                        accent: FeatureAccent.pets,
                        selected: field.value == s,
                        onTap: () {
                          field.didChange(s);
                          onChanged(s);
                        },
                      ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      field.errorText!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            );
          },
        );
}
