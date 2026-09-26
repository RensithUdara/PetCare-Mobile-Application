import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/logic/geo.dart';
import '../controllers/clinic_editor_controller.dart';
import '../providers/clinic_providers.dart';
import '../widgets/clinic_widgets.dart';

const _fallbackCenter = LatLng(6.9271, 79.8612);

/// Saved clinics on a map, plus "Find vets near me" (OpenStreetMap).
class ClinicsMapScreen extends ConsumerStatefulWidget {
  const ClinicsMapScreen({super.key});

  @override
  ConsumerState<ClinicsMapScreen> createState() => _ClinicsMapScreenState();
}

class _ClinicsMapScreenState extends ConsumerState<ClinicsMapScreen> {
  final _map = MapController();
  LatLng? _here;
  List<NearbyClinic>? _nearby;
  bool _searching = false;

  Future<void> _findNearby() async {
    setState(() => _searching = true);
    try {
      final here = await ref.read(getCurrentLocationProvider)();
      final results = await ref.read(searchNearbyClinicsProvider)(here);
      if (!mounted) return;
      setState(() {
        _here = here.toLatLng();
        _nearby = results;
      });
      _map.fitCamera(CameraFit.coordinates(
        coordinates: [_here!, for (final c in results) c.location.toLatLng()],
        padding: const EdgeInsets.all(56),
        maxZoom: 15,
      ));
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No veterinary clinics found within 5 km.'),
        ));
      }
    } on Failure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _showNearby(NearbyClinic c) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => _NearbySheet(clinic: c),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final saved = (ref.watch(clinicsProvider).value ?? const <Clinic>[])
        .where((c) => c.location != null)
        .toList();
    final savedNames = {for (final c in saved) c.name.toLowerCase()};
    final nearby = (_nearby ?? const <NearbyClinic>[])
        .where((c) => !savedNames.contains(c.name.toLowerCase()))
        .toList();

    final markers = [
      for (final c in nearby)
        pinMarker(c.location.toLatLng(),
            color: scheme.tertiary, onTap: () => _showNearby(c), key: ValueKey(c.externalId)),
      for (final c in saved)
        pinMarker(c.location!.toLatLng(),
            color: scheme.primary,
            icon: Icons.local_hospital,
            onTap: () => context.push(AppRoutes.clinicDetails(c.id)),
            key: ValueKey(c.id)),
      if (_here != null)
        Marker(
          point: _here!,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic map')),
      body: Column(
        children: [
          Expanded(
            child: PetCareMap(
              controller: _map,
              center: saved.isNotEmpty ? saved.first.location!.toLatLng() : _fallbackCenter,
              zoom: saved.isEmpty ? 11 : 13,
              fitPoints: [for (final c in saved) c.location!.toLatLng()],
              markers: markers,
            ),
          ),
          if (nearby.isNotEmpty)
            SizedBox(
              height: 190,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: nearby.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = nearby[i];
                  return ListTile(
                    leading: Icon(Icons.location_on, color: scheme.tertiary),
                    title: Text(c.name),
                    subtitle: Text([formatDistance(c.distanceMeters), ?c.address].join(' · ')),
                    onTap: () {
                      _map.move(c.location.toLatLng(), 16);
                      _showNearby(c);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: nearby.isNotEmpty ? 190 : 0),
        child: FloatingActionButton.extended(
          onPressed: _searching ? null : _findNearby,
          icon: _searching
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.near_me_outlined),
          label: const Text('Find vets near me'),
        ),
      ),
    );
  }
}

class _NearbySheet extends ConsumerWidget {
  const _NearbySheet({required this.clinic});

  final NearbyClinic clinic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uid = ref.watch(currentUserIdProvider) ?? '';
    final asClinic = clinic.toClinic(uid);
    final busy = ref.watch(clinicEditorControllerProvider).isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(clinic.name, style: theme.textTheme.titleLarge),
            Text(
              [formatDistance(clinic.distanceMeters), ?clinic.address].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (clinic.openingHours != null) ...[
              const SizedBox(height: 4),
              Text(clinic.openingHours!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            ContactActions(clinic: asClinic),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final id = await ref
                          .read(clinicEditorControllerProvider.notifier)
                          .saveClinic(asClinic);
                      navigator.pop();
                      messenger.showSnackBar(SnackBar(
                        content: Text(id == null
                            ? 'Could not save clinic.'
                            : '${clinic.name} saved to your clinics'),
                      ));
                    },
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save to my clinics'),
            ),
            const SizedBox(height: 8),
            Text(
              'Details from OpenStreetMap may be incomplete — check before visiting.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
