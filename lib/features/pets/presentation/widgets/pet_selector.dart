import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pet_providers.dart';
import 'pet_avatar.dart';

/// Required dropdown for choosing one of the user's pets.
class PetSelector extends ConsumerWidget {
  const PetSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider).value ?? const [];
    // Guard against a stale id (e.g. pet deleted) so the dropdown doesn't assert.
    final selected = pets.any((p) => p.id == value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      onChanged: enabled ? onChanged : null,
      validator: (v) => v == null ? 'Choose a pet' : null,
      decoration: const InputDecoration(labelText: 'Pet *', prefixIcon: Icon(Icons.pets)),
      items: [
        for (final pet in pets)
          DropdownMenuItem(
            value: pet.id,
            child: Row(
              children: [
                PetAvatar.fromPet(pet, radius: 12),
                const SizedBox(width: 10),
                Text(pet.name),
              ],
            ),
          ),
      ],
    );
  }
}
