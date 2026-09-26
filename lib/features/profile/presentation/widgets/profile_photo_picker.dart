import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../pets/domain/entities/photo_change.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import 'profile_widgets.dart';

/// Avatar with a camera badge to take, choose or remove a profile photo.
/// Reports changes through [onChanged]; nothing is uploaded here.
class ProfilePhotoPicker extends ConsumerWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.initials,
    required this.existingUrl,
    required this.change,
    required this.onChanged,
  });

  final String initials;
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
      final file = await ref.read(imagePickerProvider).pickImage(
            source: source,
            maxWidth: 720,
            maxHeight: 720,
            imageQuality: 80,
          );
      if (file == null) return;
      onChanged(PhotoReplaced(await file.readAsBytes()));
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final what = source == ImageSource.camera ? 'camera' : 'photo';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code.contains('denied')
            ? 'Permission denied. Enable $what access in Settings.'
            : 'Could not open the ${source == ImageSource.camera ? 'camera' : 'gallery'}.'),
      ));
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(sheet);
                _pick(context, ref, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheet);
                _pick(context, ref, ImageSource.gallery);
              },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline, color: error),
                title: Text('Remove photo', style: TextStyle(color: error)),
                onTap: () {
                  Navigator.pop(sheet);
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
      PhotoReplaced(:final bytes) => CircleAvatar(radius: _radius, backgroundImage: MemoryImage(bytes)),
      PhotoRemoved() => ProfileAvatar(initials: initials, radius: _radius),
      PhotoUnchanged() => ProfileAvatar(initials: initials, photoUrl: existingUrl, radius: _radius),
    };

    return Center(
      child: Semantics(
        button: true,
        label: _hasPhoto ? 'Change profile photo' : 'Add profile photo',
        child: GestureDetector(
          onTap: () => _showOptions(context, ref),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 18, offset: const Offset(0, 6)),
                  ],
                ),
                child: avatar,
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.photo_camera, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
