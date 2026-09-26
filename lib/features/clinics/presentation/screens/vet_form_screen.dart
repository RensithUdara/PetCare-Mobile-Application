import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/clinic.dart';
import '../controllers/clinic_editor_controller.dart';
import '../providers/clinic_providers.dart';

/// Add a veterinarian (optionally at [clinicId]) or edit [vetId].
class VetFormScreen extends ConsumerWidget {
  const VetFormScreen({super.key, this.vetId, this.clinicId});

  final String? vetId;
  final String? clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vetId == null) return _VetForm(initial: null, clinicId: clinicId);
    return ref.watch(vetsProvider).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => const Scaffold(body: ErrorView(message: 'Could not load this vet.')),
          data: (vets) {
            final vet = vets.where((v) => v.id == vetId).firstOrNull;
            return vet == null
                ? Scaffold(
                    appBar: const BrandAppBar.page(title: 'Veterinarian'),
                    body: const EmptyState(icon: Icons.search_off, title: 'Veterinarian not found'),
                  )
                : _VetForm(initial: vet, clinicId: vet.clinicId);
          },
        );
  }
}

class _VetForm extends ConsumerStatefulWidget {
  const _VetForm({required this.initial, this.clinicId});

  final Veterinarian? initial;
  final String? clinicId;

  @override
  ConsumerState<_VetForm> createState() => _VetFormState();
}

class _VetFormState extends ConsumerState<_VetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? 'Dr. ');
  late final _specialization = TextEditingController(text: widget.initial?.specialization);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _email = TextEditingController(text: widget.initial?.email);
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late String? _clinicId = widget.clinicId;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_name, _specialization, _phone, _email, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _showError() {
    final error = ref.read(clinicEditorControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error is Failure ? error.message : 'Something went wrong.')),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final base = widget.initial ?? const Veterinarian(ownerId: '', name: '');
    final id = await ref.read(clinicEditorControllerProvider.notifier).saveVet(base.copyWith(
          name: _name.text,
          clinicId: _clinicId,
          specialization: _specialization.text,
          phone: _phone.text,
          email: _email.text,
          notes: _notes.text,
        ));
    if (!mounted) return;
    if (id == null) return _showError();
    await showSuccessDialog(
      context,
      title: _isEditing ? 'Veterinarian updated' : 'Veterinarian saved',
      message: _name.text.trim(),
    );
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${widget.initial!.name}?',
      message: 'This removes the veterinarian from your contacts.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await ref.read(clinicEditorControllerProvider.notifier).deleteVet(widget.initial!.id);
    if (!mounted) return;
    if (!ok) return _showError();
    context.pop();
  }

  static const _specialties = [
    'General practice',
    'Surgery',
    'Dermatology',
    'Dentistry',
    'Cardiology',
    'Exotic animals',
  ];

  /// "Dr. Nimali Perera" → "NP".
  static String _initials(String name) => name
      .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(clinicEditorControllerProvider).isLoading;
    final clinics = ref.watch(clinicsProvider).value ?? const <Clinic>[];
    final clinicValue = clinics.any((c) => c.id == _clinicId) ? _clinicId : null;
    final clinicName = clinics.where((c) => c.id == clinicValue).firstOrNull?.name;
    final theme = Theme.of(context);
    final name = _name.text.replaceFirst(RegExp(r'^Dr\.?\s*$'), '').trim();
    final initials = _initials(name);
    const accent = FeatureAccent.clinics;

    return Scaffold(
      appBar: BrandAppBar.page(
        title: _isEditing ? 'Edit Veterinarian' : 'Add Veterinarian',
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: busy ? null : _delete,
            ),
        ],
      ),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Save Veterinarian',
        icon: _isEditing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
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
              // Live preview of the contact card.
              GradientHeader(
                floating: true,
                gradient: accent.gradient,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: initials.isEmpty
                          ? Icon(Icons.medical_services_rounded, size: 30, color: accent.deep)
                          : Text(initials,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: accent.deep, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'New veterinarian' : _name.text.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (_specialization.text.trim().isNotEmpty) _specialization.text.trim(),
                              clinicName ?? 'Save your pet’s vet',
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FormSection(
                title: 'Veterinarian',
                icon: Icons.medical_services_outlined,
                accent: accent,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final name = v?.replaceFirst(RegExp(r'^Dr\.?\s*$'), '');
                      return Validators.required(name, field: 'Name');
                    },
                    decoration: const InputDecoration(labelText: 'Name *', prefixIcon: Icon(Icons.person_outline)),
                  ),
                  TextFormField(
                    controller: _specialization,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      hintText: 'e.g. General Veterinary Medicine',
                      prefixIcon: Icon(Icons.workspace_premium_outlined),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in _specialties)
                        ChoiceChip(
                          label: Text(s),
                          selected: _specialization.text.trim() == s,
                          selectedColor: accent.color.withValues(alpha: 0.2),
                          onSelected: (_) => setState(() => _specialization.text = s),
                        ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Works at',
                icon: Icons.local_hospital_outlined,
                accent: FeatureAccent.pets,
                subtitle: clinics.isEmpty
                    ? 'Add a clinic first to link this vet to it.'
                    : 'Link the vet to one of your saved clinics.',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ClinicChip(
                        label: 'No clinic',
                        icon: Icons.block_outlined,
                        selected: clinicValue == null,
                        onTap: () => setState(() => _clinicId = null),
                      ),
                      for (final c in clinics)
                        _ClinicChip(
                          label: c.name,
                          icon: Icons.local_hospital_rounded,
                          selected: clinicValue == c.id,
                          onTap: () => setState(() => _clinicId = c.id),
                        ),
                    ],
                  ),
                ],
              ),
              FormSection(
                title: 'Contact',
                icon: Icons.call_outlined,
                accent: FeatureAccent.appointments,
                children: [
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: '+94 77 123 4567',
                      prefixIcon: Icon(Icons.call_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.email(v),
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
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
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Consultation days, languages, what they’re great with…',
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

/// Selectable clinic pill for the "Works at" section.
class _ClinicChip extends StatelessWidget {
  const _ClinicChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = FeatureAccent.pets.color;
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : color),
      label: Text(label, overflow: TextOverflow.ellipsis),
      selected: selected,
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
