import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/core/widgets/design/design_thumb_widget.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_cubit.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_state.dart';

/// Conteúdo da Loja do vendedor (tela 06 do design handoff)
class SellerStoreLoadedWidget extends StatelessWidget {
  final SellerStoreState state;

  const SellerStoreLoadedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = state.store!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header: avatar + nome + rating + seguir
        Row(
          children: [
            DesignAvatarWidget(name: store.name, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '★ ${DesignFormat.rating(store.rating)} · '
                    '${store.distanceLabel} · ${store.salesCount} vendas',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            state.isFollowing
                ? FilledButton.tonal(
                    onPressed: () =>
                        context.read<SellerStoreCubit>().toggleFollow(),
                    child: const Text('Seguindo'),
                  )
                : OutlinedButton(
                    onPressed: () =>
                        context.read<SellerStoreCubit>().toggleFollow(),
                    child: const Text('Seguir'),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        Text(store.bio, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        // Destaque de hoje
        Row(
          children: [
            Text(
              'Destaque de hoje',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: const Text('novo'),
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
              backgroundColor: theme.colorScheme.tertiaryContainer,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(height: 10),
        NeumorphicSurface(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesignThumbWidget(
                label: store.highlight.thumbLabel,
                height: 140,
                width: double.infinity,
              ),
              ListTile(
                title: Text(store.highlight.name),
                subtitle: const Text('Sob encomenda · serve 8'),
                trailing: Text(
                  DesignFormat.price(store.highlight.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Mais da loja
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mais de ${store.name.split(' ').last}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('ver tudo')),
          ],
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: store.moreProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = store.moreProducts[index];
              return SizedBox(
                width: 118,
                child: NeumorphicSurface(
                  margin: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DesignThumbWidget(
                        label: product.thumbLabel,
                        height: 70,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DesignFormat.price(product.price),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
