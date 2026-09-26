import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/emergency_profile.dart';
import '../controllers/emergency_controller.dart';
import '../providers/emergency_providers.dart';

/// Owner view: set up the pet's emergency profile, choose what's public,
/// and get the QR code.
class EmergencyProfileScreen extends ConsumerWidget {
  const EmergencyProfileScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider(petId)).value;
    final settings = ref.watch(emergencyProfileProvider(petId));
    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Emergency profile'),
      body: pet == null
          ? const LoadingView()
          : settings.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(
                message: 'Could not load the emergency profile.',
                onRetry: () => ref.invalidate(emergencyProfileProvider(petId)),
              ),
              data: (s) => s == null ? _Setup(pet: pet) : _Manage(pet: pet, settings: s),
            ),
    );
  }
}

void _showError(BuildContext context, WidgetRef ref) {
  final error = ref.read(emergencyControllerProvider).error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error is Failure ? error.message : 'Something went wrong.')),
  );
}

class _Setup extends ConsumerStatefulWidget {
  const _Setup({required this.pet});

  final Pet pet;

  @override
  ConsumerState<_Setup> createState() => _SetupState();
}

class _SetupState extends ConsumerState<_Setup> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(authStateProvider).value?.displayName);
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(emergencyControllerProvider.notifier)
        .create(widget.pet, contactPhone: _phone.text.trim(), contactName: _name.text.trim());
    if (!ok && mounted) _showError(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = ref.watch(emergencyControllerProvider).isLoading;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.qr_code_2, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Help ${widget.pet.name} get home',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Create a QR tag for ${widget.pet.name}’s collar. Anyone who scans it sees an '
            'emergency page with your contact details — no app needed. You choose '
            'exactly what is shown.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Contact name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'A phone number is required' : null,
            decoration: const InputDecoration(
              labelText: 'Emergency phone *',
              prefixIcon: Icon(Icons.call_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: busy ? null : _create,
            icon: const Icon(Icons.qr_code),
            label: const Text('Create QR Pet ID'),
          ),
        ],
      ),
    );
  }
}

class _Manage extends ConsumerStatefulWidget {
  const _Manage({required this.pet, required this.settings});

  final Pet pet;
  final EmergencyProfile settings;

  @override
  ConsumerState<_Manage> createState() => _ManageState();
}

class _ManageState extends ConsumerState<_Manage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.settings.contactName);
  late final _phone = TextEditingController(text: widget.settings.contactPhone);
  late final _warnings = TextEditingController(text: widget.settings.medicalWarnings);
  late final _message = TextEditingController(text: widget.settings.message);
  late var _draft = widget.settings;

  @override
  void dispose() {
    for (final c in [_name, _phone, _warnings, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  EmergencyProfile get _current => _draft.copyWith(
        contactName: _name.text,
        contactPhone: _phone.text,
        medicalWarnings: _warnings.text,
        message: _message.text,
      );

  Future<void> _save({EmergencyProfile? settings, String? successMessage}) async {
    final ok = await ref
        .read(emergencyControllerProvider.notifier)
        .save(widget.pet, settings ?? _current);
    if (!mounted) return;
    if (!ok) return _showError(context, ref);
    if (successMessage != null) await showSuccessDialog(context, title: successMessage);
  }

  Future<void> _toggleEnabled(bool enabled) async {
    setState(() => _draft = _draft.copyWith(enabled: enabled));
    await _save(
      settings: _current,
      successMessage: enabled ? 'Public profile is live' : 'Public profile turned off',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = ref.watch(emergencyControllerProvider).isLoading;
    final url = '${ref.watch(publicProfileBaseUrlProvider)}${_draft.publicId}';

    SwitchListTile toggle(String title, String? subtitle, bool value,
            EmergencyProfile Function(bool) update, {bool available = true}) =>
        SwitchListTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle),
          value: value && available,
          onChanged: available ? (v) => setState(() => _draft = update(v)) : null,
        );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (busy) const LinearProgressIndicator(),
          Card(
            child: SwitchListTile(
              secondary: Icon(_draft.enabled ? Icons.public : Icons.public_off),
              title: Text(_draft.enabled ? 'Public profile is on' : 'Public profile is off'),
              subtitle: Text(_draft.enabled
                  ? 'Anyone scanning the QR code can see this page'
                  : 'Scanning the QR shows “profile not available”. The code stays the same.'),
              value: _draft.enabled,
              onChanged: busy ? null : _toggleEnabled,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('${widget.pet.species.emoji} ${widget.pet.name.toUpperCase()}',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  // White background so the code scans in dark mode too.
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: url,
                      size: 200,
                      semanticsLabel: 'QR code for ${widget.pet.name}’s emergency profile',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(_draft.publicId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      )),
                  Text('PetCare ID', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied')),
                            );
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Copy link'),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                        onPressed: () => SharePlus.instance.share(ShareParams(
                          text: '${widget.pet.name}’s PetCare emergency profile: $url',
                          subject: '${widget.pet.name} — PetCare ID ${_draft.publicId}',
                        )),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                        onPressed: () => context.push(AppRoutes.publicProfile(_draft.publicId)),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Preview'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('What’s shown publicly', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Name and species are always shown.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                toggle('Photo', widget.pet.photoUrl == null ? 'No photo on the pet profile' : null,
                    _draft.showPhoto, (v) => _draft.copyWith(showPhoto: v),
                    available: widget.pet.photoUrl != null),
                toggle('Breed', widget.pet.breed, _draft.showBreed, (v) => _draft.copyWith(showBreed: v),
                    available: widget.pet.breed != null),
                toggle(
                  'Microchip ID',
                  widget.pet.microchipId ?? 'No microchip ID on the pet profile',
                  _draft.showMicrochip,
                  (v) => _draft.copyWith(showMicrochip: v),
                  available: widget.pet.microchipId != null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Emergency contact', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Contact name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Emergency phone *', prefixIcon: Icon(Icons.call_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _warnings,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Medical warnings',
              hintText: 'e.g. Diabetic — needs insulin twice daily. Allergic to penicillin.',
              prefixIcon: Icon(Icons.warning_amber_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _message,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Message to the finder',
              hintText: 'e.g. Friendly but shy. Please call me — reward offered!',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : () => _save(successMessage: 'Emergency profile updated'),
            child: const Text('Save & Publish'),
          ),
        ],
      ),
    );
  }
}
