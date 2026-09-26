import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../providers/emergency_providers.dart';

/// Pet profile row linking to the emergency profile / QR ID.
class PetEmergencyTile extends ConsumerWidget {
  const PetEmergencyTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(emergencyProfileProvider(petId));
    final subtitle = switch (settings.value) {
      _ when settings.isLoading => 'Loading…',
      null => 'Create a QR tag so finders can reach you',
      final s when s.enabled => '${s.publicId} · Public profile on',
      final s => '${s.publicId} · Public profile off',
    };
    return ListTile(
      leading: const Icon(Icons.qr_code_2),
      title: const Text('Emergency profile & QR ID'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.emergency(petId)),
    );
  }
}
