import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/pet.dart';

/// Circular pet photo with caching, falling back to the species emoji.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.species,
    this.photoUrl,
    this.radius = 28,
  });

  PetAvatar.fromPet(Pet pet, {Key? key, double radius = 28})
      : this(key: key, species: pet.species, photoUrl: pet.photoUrl, radius: radius);

  final PetSpecies species;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = radius * 2;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: scheme.primaryContainer,
      child: Text(species.emoji, style: TextStyle(fontSize: radius * 0.9)),
    );

    return ClipOval(
      child: photoUrl == null
          ? fallback
          : CachedNetworkImage(
              imageUrl: photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Decode at display size instead of full resolution.
              memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
