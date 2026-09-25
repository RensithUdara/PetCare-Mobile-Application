import 'package:flutter/material.dart';

import '../../domain/pet.dart';
import '../../domain/pet_age.dart';
import 'pet_avatar.dart';

class PetCard extends StatelessWidget {
  const PetCard({super.key, required this.pet, this.onTap});

  final Pet pet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = petAgeLabel(pet.dateOfBirth, DateTime.now());
    final details = [pet.breedOrSpecies, ?age].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(tag: 'pet-avatar-${pet.id}', child: PetAvatar.fromPet(pet, radius: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (pet.weightKg != null) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text('${formatWeight(pet.weightKg!)} kg'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// "12.5" or "12" (drops a trailing ".0").
String formatWeight(double kg) =>
    kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
