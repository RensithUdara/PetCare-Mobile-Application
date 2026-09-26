import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/domain/entities/photo_change.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/account_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_photo_picker.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userProfileProvider).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: 'Could not load your profile.',
              onRetry: () => ref.invalidate(userProfileProvider),
            ),
          ),
          data: (profile) => profile == null
              ? const Scaffold(body: LoadingView())
              : _EditProfileForm(profile: profile),
        );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _phone = TextEditingController(text: widget.profile.phone ?? '');
  late final _city = TextEditingController(text: widget.profile.city ?? '');
  PhotoChange _photo = const PhotoUnchanged();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await ref.read(accountControllerProvider.notifier).saveProfile(
          widget.profile.copyWith(
            fullName: _name.text,
            phone: () => _phone.text,
            city: () => _city.text,
          ),
          photo: _photo,
        );
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(accountControllerProvider);

    ref.listen(accountControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            GradientHeader(
              floating: true,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  ProfilePhotoPicker(
                    initials: widget.profile.initials,
                    existingUrl: widget.profile.photoUrl,
                    change: _photo,
                    onChanged: (c) => setState(() => _photo = c),
                  ),
                  const SizedBox(height: 12),
                  Text('Tap the photo to change it',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Personal details', icon: Icons.badge_outlined, accent: FeatureAccent.pets),
            SoftCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full name *', prefixIcon: Icon(Icons.person_outline)),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: '+94 77 123 4567',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.phone(v),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _city,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_on_outlined)),
                  ),
                ],
              ),
            ),
            const SectionTitle(title: 'Login', icon: Icons.lock_outline, accent: FeatureAccent.medications),
            SoftCard(
              child: TextFormField(
                initialValue: widget.profile.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                  suffixIcon: Icon(Icons.lock_outline, size: 18),
                  helperText: 'Your email is your login and can’t be changed here.',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: state.isBusy ? null : _save,
            icon: state.isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(state.isBusy ? 'Saving…' : 'Save changes'),
          ),
        ),
      ),
    );
  }
}
