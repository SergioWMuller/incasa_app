import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';

class MyStoreProductCard extends StatelessWidget {
  final Product product;

  const MyStoreProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
      title: Text(product.name),
      subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        // TODO: Navegar para edição do produto
      },
    );
  }
}
