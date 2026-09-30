import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';

/// Card de produto da vitrine padrão de "Minha Loja" — grid 2 colunas,
/// imagem + nome + preço + selo de disponibilidade. StatelessWidget puro.
class MyStoreProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const MyStoreProductGridCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return NeumorphicSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: _DisponibilidadeBadge(product: product),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DesignFormat.price(product.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisponibilidadeBadge extends StatelessWidget {
  final Product product;

  const _DisponibilidadeBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (product) {
      Product(disponivelVenda: false) => ('Indisponível', Colors.grey.shade700),
      Product(prontaEntrega: true) => ('Pronta entrega', Colors.green.shade700),
      Product(aceitaEncomenda: true) => (
        'Sob encomenda',
        Colors.orange.shade700,
      ),
      _ => (null, Colors.transparent),
    };

    if (label == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.94),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
