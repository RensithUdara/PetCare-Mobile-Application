import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/clinic.dart';
import '../controllers/clinic_editor_controller.dart';
import '../providers/clinic_providers.dart';
import '../widgets/clinic_widgets.dart';

/// Default map centre when no location is known (Colombo).
const _fallbackCenter = LatLng(6.9271, 79.8612);

class ClinicFormScreen extends ConsumerWidget {
  const ClinicFormScreen({super.key, this.clinicId});

  final String? clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (clinicId == null) return const _ClinicForm(initial: null);
    return ref.watch(clinicProvider(clinicId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => const Scaffold(body: ErrorView(message: 'Could not load this clinic.')),
          data: (c) => c == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(icon: Icons.search_off, title: 'Clinic not found'),
                )
              : _ClinicForm(initial: c),
        );
  }
}

class _ClinicForm extends ConsumerStatefulWidget {
  const _ClinicForm({required this.initial});

  final Clinic? initial;

  @override
  ConsumerState<_ClinicForm> createState() => _ClinicFormState();
}

class _ClinicFormState extends ConsumerState<_ClinicForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _email = TextEditingController(text: widget.initial?.email);
  late final _website = TextEditingController(text: widget.initial?.website);
  late final _hours = TextEditingController(text: widget.initial?.openingHours);
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late GeoPoint? _location = widget.initial?.location;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _email, _website, _hours, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.of(context).push<GeoPoint>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => LocationPickerScreen(initial: _location),
    ));
    if (picked != null) setState(() => _location = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final base = widget.initial ?? const Clinic(ownerId: '', name: '');
    final id = await ref.read(clinicEditorControllerProvider.notifier).saveClinic(base.copyWith(
          name: _name.text,
          address: _address.text,
          phone: _phone.text,
          email: _email.text,
          website: _website.text,
          openingHours: _hours.text,
          notes: _notes.text,
          location: _location,
        ));
    if (id == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Clinic updated' : 'Clinic saved')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(clinicEditorControllerProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is Failure ? error.message : 'Something went wrong.')),
        );
      }
    });
    final busy = ref.watch(clinicEditorControllerProvider).isLoading;
    final theme = Theme.of(context);
    const gap = SizedBox(height: 16);

    Widget field(TextEditingController c, String label, IconData icon,
            {TextInputType? keyboard, String? Function(String?)? validator, int lines = 1}) =>
        TextFormField(
          controller: c,
          keyboardType: keyboard,
          validator: validator,
          minLines: lines,
          maxLines: lines == 1 ? 1 : lines + 2,
          textCapitalization: keyboard == null ? TextCapitalization.sentences : TextCapitalization.none,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Clinic' : 'Add Clinic')),
      body: AbsorbPointer(
        absorbing: busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              field(_name, 'Clinic name *', Icons.local_hospital_outlined,
                  validator: (v) => Validators.required(v, field: 'Clinic name')),
              gap,
              field(_address, 'Address', Icons.place_outlined, lines: 2),
              gap,
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (_location != null)
                      SizedBox(
                        height: 140,
                        child: PetCareMap(
                          center: _location!.toLatLng(),
                          zoom: 15,
                          interactive: false,
                          markers: [
                            pinMarker(_location!.toLatLng(), color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: Text(_location == null ? 'Set location on map' : 'Change location'),
                      subtitle: const Text('Used for the map and directions'),
                      trailing: _location == null
                          ? const Icon(Icons.chevron_right)
                          : IconButton(
                              tooltip: 'Remove location',
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _location = null),
                            ),
                      onTap: _pickLocation,
                    ),
                  ],
                ),
              ),
              gap,
              field(_phone, 'Phone', Icons.call_outlined, keyboard: TextInputType.phone),
              gap,
              field(_email, 'Email', Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.email(v)),
              gap,
              field(_website, 'Website', Icons.language, keyboard: TextInputType.url),
              gap,
              field(_hours, 'Opening hours', Icons.schedule),
              gap,
              field(_notes, 'Notes', Icons.notes, lines: 2),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : _save,
                child: busy
                    ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(_isEditing ? 'Save Changes' : 'Save Clinic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen map: tap to place the pin, or use the current location.
/// Pops with the chosen [GeoPoint].
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final GeoPoint? initial;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _map = MapController();
  late LatLng? _point = widget.initial?.toLatLng();
  bool _locating = false;

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final here = (await ref.read(getCurrentLocationProvider)()).toLatLng();
      if (!mounted) return;
      setState(() => _point = here);
      _map.move(here, 16);
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic location'),
        actions: [
          TextButton(
            onPressed: _point == null ? null : () => Navigator.pop(context, _point!.toGeoPoint()),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Stack(
        children: [
          PetCareMap(
            controller: _map,
            center: _point ?? _fallbackCenter,
            zoom: _point == null ? 12 : 16,
            onTap: (p) => setState(() => _point = p),
            markers: [if (_point != null) pinMarker(_point!, color: scheme.primary)],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _point == null ? 'Tap the map to place the clinic' : 'Tap again to move the pin',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _locating ? null : _useMyLocation,
        icon: _locating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location),
        label: const Text('Use my location'),
      ),
    );
  }
}
