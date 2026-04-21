import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_state.dart';
import 'package:incasa_app/features/marketplace/widgets/product_card_widget.dart';

/// Widget que exibe os produtos carregados
class MarketplaceLoadedWidget extends StatelessWidget {
  final MarketplaceLoaded state;

  const MarketplaceLoadedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Campo de busca
        TextField(
          decoration: const InputDecoration(
            hintText: 'Pesquisar produtos',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            context.read<MarketplaceCubit>().searchProducts(query);
          },
        ),
        const SizedBox(height: 16),

        // Categorias
        if (state.categories.isNotEmpty) ...[
          Text('Categorias', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category.title),
                    onSelected: (selected) {
                      // TODO: Filtrar por categoria
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Lista de produtos
        Text(
          'Produtos (${state.products.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...state.products.map((product) => ProductCardWidget(product: product)),
      ],
    );
  }
}
