import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/clinic.dart';
import '../controllers/clinic_editor_controller.dart';
import '../providers/clinic_providers.dart';
import '../widgets/clinic_widgets.dart';

class ClinicDetailsScreen extends ConsumerWidget {
  const ClinicDetailsScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(clinicProvider(clinicId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: const BrandAppBar.page(title: 'Clinic'),
            body: const ErrorView(message: 'Could not load this clinic.'),
          ),
          data: (c) => c == null
              ? Scaffold(
                  appBar: const BrandAppBar.page(title: 'Clinic'),
                  body: const EmptyState(icon: Icons.search_off, title: 'Clinic not found'),
                )
              : _Details(clinic: c),
        );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.clinic});

  final Clinic clinic;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${clinic.name}?',
      message: 'Veterinarians at this clinic are kept but no longer linked to it.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navContext = Navigator.of(context, rootNavigator: true).context;
    if (await ref.read(clinicEditorControllerProvider.notifier).deleteClinic(clinic.id)) {
      router.pop();
      if (navContext.mounted) await showSuccessDialog(navContext, title: '${clinic.name} deleted');
    } else {
      final error = ref.read(clinicEditorControllerProvider).error;
      messenger.showSnackBar(SnackBar(
        content: Text(error is Failure ? error.message : 'Could not delete clinic.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vets = (ref.watch(vetsProvider).value ?? const <Veterinarian>[])
        .where((v) => v.clinicId == clinic.id)
        .toList();
    final busy = ref.watch(clinicEditorControllerProvider).isLoading;

    final rows = <(IconData, String, String?)>[
      (Icons.place_outlined, 'Address', clinic.address),
      (Icons.schedule, 'Opening hours', clinic.openingHours),
      (Icons.call_outlined, 'Phone', clinic.phone),
      (Icons.email_outlined, 'Email', clinic.email),
      (Icons.language, 'Website', clinic.website),
    ];

    return Scaffold(
      appBar: BrandAppBar.page(
        title: clinic.name,
        actions: [
          IconButton(
            tooltip: clinic.isFavorite ? 'Remove from favourites' : 'Add to favourites',
            icon: Icon(clinic.isFavorite ? Icons.star : Icons.star_border,
                color: clinic.isFavorite ? Colors.amber.shade600 : null),
            onPressed: busy
                ? null
                : () => ref.read(clinicEditorControllerProvider.notifier).toggleFavorite(clinic),
          ),
          PopupMenuButton<String>(
            enabled: !busy,
            onSelected: (v) =>
                v == 'edit' ? context.push(AppRoutes.clinicEdit(clinic.id)) : _delete(context, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (busy) const LinearProgressIndicator(),
          if (clinic.location != null)
            SizedBox(
              height: 180,
              child: PetCareMap(
                center: clinic.location!.toLatLng(),
                zoom: 15,
                interactive: false,
                markers: [
                  pinMarker(clinic.location!.toLatLng(), color: theme.colorScheme.primary),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ContactActions(clinic: clinic),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Card(
              child: Column(
                children: [
                  for (final (icon, label, value) in rows)
                    if (value != null)
                      ListTile(
                        leading: Icon(icon),
                        title: Text(label, style: theme.textTheme.bodySmall),
                        subtitle: Text(value, style: theme.textTheme.bodyLarge),
                      ),
                  if (rows.every((r) => r.$3 == null))
                    const ListTile(title: Text('No contact details yet')),
                ],
              ),
            ),
          ),
          if (clinic.notes != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Card(
                child: ListTile(
                  title: Text('Notes', style: theme.textTheme.titleSmall),
                  subtitle: Text(clinic.notes!),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text('Veterinarians', style: theme.textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Column(
                children: [
                  for (final vet in vets)
                    VetTile(vet: vet, onTap: () => context.push(AppRoutes.vetEdit(vet.id))),
                  ListTile(
                    leading: const Icon(Icons.person_add_alt),
                    title: const Text('Add veterinarian'),
                    onTap: () => context.push(AppRoutes.vetNew(clinicId: clinic.id)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
