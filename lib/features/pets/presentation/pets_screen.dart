import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import 'pet_providers.dart';
import 'widgets/pet_card.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final hasPets = pets.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My Pets')),
      floatingActionButton: hasPets
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.petAdd),
              icon: const Icon(Icons.add),
              label: const Text('Add Pet'),
            )
          : null,
      body: pets.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load your pets.',
          onRetry: () => ref.invalidate(petsProvider),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return EmptyState(
              icon: Icons.pets,
              title: 'No pets yet',
              message: 'Add your first pet to start tracking their health.',
              action: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => context.push(AppRoutes.petAdd),
                icon: const Icon(Icons.add),
                label: const Text('Add Pet'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              8,
              AppConstants.pagePadding,
              96, // clear the FAB
            ),
            itemCount: pets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final pet = pets[i];
              return PetCard(
                key: ValueKey(pet.id),
                pet: pet,
                onTap: () => context.go(AppRoutes.petDetails(pet.id)),
              );
            },
          );
        },
      ),
    );
  }
}
