import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../providers/sharing_providers.dart';

/// Pet profile row linking to vet access (record sharing).
class PetVetAccessTile extends ConsumerWidget {
  const PetVetAccessTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shares = ref.watch(petSharesProvider(petId));
    final subtitle = switch (shares.value) {
      _ when shares.isLoading => 'Loading…',
      null || [] => 'Share records securely with your vet',
      [final only] => '${only.doctorName} has access',
      final list => '${list.first.doctorName} and ${list.length - 1} more have access',
    };
    return ListTile(
      leading: const IconBadge(icon: Icons.medical_information_outlined, accent: FeatureAccent.clinics),
      title: const Text('Vet access'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.petSharing(petId)),
    );
  }
}
