import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
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

/// A map with OpenStreetMap tiles, modern pins, zoom / recenter controls and
/// a compact attribution button. Tiles are omitted when [mapTileUrlProvider]
/// is `null` (tests).
class PetCareMap extends ConsumerStatefulWidget {
  const PetCareMap({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.onTap,
    this.controller,
    this.interactive = true,
    this.fitPoints,
    this.showControls,
  });

  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final void Function(LatLng point)? onTap;
  final MapController? controller;
  final bool interactive;

  /// When given (2+ points), the camera fits them instead of [center].
  final List<LatLng>? fitPoints;

  /// Zoom and recenter buttons; defaults to [interactive].
  final bool? showControls;

  @override
  ConsumerState<PetCareMap> createState() => _PetCareMapState();
}

class _PetCareMapState extends ConsumerState<PetCareMap> {
  late final MapController _own = MapController();
  MapController get _map => widget.controller ?? _own;

  bool get _fits => (widget.fitPoints?.length ?? 0) > 1;

  CameraFit get _fit => CameraFit.coordinates(
        coordinates: widget.fitPoints!,
        padding: const EdgeInsets.all(56),
        maxZoom: 16,
      );

  void _zoomBy(double delta) {
    final camera = _map.camera;
    _map.move(camera.center, (camera.zoom + delta).clamp(3, 19));
  }

  void _recenter() => _fits ? _map.fitCamera(_fit) : _map.move(widget.center, widget.zoom);

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(mapTileUrlProvider);
    final controls = widget.showControls ?? widget.interactive;
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        initialCameraFit: _fits ? _fit : null,
        backgroundColor: const Color(0xFFE8EEF3),
        onTap: widget.onTap == null ? null : (_, point) => widget.onTap!(point),
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
      ),
      children: [
        if (tiles != null)
          TileLayer(
            urlTemplate: tiles,
            userAgentPackageName: 'com.rensithudara.petcare',
            maxNativeZoom: 19,
            tileDisplay: const TileDisplay.fadeIn(),
          ),
        MarkerLayer(markers: widget.markers),
        if (controls)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapButton(icon: Icons.add_rounded, tooltip: 'Zoom in', onTap: () => _zoomBy(1)),
                  const SizedBox(height: 8),
                  _MapButton(icon: Icons.remove_rounded, tooltip: 'Zoom out', onTap: () => _zoomBy(-1)),
                  const SizedBox(height: 8),
                  _MapButton(icon: Icons.center_focus_strong_rounded, tooltip: 'Recenter', onTap: _recenter),
                ],
              ),
            ),
          ),
        // OpenStreetMap's licence requires credit; keep it as a small (i)
        // button that shows it on tap.
        if (tiles != null)
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            showFlutterMapAttribution: false,
            popupBorderRadius: BorderRadius.circular(12),
            openButton: (context, open) => _MapButton(
              icon: Icons.info_outline_rounded,
              tooltip: 'Map data credits',
              onTap: open,
              size: 32,
            ),
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// White rounded map control with a soft shadow.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onTap, this.size = 42});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(size * 0.32),
        child: InkWell(
          borderRadius: BorderRadius.circular(size * 0.32),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: size * 0.52, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

/// Map pin marker: a gradient bubble with an icon and a pointer.
Marker pinMarker(
  LatLng point, {
  required Color color,
  IconData icon = Icons.local_hospital_rounded,
  VoidCallback? onTap,
  Key? key,
}) =>
    Marker(
      key: key,
      point: point,
      width: 48,
      height: 58,
      alignment: Alignment.topCenter,
      child: GestureDetector(onTap: onTap, child: MapPin(color: color, icon: icon)),
    );

class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(color, Colors.black, 0.25)!;
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, deep],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: deep.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        CustomPaint(size: const Size(14, 10), painter: _PointerPainter(deep)),
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

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
        leading: const IconBadge(icon: Icons.local_hospital, accent: FeatureAccent.clinics),
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
