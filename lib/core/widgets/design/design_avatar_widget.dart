import 'package:flutter/material.dart';

/// Avatar circular com inicial; opcionalmente com anel gradiente
/// (carrossel "Vizinhos vendendo hoje" do design handoff).
class DesignAvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final bool withRing;

  const DesignAvatarWidget({
    super.key,
    required this.name,
    this.size = 40,
    this.withRing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size / 2.4,
        ),
      ),
    );

    if (!withRing) return avatar;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorScheme.tertiary, colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: avatar,
      ),
    );
  }
}
