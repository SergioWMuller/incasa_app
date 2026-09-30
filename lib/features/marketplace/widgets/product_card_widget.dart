import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';

/// Widget para exibir um produto em forma de Card
class ProductCardWidget extends StatelessWidget {
  final Product product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return NeumorphicSurface(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 60,
              height: 60,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return Text(
              'R\$ ${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeState.color.color,
                fontSize: 16,
              ),
            );
          },
        ),
      ),
    );
  }
}
