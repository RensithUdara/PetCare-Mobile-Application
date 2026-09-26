import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(clinicEditorControllerProvider).isLoading;
    final clinics = ref.watch(clinicsProvider).value ?? const <Clinic>[];
    final clinicValue = clinics.any((c) => c.id == _clinicId) ? _clinicId : null;
    const gap = SizedBox(height: 16);

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
                validator: (v) {
                  final name = v?.replaceFirst(RegExp(r'^Dr\.?\s*$'), '');
                  return Validators.required(name, field: 'Name');
                },
                decoration: const InputDecoration(labelText: 'Name *', prefixIcon: Icon(Icons.person_outline)),
              ),
              gap,
              DropdownButtonFormField<String?>(
                initialValue: clinicValue,
                isExpanded: true,
                onChanged: (v) => setState(() => _clinicId = v),
                decoration: const InputDecoration(
                  labelText: 'Clinic',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final c in clinics)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
              gap,
              TextFormField(
                controller: _specialization,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  hintText: 'e.g. General Veterinary Medicine',
                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                ),
              ),
              gap,
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.call_outlined)),
              ),
              gap,
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.email(v),
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              gap,
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : _save,
                child: busy
                    ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(_isEditing ? 'Save Changes' : 'Save Veterinarian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
