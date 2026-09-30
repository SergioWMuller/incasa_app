import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';

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

    final padding = withRing ? 3.0 : 0.0;
    return NeumorphicSurface(
      constraints: BoxConstraints.tightFor(
        width: size + padding * 2,
        height: size + padding * 2,
      ),
      padding: EdgeInsets.all(padding),
      borderRadius: BorderRadius.circular(size),
      depth: withRing ? 5 : 3,
      child: avatar,
    );
  }
}
