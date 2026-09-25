import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/pet.dart';
import 'pet_editor_controller.dart';
import 'pet_providers.dart';
import 'widgets/pet_card.dart';
import 'widgets/pet_photo_picker.dart';

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
                  appBar: AppBar(),
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

    final id = await ref.read(petEditorControllerProvider.notifier).save(pet, photo: _photo);
    if (id == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? '${pet.name} updated' : '${pet.name} added')),
    );
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
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit ${widget.initial!.name}' : 'Add Pet')),
      body: AbsorbPointer(
        absorbing: editor.isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              PetPhotoPicker(
                species: _species ?? PetSpecies.other,
                existingUrl: widget.initial?.photoUrl,
                change: _photo,
                onChanged: (change) => setState(() => _photo = change),
              ),
              const SizedBox(height: 24),
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
              gap,
              _SpeciesField(
                initialValue: _species,
                onChanged: (s) => setState(() => _species = s),
              ),
              gap,
              TextFormField(
                controller: _breed,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              gap,
              Text('Gender', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<PetGender>(
                segments: [
                  for (final g in PetGender.values)
                    ButtonSegment(value: g, label: Text(g.label)),
                ],
                selected: {_gender},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _gender = s.first),
              ),
              gap,
              DateField(
                label: 'Date of birth',
                initialValue: _dateOfBirth,
                firstDate: DateTime(1980),
                lastDate: DateTime.now(),
                icon: Icons.cake_outlined,
                validator: Validators.notInFuture,
                onChanged: (d) => _dateOfBirth = d,
              ),
              gap,
              TextFormField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: Validators.weight,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              gap,
              TextFormField(
                controller: _color,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Text('Identification', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _microchip,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Microchip ID',
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
              gap,
              TextFormField(
                controller: _registration,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Registration number',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              gap,
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 6,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: editor.isBusy ? null : _save,
                child: editor.isBusy
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          if (editor.uploadProgress != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              'Uploading photo ${(editor.uploadProgress! * 100).round()}%',
                            ),
                          ],
                        ],
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Add Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Required species choice rendered as chips.
class _SpeciesField extends FormField<PetSpecies> {
  _SpeciesField({super.initialValue, required ValueChanged<PetSpecies> onChanged})
      : super(
          validator: (v) => v == null ? 'Choose a species' : null,
          builder: (field) {
            final theme = Theme.of(field.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Species *', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in PetSpecies.values)
                      ChoiceChip(
                        label: Text('${s.emoji}  ${s.label}'),
                        selected: field.value == s,
                        onSelected: (_) {
                          field.didChange(s);
                          onChanged(s);
                        },
                      ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
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
