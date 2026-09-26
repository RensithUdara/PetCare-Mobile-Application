import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/emergency_profile.dart';
import '../providers/emergency_providers.dart';

/// What a finder sees after scanning a pet's QR code (in-app version of
/// the hosted `public/p.html`). Works without signing in.
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, required this.publicId});

  final String publicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('PetCare Emergency Profile')),
      body: ref.watch(publicProfileProvider(publicId)).when(
            loading: () => const LoadingView(),
            error: (_, _) => ErrorView(
              message: 'Could not load this profile. Check your connection.',
              onRetry: () => ref.invalidate(publicProfileProvider(publicId)),
            ),
            data: (p) => p == null
                ? EmptyState(
                    icon: Icons.pets,
                    title: 'Profile not available',
                    message: 'The owner of $publicId has turned this profile off, or the code is not valid.',
                  )
                : _Profile(profile: p),
          ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.profile});

  final PublicPetProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final species = PetSpecies.values.asNameMap()[profile.species] ?? PetSpecies.other;
    final phone = profile.contactPhone;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: scheme.primaryContainer,
                  foregroundImage:
                      profile.photoUrl == null ? null : CachedNetworkImageProvider(profile.photoUrl!),
                  child: Text(species.emoji, style: const TextStyle(fontSize: 52)),
                ),
              ),
              const SizedBox(height: 14),
              Text(profile.petName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
              Text([profile.breed ?? species.label].join(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('PetCare ID ${profile.publicId}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'If you found ${profile.petName}, please contact the owner. Thank you for helping!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
        ),
        if (phone != null) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: FeatureAccent.vaccinations.color,
              shadowColor: FeatureAccent.vaccinations.color.withValues(alpha: 0.5),
              minimumSize: const Size.fromHeight(60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''))),
            icon: const Icon(Icons.call),
            label: Text(profile.contactName == null ? 'Call owner' : 'Call ${profile.contactName}'),
          ),
          const SizedBox(height: 4),
          Text(phone, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
        if (profile.medicalWarnings != null) ...[
          const SizedBox(height: 20),
          Card(
            color: scheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: scheme.onErrorContainer),
              title: Text('Medical warnings',
                  style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700)),
              subtitle: Text(profile.medicalWarnings!, style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ),
        ],
        if (profile.message != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('From the owner'),
              subtitle: Text(profile.message!),
            ),
          ),
        ],
        if (profile.microchipId != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Microchip ID'),
              subtitle: SelectableText(profile.microchipId!),
            ),
          ),
        ],
            ],
          ),
        ),
      ],
    );
  }
}
