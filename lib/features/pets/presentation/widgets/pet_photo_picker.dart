import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/pet.dart';
import '../pet_editor_controller.dart';
import '../pet_providers.dart';
import 'pet_avatar.dart';

/// Tappable avatar that lets the user take, choose, replace or remove a
/// photo. Reports changes through [onChanged]; nothing is uploaded here.
class PetPhotoPicker extends ConsumerWidget {
  const PetPhotoPicker({
    super.key,
    required this.species,
    required this.existingUrl,
    required this.change,
    required this.onChanged,
  });

  final PetSpecies species;
  final String? existingUrl;
  final PhotoChange change;
  final ValueChanged<PhotoChange> onChanged;

  static const _radius = 56.0;

  bool get _hasPhoto => switch (change) {
        PhotoReplaced() => true,
        PhotoRemoved() => false,
        PhotoUnchanged() => existingUrl != null,
      };

  Future<void> _pick(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      // Downscale + recompress on pick; keeps uploads small (~100–300 KB).
      final file = await ref.read(imagePickerProvider).pickImage(
            source: source,
            maxWidth: 1080,
            maxHeight: 1080,
            imageQuality: 80,
          );
      if (file == null) return;
      onChanged(PhotoReplaced(await file.readAsBytes()));
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final denied = e.code.contains('denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(denied
            ? 'Permission denied. Enable ${source == ImageSource.camera ? 'camera' : 'photo'} access in Settings.'
            : 'Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}.'),
      ));
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ref, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ref, ImageSource.gallery);
              },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Remove photo',
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onChanged(const PhotoRemoved());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final Widget avatar = switch (change) {
      PhotoReplaced(:final bytes) => _MemoryAvatar(bytes: bytes, radius: _radius),
      PhotoRemoved() => PetAvatar(species: species, radius: _radius),
      PhotoUnchanged() =>
        PetAvatar(species: species, photoUrl: existingUrl, radius: _radius),
    };

    return Center(
      child: Semantics(
        button: true,
        label: _hasPhoto ? 'Change pet photo' : 'Add pet photo',
        child: GestureDetector(
          onTap: () => _showOptions(context, ref),
          child: Stack(
            children: [
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.camera_alt, size: 18, color: scheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryAvatar extends StatelessWidget {
  const _MemoryAvatar({required this.bytes, required this.radius});

  final Uint8List bytes;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.memory(bytes, width: radius * 2, height: radius * 2, fit: BoxFit.cover),
    );
  }
}
