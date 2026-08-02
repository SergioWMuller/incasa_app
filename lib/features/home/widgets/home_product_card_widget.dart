import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/core/widgets/design/design_thumb_widget.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/features/home/cubit/home_cubit.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_cubit.dart';
import 'package:incasa_app/features/product_detail/view/product_detail_view.dart';

/// Card de produto do feed (tela 01 do design handoff)
class HomeProductCardWidget extends StatelessWidget {
  final HomeProduct product;
  final bool isFavorite;

  const HomeProductCardWidget({
    super.key,
    required this.product,
    required this.isFavorite,
  });

  void _openProduct(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ProductDetailCubit>()..load(product.id),
          child: const ProductDetailView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => _openProduct(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                DesignThumbWidget(
                  label: product.thumbLabel,
                  height: 150,
                  width: double.infinity,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: theme.colorScheme.surface,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          sl<HomeCubit>().toggleFavorite(product.id),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DesignAvatarWidget(name: product.sellerName, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${product.sellerName} · ${product.distanceLabel}',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        DesignFormat.rating(product.rating),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DesignFormat.price(product.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Chip(
                        label: Text(product.category),
                        labelStyle: theme.textTheme.labelSmall,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
