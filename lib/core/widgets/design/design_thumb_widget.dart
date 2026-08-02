import 'package:flutter/material.dart';

/// Placeholder colorido de imagem (o handoff não traz fotos reais).
class DesignThumbWidget extends StatelessWidget {
  final String label;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const DesignThumbWidget({
    super.key,
    required this.label,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Cor derivada do label só para variar os placeholders entre si
    final containers = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    final onContainers = [
      colorScheme.onPrimaryContainer,
      colorScheme.onSecondaryContainer,
      colorScheme.onTertiaryContainer,
    ];
    final index = label.hashCode.abs() % containers.length;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: containers[index],
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: onContainers[index]),
      ),
    );
  }
}
