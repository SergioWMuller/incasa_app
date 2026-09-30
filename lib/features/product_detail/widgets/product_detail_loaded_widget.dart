import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_avatar_widget.dart';
import 'package:incasa_app/core/widgets/design/design_format.dart';
import 'package:incasa_app/core/widgets/design/design_thumb_widget.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';
import 'package:incasa_app/features/chat/view/chat_conversation_view.dart';
import 'package:incasa_app/features/checkout/view/pix_sheet_widget.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_cubit.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_state.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_cubit.dart';
import 'package:incasa_app/features/seller_store/view/seller_store_view.dart';

/// Conteúdo da tela de Produto (tela 02 do design handoff)
class ProductDetailLoadedWidget extends StatelessWidget {
  final ProductDetailState state;

  const ProductDetailLoadedWidget({super.key, required this.state});

  void _openChat(BuildContext context) {
    sl<ChatCubit>().openThread('thread-bel');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatConversationView()));
  }

  void _openStore(BuildContext context) {
    final sellerId = state.product!.sellerId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<SellerStoreCubit>()..load(sellerId),
          child: const SellerStoreView(),
        ),
      ),
    );
  }

  void _openPixSheet(BuildContext context) {
    PixSheetWidget.show(context, state.product!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = state.product!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Imagem full-bleed com botões sobrepostos
              Stack(
                children: [
                  DesignThumbWidget(
                    label: product.thumbLabel,
                    height: 250,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    child: Material(
                      color: theme.colorScheme.surface,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: Row(
                      children: [
                        Material(
                          color: theme.colorScheme.surface,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              state.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: state.isFavorite
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            onPressed: () => context
                                .read<ProductDetailCubit>()
                                .toggleFavorite(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: theme.colorScheme.surface,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(product.category),
                          labelStyle: theme.textTheme.labelSmall,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.distanceLabel} de você',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DesignFormat.price(product.price),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card do vendedor
                    NeumorphicSurface(
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        leading: DesignAvatarWidget(
                          name: product.sellerName,
                          size: 40,
                        ),
                        title: Text(product.sellerName),
                        subtitle: Text(
                          '★ ${DesignFormat.rating(product.rating)} · '
                          '32 vendas no bairro',
                        ),
                        trailing: TextButton(
                          onPressed: () => _openStore(context),
                          child: const Text('ver loja ›'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Banner de disponibilidade
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.availabilityLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Descrição',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Barra de ações fixa
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openChat(context),
                    child: const Text('Conversar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => _openPixSheet(context),
                    child: Text(
                      'Comprar · ${DesignFormat.price(product.price)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
