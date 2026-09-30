import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'grid_node_widget.dart';
import 'no_gesto_wrapper.dart';

/// Renderiza um `LinhaNode` (carrossel horizontal) — ai/EDITAR_LOJA_VIEW.md
/// §4.5. Em modo de edição, os filhos usam `ReorderableListView` (widget do
/// próprio Flutter) para long-press + arrasto + auto-scroll na reordenação
/// (§6.1), sem exigir nenhum `StatefulWidget` autoral.
class LinhaNodeWidget extends StatelessWidget {
  final LinhaNode node;
  final double unidadeMedida;
  final bool modoEdicaoAtivo;
  final double faseWiggle;
  final List<Product> produtosDisponiveis;
  final EditarLojaCubit cubit;

  const LinhaNodeWidget({
    super.key,
    required this.node,
    required this.unidadeMedida,
    required this.modoEdicaoAtivo,
    required this.faseWiggle,
    required this.produtosDisponiveis,
    required this.cubit,
  });

  int get _itensVisiveisEstimados {
    var largura = 0;
    var count = 0;
    for (final filho in node.children) {
      if (largura + filho.w > node.w) break;
      largura += filho.w;
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final itensExtras = node.children.length - _itensVisiveisEstimados;

    return NoGestoWrapper(
      nodeId: node.id,
      modoEdicaoAtivo: modoEdicaoAtivo,
      faseWiggle: faseWiggle,
      cubit: cubit,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration:
                neumorphicDecoration(
                  context,
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  depth: 2,
                ).copyWith(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
            child: _construirConteudo(),
          ),
          if (itensExtras > 0)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$itensExtras',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          if (modoEdicaoAtivo)
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => cubit.removerNo(node.id),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirChild(GridNode filho) {
    return SizedBox(
      key: ValueKey(filho.id),
      width: filho.w * unidadeMedida,
      height: filho.h * unidadeMedida,
      child: GridNodeWidget(
        node: filho,
        unidadeMedida: unidadeMedida,
        modoEdicaoAtivo: modoEdicaoAtivo,
        faseWiggle: faseWiggle,
        produtosDisponiveis: produtosDisponiveis,
        cubit: cubit,
      ),
    );
  }

  Widget _construirConteudo() {
    if (!modoEdicaoAtivo) {
      return ListView(
        scrollDirection: Axis.horizontal,
        children: node.children.map(_construirChild).toList(),
      );
    }

    return ReorderableListView(
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: false,
      // `onReorderItem` já entrega `newIndex` ajustado para a remoção do
      // item em `oldIndex` (diferente do `onReorder` legado).
      onReorderItem: (oldIndex, newIndex) {
        cubit.reordenarItemNaLinha(node.id, oldIndex, newIndex);
      },
      children: node.children.map((filho) {
        return ReorderableDragStartListener(
          key: ValueKey(filho.id),
          index: node.children.indexOf(filho),
          child: _construirChild(filho),
        );
      }).toList(),
    );
  }
}
