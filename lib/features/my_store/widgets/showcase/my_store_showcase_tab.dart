import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';
import 'my_store_product_grid_card.dart';
import 'my_store_showcase_header.dart';

/// Vitrine padrão de "Minha Loja" (layout automático em grid, sem edição
/// manual de posição/tamanho — ver ai/EDITAR_LOJA_VIEW.md sobre a variante
/// customizável, hoje pausada). StatelessWidget, sem estado próprio: todo
/// dado vem do `MyStoreState` já carregado pelo `MyStoreCubit`.
class MyStoreShowcaseTab extends StatelessWidget {
  final Store store;
  final List<Product> products;

  const MyStoreShowcaseTab({
    super.key,
    required this.store,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products
        .where((product) => product.disponivelVenda)
        .toList(growable: false);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: MyStoreShowcaseHeader(
            store: store,
            productCount: visibleProducts.length,
          ),
        ),
        if (visibleProducts.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    MyStoreProductGridCard(product: visibleProducts[index]),
                childCount: visibleProducts.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicSurface(
            constraints: const BoxConstraints.tightFor(width: 84, height: 84),
            borderRadius: BorderRadius.circular(42),
            child: Icon(
              Icons.storefront_outlined,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('Sua vitrine está vazia', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Cadastre um produto ou serviço na aba "Adicionar" para publicar na vitrine.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
