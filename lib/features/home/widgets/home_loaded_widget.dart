import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/home/cubit/home_cubit.dart';
import 'package:incasa_app/features/home/cubit/home_state.dart';
import 'package:incasa_app/features/home/widgets/home_product_card_widget.dart';
import 'package:incasa_app/features/home/widgets/neighbors_carousel_widget.dart';

/// Conteúdo do Início carregado (tela 01 do design handoff)
class HomeLoadedWidget extends StatelessWidget {
  final HomeState state;

  const HomeLoadedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Pill de localização + sino
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      state.neighborhoodName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Barra de busca — filtra os produtos da seção "Perto de você"
        TextField(
          onChanged: (value) => sl<HomeCubit>().setSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Buscar comida, artesanato, serviços…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 20),
        // Vizinhos vendendo hoje
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vizinhos vendendo hoje',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('ver todos')),
          ],
        ),
        const SizedBox(height: 4),
        NeighborsCarouselWidget(neighbors: state.neighbors),
        const SizedBox(height: 20),
        // Perto de você + toggle segmentado
        Text(
          'Perto de você',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<HomeViewMode>(
          segments: const [
            ButtonSegment(
              value: HomeViewMode.produtos,
              label: Text('Produtos'),
            ),
            ButtonSegment(
              value: HomeViewMode.vizinhos,
              label: Text('Vizinhos'),
            ),
          ],
          selected: {state.viewMode},
          onSelectionChanged: (selection) =>
              sl<HomeCubit>().toggleViewMode(selection.first),
        ),
        const SizedBox(height: 14),
        if (state.viewMode == HomeViewMode.produtos) ...[
          if (state.visibleProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Nada encontrado para "${state.searchQuery.trim()}"',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...state.visibleProducts.map(
              (product) => HomeProductCardWidget(
                product: product,
                isFavorite: state.favoriteIds.contains(product.id),
              ),
            ),
        ] else
          ...state.neighbors.map(
            (neighbor) => NeumorphicSurface(
              margin: const EdgeInsets.only(bottom: 10),
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: DesignAvatarWidget(
                  name: neighbor.name,
                  size: 40,
                  withRing: true,
                ),
                title: Text(neighbor.name),
                subtitle: Text('${neighbor.distanceLabel} de você'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
      ],
    );
  }
}
