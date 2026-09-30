import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/domain/entities/design/neighbor_seller.dart';

/// Carrossel "Vizinhos vendendo hoje" (tela 01 do design handoff)
class NeighborsCarouselWidget extends StatelessWidget {
  final List<NeighborSeller> neighbors;

  const NeighborsCarouselWidget({super.key, required this.neighbors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: neighbors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final neighbor = neighbors[index];
          return Column(
            children: [
              DesignAvatarWidget(name: neighbor.name, size: 52, withRing: true),
              const SizedBox(height: 4),
              Text(neighbor.name, style: theme.textTheme.labelMedium),
              Text(
                neighbor.distanceLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
