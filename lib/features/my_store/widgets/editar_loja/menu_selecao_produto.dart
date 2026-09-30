import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/core/utils/id_generator.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';

/// Abre o menu central de seleção de produto do botão "Produto" da
/// BottomBar (ai/EDITAR_LOJA_VIEW.md §6.4). Cada item mostra a foto e uma
/// única palavra do nome do produto.
Future<void> abrirMenuSelecaoProduto(
  BuildContext context,
  EditarLojaCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => MenuSelecaoProduto(cubit: cubit),
  );
}

class MenuSelecaoProduto extends StatelessWidget {
  final EditarLojaCubit cubit;

  const MenuSelecaoProduto({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final produtos = cubit.state.produtosDisponiveis;

    if (produtos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Nenhum produto cadastrado ainda.')),
      );
    }

    return SafeArea(
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];
          return _ItemMenuProduto(
            produto: produto,
            onTap: () {
              cubit.iniciarPosicionamentoDeNovoNo(
                ItemNode(id: gerarIdUnico(), x: 0, y: 0, productId: produto.id),
              );
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

class _ItemMenuProduto extends StatelessWidget {
  final Product produto;
  final VoidCallback onTap;

  const _ItemMenuProduto({required this.produto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primeiraPalavra = produto.name.trim().split(RegExp(r'\s+')).first;

    return NeumorphicSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                produto.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            primeiraPalavra,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
