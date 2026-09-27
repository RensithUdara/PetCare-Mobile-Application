import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
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
    Widget page(Widget body) => Scaffold(appBar: const BrandAppBar.page(title: 'Emergency profile'), body: body);
    if (pet == null) return page(const LoadingView());
    return settings.when(
      loading: () => page(const LoadingView()),
      error: (_, _) => page(ErrorView(
        message: 'Could not load the emergency profile.',
        onRetry: () => ref.invalidate(emergencyProfileProvider(petId)),
      )),
      data: (s) => s == null ? _Setup(pet: pet) : _Manage(pet: pet, settings: s),
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
    final pet = widget.pet;
    final white90 = Colors.white.withValues(alpha: 0.9);

    Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: white90))),
            ],
          ),
        );

    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Emergency profile'),
      bottomNavigationBar: FormSaveBar(
        label: 'Create QR Pet ID',
        icon: Icons.qr_code_rounded,
        busy: busy,
        busyLabel: 'Creating…',
        onPressed: _create,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            GradientHeader(
              floating: true,
              margin: const EdgeInsets.only(top: 16),
              gradient: FeatureAccent.emergency.gradient,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Icon(Icons.qr_code_2_rounded, size: 40, color: FeatureAccent.emergency.deep),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Help ${pet.name} get home',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a QR tag for ${pet.name}’s collar. Anyone who scans it sees an emergency page '
                    'with your contact details.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: white90),
                  ),
                  const SizedBox(height: 6),
                  point(Icons.phone_iphone_rounded, 'Works with any phone camera — no app needed'),
                  point(Icons.tune_rounded, 'You choose exactly what is shown'),
                  point(Icons.toggle_off_outlined, 'Turn the page off at any time'),
                ],
              ),
            ),
            FormSection(
              title: 'Emergency contact',
              icon: Icons.contact_phone_outlined,
              accent: FeatureAccent.emergency,
              subtitle: 'Shown to whoever finds ${pet.name}.',
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Contact name', prefixIcon: Icon(Icons.person_outline)),
                ),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _create(),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'A phone number is required' : null,
                  decoration: const InputDecoration(
                    labelText: 'Emergency phone *',
                    hintText: '+94 77 123 4567',
                    prefixIcon: Icon(Icons.call_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final on = _draft.enabled;

    Widget toggle(String title, String? subtitle, bool value, EmergencyProfile Function(bool) update,
            {bool available = true, required IconData icon}) =>
        SwitchListTile(
          secondary: Icon(icon, color: available ? FeatureAccent.emergency.color : theme.disabledColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: subtitle == null ? null : Text(subtitle),
          value: value && available,
          onChanged: available ? (v) => setState(() => _draft = update(v)) : null,
        );

    Widget heroButton(IconData icon, String label, VoidCallback onTap) => Expanded(
          child: Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(height: 4),
                    Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        );

    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Emergency profile'),
      bottomNavigationBar: FormSaveBar(
        label: 'Save & Publish',
        icon: Icons.publish_rounded,
        busy: busy,
        busyLabel: 'Publishing…',
        onPressed: () => _save(successMessage: 'Emergency profile updated'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            // The collar tag: QR code, PetCare ID and quick actions.
            GradientHeader(
              floating: true,
              margin: const EdgeInsets.only(top: 16),
              gradient: FeatureAccent.emergency.gradient,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.pet.species.emoji} ${widget.pet.name.toUpperCase()}',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: on ? Colors.white : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(on ? Icons.public : Icons.public_off,
                                size: 14, color: on ? FeatureAccent.vaccinations.deep : Colors.white),
                            const SizedBox(width: 4),
                            Text(on ? 'Live' : 'Off',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: on ? FeatureAccent.vaccinations.deep : Colors.white,
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // White background so the code scans in dark mode too.
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 18, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Opacity(
                      opacity: on ? 1 : 0.35,
                      child: QrImageView(
                        data: url,
                        size: 190,
                        semanticsLabel: 'QR code for ${widget.pet.name}’s emergency profile',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    _draft.publicId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('PetCare ID', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      heroButton(Icons.link_rounded, 'Copy link', () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                        }
                      }),
                      const SizedBox(width: 10),
                      heroButton(Icons.share_rounded, 'Share', () => SharePlus.instance.share(ShareParams(
                            text: '${widget.pet.name}’s PetCare emergency profile: $url',
                            subject: '${widget.pet.name} — PetCare ID ${_draft.publicId}',
                          ))),
                      const SizedBox(width: 10),
                      heroButton(Icons.visibility_rounded, 'Preview',
                          () => context.push(AppRoutes.publicProfile(_draft.publicId))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                secondary: IconBadge(icon: on ? Icons.public : Icons.public_off, accent: on ? FeatureAccent.vaccinations : FeatureAccent.settings, size: 40),
                title: Text(on ? 'Public profile is on' : 'Public profile is off',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(on
                    ? 'Anyone scanning the QR code can see this page'
                    : 'Scanning the QR shows “profile not available”. The code stays the same.'),
                value: on,
                onChanged: busy ? null : _toggleEnabled,
              ),
            ),
            FormSection(
              title: 'What’s shown publicly',
              icon: Icons.visibility_outlined,
              accent: FeatureAccent.emergency,
              subtitle: 'Name and species are always shown.',
              children: [
                Column(
                  children: [
                    toggle('Photo', widget.pet.photoUrl == null ? 'No photo on the pet profile' : null, _draft.showPhoto,
                        (v) => _draft.copyWith(showPhoto: v),
                        available: widget.pet.photoUrl != null, icon: Icons.photo_outlined),
                    toggle('Breed', widget.pet.breed, _draft.showBreed, (v) => _draft.copyWith(showBreed: v),
                        available: widget.pet.breed != null, icon: Icons.category_outlined),
                    toggle('Microchip ID', widget.pet.microchipId ?? 'No microchip ID on the pet profile',
                        _draft.showMicrochip, (v) => _draft.copyWith(showMicrochip: v),
                        available: widget.pet.microchipId != null, icon: Icons.memory),
                  ],
                ),
              ],
            ),
            FormSection(
              title: 'Emergency contact',
              icon: Icons.contact_phone_outlined,
              accent: FeatureAccent.appointments,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Contact name', prefixIcon: Icon(Icons.person_outline)),
                ),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Emergency phone *', prefixIcon: Icon(Icons.call_outlined)),
                ),
              ],
            ),
            FormSection(
              title: 'For the finder',
              icon: Icons.volunteer_activism_outlined,
              accent: FeatureAccent.documents,
              children: [
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
