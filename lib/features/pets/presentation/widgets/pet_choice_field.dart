import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/pet_providers.dart';
import 'pet_avatar.dart';

/// Required pet choice shown as a row of tappable avatars.
class PetChoiceField extends ConsumerWidget {
  const PetChoiceField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider).value ?? const [];
    final theme = Theme.of(context);

    return FormField<String>(
      // Rebuild the field when the chosen pet changes from outside.
      key: ValueKey(value),
      initialValue: value,
      validator: (v) => v == null || !pets.any((p) => p.id == v) ? 'Choose a pet' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final pet = pets[i];
                final selected = pet.id == field.value;
                final dim = !enabled && !selected;
                return Opacity(
                  opacity: dim ? 0.4 : 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: enabled
                        ? () {
                            field.didChange(pet.id);
                            onChanged(pet.id);
                          }
                        : null,
                    child: SizedBox(
                      width: 76,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: selected ? AppColors.brandGradient : null,
                              color: selected ? null : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.cardTheme.color ?? theme.colorScheme.surface,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  PetAvatar.fromPet(pet, radius: 28),
                                  if (selected)
                                    Positioned(
                                      right: -4,
                                      bottom: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                              color: selected ? theme.colorScheme.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(field.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
            ),
        ],
      ),
    );
  }
}
