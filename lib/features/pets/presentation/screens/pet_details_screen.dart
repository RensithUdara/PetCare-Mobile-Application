import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/pet.dart';
import '../../domain/logic/pet_age.dart';
import '../../../appointments/presentation/widgets/pet_appointments_tile.dart';
import '../../../medications/presentation/widgets/medication_widgets.dart';
import '../../../vaccinations/presentation/widgets/pet_vaccinations_tile.dart';
import '../controllers/pet_editor_controller.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_card.dart';

class PetDetailsScreen extends ConsumerWidget {
  const PetDetailsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(petProvider(petId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: 'Could not load this pet.',
              onRetry: () => ref.invalidate(petProvider(petId)),
            ),
          ),
          data: (pet) => pet == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.search_off,
                    title: 'Pet not found',
                    message: 'This pet may have been deleted.',
                  ),
                )
              : _PetDetails(pet: pet),
        );
  }
}

enum _MenuAction { edit, delete }

class _PetDetails extends ConsumerWidget {
  const _PetDetails({required this.pet});

  final Pet pet;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pet.name}?'),
        content: const Text(
          'This permanently removes the pet profile, photo and all health records. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final ok = await ref.read(petEditorControllerProvider.notifier).delete(pet.id);
    if (ok) {
      router.go(AppRoutes.pets);
      messenger.showSnackBar(SnackBar(content: Text('${pet.name} deleted')));
    } else {
      final error = ref.read(petEditorControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(content: Text(error?.message ?? 'Could not delete pet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final age = petAgeLabel(pet.dateOfBirth, DateTime.now());
    final deleting = ref.watch(petEditorControllerProvider).isBusy;
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.petEdit(pet.id)),
          ),
          PopupMenuButton<_MenuAction>(
            enabled: !deleting,
            onSelected: (action) => switch (action) {
              _MenuAction.edit => context.push(AppRoutes.petEdit(pet.id)),
              _MenuAction.delete => _delete(context, ref),
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text('Delete',
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          if (deleting) const LinearProgressIndicator(),
          Center(
            child: Hero(
              tag: 'pet-avatar-${pet.id}',
              child: PetAvatar.fromPet(pet, radius: 64),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${pet.name} ${pet.species.emoji}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            pet.breedOrSpecies,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatTile(label: 'Age', value: age ?? '—'),
              const SizedBox(width: 12),
              _StatTile(
                label: 'Weight',
                value: pet.weightKg == null ? '—' : '${formatWeight(pet.weightKg!)} kg',
              ),
              const SizedBox(width: 12),
              _StatTile(label: 'Gender', value: pet.gender.label),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Details',
            rows: [
              ('Species', pet.species.label),
              ('Date of birth',
                  pet.dateOfBirth == null ? null : dateFormat.format(pet.dateOfBirth!)),
              ('Color', pet.color),
              ('Microchip ID', pet.microchipId),
              ('Registration no.', pet.registrationNumber),
            ],
          ),
          if (pet.notes != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(pet.notes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Health records', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                PetVaccinationsTile(petId: pet.id),
                const Divider(height: 1),
                PetAppointmentsTile(petId: pet.id),
                const Divider(height: 1),
                PetMedicationsTile(petId: pet.id),
                const Divider(height: 1),
                const _RecordTile(icon: Icons.description_outlined, title: 'Documents'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = rows.where((r) => r.$2 != null && r.$2!.isNotEmpty).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final (label, value) in visible)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        label,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Text(value!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Entry point to a pet's health records; wired up in later phases.
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: const Text('Coming soon'),
      enabled: false,
    );
  }
}
