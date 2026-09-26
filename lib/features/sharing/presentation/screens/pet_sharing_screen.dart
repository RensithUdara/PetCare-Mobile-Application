import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/pet_share.dart';
import '../controllers/sharing_controller.dart';
import '../providers/sharing_providers.dart';

/// Lets the owner give vets access to one pet's records (by the vet's
/// doctor code) and take it away again.
class PetSharingScreen extends ConsumerWidget {
  const PetSharingScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(petProvider(petId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => const Scaffold(
            appBar: BrandAppBar.page(title: 'Vet access'),
            body: ErrorView(message: 'Could not load this pet.'),
          ),
          data: (pet) => pet == null
              ? const Scaffold(
                  appBar: BrandAppBar.page(title: 'Vet access'),
                  body: EmptyState(icon: Icons.search_off, title: 'Pet not found'),
                )
              : _SharingBody(pet: pet),
        );
  }
}

class _SharingBody extends ConsumerStatefulWidget {
  const _SharingBody({required this.pet});

  final Pet pet;

  @override
  ConsumerState<_SharingBody> createState() => _SharingBodyState();
}

class _SharingBodyState extends ConsumerState<_SharingBody> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _lookUp() async {
    FocusScope.of(context).unfocus();
    await ref.read(sharingControllerProvider.notifier).lookUp(_code.text);
  }

  Future<void> _share(DoctorProfile doctor) async {
    final pet = widget.pet;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Share ${pet.name} with ${doctor.fullName}?',
      message: 'They’ll see ${pet.name}’s profile and health records, and can add vaccinations, '
          'prescriptions and visit notes. You can remove access at any time.',
      confirmLabel: 'Share',
      icon: Icons.medical_information_outlined,
      accent: FeatureAccent.clinics,
    );
    if (!confirmed || !mounted) return;
    final ok = await ref.read(sharingControllerProvider.notifier).share(pet, doctor);
    if (!ok || !mounted) return;
    _code.clear();
    await showSuccessDialog(
      context,
      title: 'Access granted',
      message: '${doctor.fullName} can now see ${pet.name}’s records.',
    );
  }

  Future<void> _revoke(PetShare share) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove ${share.doctorName}?',
      message: 'They will no longer see ${share.petName}’s records. Records they already added stay.',
      confirmLabel: 'Remove',
      icon: Icons.person_remove_outlined,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final ok = await ref.read(sharingControllerProvider.notifier).revoke(share);
    if (ok && mounted) await showSuccessDialog(context, title: 'Access removed');
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final theme = Theme.of(context);
    final state = ref.watch(sharingControllerProvider);
    final shares = ref.watch(petSharesProvider(pet.id));

    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Vet access'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          GradientHeader(
            floating: true,
            margin: const EdgeInsets.only(top: 16),
            gradient: FeatureAccent.clinics.gradient,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.medical_information_outlined, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share ${pet.name}’s records',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        'Give your vet secure access with their PetCare doctor code.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FormSection(
            title: 'Add a vet',
            icon: Icons.person_add_alt_1_outlined,
            accent: FeatureAccent.clinics,
            subtitle: 'Ask your vet for their doctor code — it looks like DR-7K3M9Q.',
            children: [
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _lookUp(),
                enabled: !state.isBusy,
                decoration: const InputDecoration(
                  labelText: 'Doctor code',
                  hintText: 'DR-7K3M9Q',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              if (state.error != null)
                Text(state.error!.message, style: TextStyle(color: theme.colorScheme.error)),
              if (state.doctor == null)
                FilledButton.icon(
                  onPressed: state.isBusy ? null : _lookUp,
                  icon: state.isBusy
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Icon(Icons.search_rounded),
                  label: const Text('Find vet'),
                )
              else
                _DoctorCard(
                  doctor: state.doctor!,
                  busy: state.isBusy,
                  onShare: () => _share(state.doctor!),
                  onCancel: () => ref.read(sharingControllerProvider.notifier).clear(),
                ),
            ],
          ),
          const SectionTitle(title: 'Vets with access', icon: Icons.verified_user_outlined, accent: FeatureAccent.vaccinations),
          shares.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SoftCard(child: Text('Could not load vet access.')),
            data: (list) => list.isEmpty
                ? SoftCard(
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Only you can see ${pet.name}’s records right now.')),
                      ],
                    ),
                  )
                : SoftCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (final (i, share) in list.indexed) ...[
                          if (i > 0) const Divider(indent: 72, endIndent: 16),
                          ListTile(
                            leading: _Initials(name: share.doctorName),
                            title: Text(share.doctorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text([
                              if (share.clinicName != null) share.clinicName!,
                              if (share.createdAt != null) 'Since ${DateFormat.yMMMd().format(share.createdAt!)}',
                            ].join(' · ')),
                            trailing: IconButton(
                              tooltip: 'Remove access',
                              icon: Icon(Icons.person_remove_outlined, color: theme.colorScheme.error),
                              onPressed: state.isBusy ? null : () => _revoke(share),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          const SectionTitle(title: 'What vets can do', icon: Icons.info_outline, accent: FeatureAccent.appointments),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (icon, text) in [
                  (Icons.visibility_outlined, 'See ${pet.name}’s profile, vaccinations, visits, medications, weight and documents'),
                  (Icons.add_circle_outline, 'Add vaccinations, prescriptions and visit notes — they appear here in your app'),
                  (Icons.block_outlined, 'They can never delete your records'),
                  (Icons.lock_reset_outlined, 'Remove access whenever you like'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(text)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.busy, required this.onShare, required this.onCancel});

  final DoctorProfile doctor;
  final bool busy;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = [doctor.specialization, doctor.clinicName, doctor.city].whereType<String>().join(' · ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FeatureAccent.clinics.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FeatureAccent.clinics.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Initials(name: doctor.fullName, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(doctor.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, size: 18, color: FeatureAccent.clinics.color),
                      ],
                    ),
                    if (details.isNotEmpty) Text(details, style: theme.textTheme.bodySmall),
                    Text(doctor.doctorCode,
                        style: theme.textTheme.labelMedium?.copyWith(color: FeatureAccent.clinics.deep)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                  onPressed: busy ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                  onPressed: busy ? null : onShare,
                  child: busy
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Give access'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: FeatureAccent.clinics.gradient),
      child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36)),
    );
  }
}
