import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/clinic.dart';
import '../providers/clinic_providers.dart';

extension GeoPointLatLng on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngGeoPoint on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

/// Opens [uri] in the matching app (dialer, mail, browser, maps).
Future<void> openExternal(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No app available for this action.')));
  }
}

Uri phoneUri(String phone) => Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));

Uri emailUri(String email) => Uri(scheme: 'mailto', path: email);

/// Google Maps directions URL (opens the Maps app or browser; no API key).
Uri directionsUri({GeoPoint? location, String? address}) => Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': location != null ? '${location.latitude},${location.longitude}' : address ?? '',
    });

/// A map with OpenStreetMap tiles and attribution. Tiles are omitted when
/// [mapTileUrlProvider] is `null` (tests).
class PetCareMap extends ConsumerWidget {
  const PetCareMap({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.onTap,
    this.controller,
    this.interactive = true,
    this.fitPoints,
  });

  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final void Function(LatLng point)? onTap;
  final MapController? controller;
  final bool interactive;

  /// When given (2+ points), the camera fits them instead of [center].
  final List<LatLng>? fitPoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = ref.watch(mapTileUrlProvider);
    final fit = fitPoints;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        initialCameraFit: fit != null && fit.length > 1
            ? CameraFit.coordinates(
                coordinates: fit,
                padding: const EdgeInsets.all(48),
                maxZoom: 16,
              )
            : null,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
      ),
      children: [
        if (tiles != null)
          TileLayer(urlTemplate: tiles, userAgentPackageName: 'com.petcare.petcare'),
        MarkerLayer(markers: markers),
        if (tiles != null)
          const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}

/// Map pin marker.
Marker pinMarker(
  LatLng point, {
  required Color color,
  IconData icon = Icons.location_on,
  VoidCallback? onTap,
  Key? key,
}) =>
    Marker(
      key: key,
      point: point,
      width: 44,
      height: 44,
      alignment: Alignment.topCenter,
      child: GestureDetector(onTap: onTap, child: Icon(icon, color: color, size: 44)),
    );

/// Round buttons: Call · Email · Website · Directions (only those available).
class ContactActions extends StatelessWidget {
  const ContactActions({super.key, required this.clinic});

  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, Uri)>[
      if (clinic.phone != null) (Icons.call, 'Call', phoneUri(clinic.phone!)),
      if (clinic.email != null) (Icons.email_outlined, 'Email', emailUri(clinic.email!)),
      if (clinic.website != null) (Icons.language, 'Website', Uri.parse(clinic.website!)),
      if (clinic.location != null || clinic.address != null)
        (
          Icons.directions,
          'Directions',
          directionsUri(location: clinic.location, address: clinic.address),
        ),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (icon, label, uri) in actions)
          Column(
            children: [
              IconButton.filledTonal(
                tooltip: label,
                onPressed: () => openExternal(context, uri),
                icon: Icon(icon, color: scheme.primary),
              ),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
      ],
    );
  }
}

class ClinicCard extends StatelessWidget {
  const ClinicCard({super.key, required this.clinic, this.vetCount = 0, this.onTap});

  final Clinic clinic;
  final int vetCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.local_hospital, color: theme.colorScheme.primary),
        ),
        title: Row(
          children: [
            Flexible(child: Text(clinic.name, overflow: TextOverflow.ellipsis)),
            if (clinic.isFavorite) ...[
              const SizedBox(width: 6),
              Icon(Icons.star, size: 18, color: Colors.amber.shade600, semanticLabel: 'Favourite'),
            ],
          ],
        ),
        subtitle: Text(
          [
            ?clinic.address,
            if (vetCount > 0) '$vetCount vet${vetCount == 1 ? '' : 's'}',
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: muted,
        ),
        trailing: clinic.phone == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                tooltip: 'Call ${clinic.name}',
                icon: const Icon(Icons.call_outlined),
                onPressed: () => openExternal(context, phoneUri(clinic.phone!)),
              ),
      ),
    );
  }
}

class VetTile extends StatelessWidget {
  const VetTile({super.key, required this.vet, this.clinicName, this.onTap});

  final Veterinarian vet;
  final String? clinicName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = vet.name
        .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(initials.isEmpty ? '?' : initials)),
      title: Text(vet.name),
      subtitle: Text([?vet.specialization, ?clinicName].join(' · ')),
      trailing: vet.phone == null
          ? null
          : IconButton(
              tooltip: 'Call ${vet.name}',
              icon: const Icon(Icons.call_outlined),
              onPressed: () => openExternal(context, phoneUri(vet.phone!)),
            ),
    );
  }
}
