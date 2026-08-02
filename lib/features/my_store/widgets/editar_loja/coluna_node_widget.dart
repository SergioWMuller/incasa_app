import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'grid_node_widget.dart';
import 'no_gesto_wrapper.dart';

/// Renderiza um `ColunaNode` (carrossel vertical) — ai/EDITAR_LOJA_VIEW.md
/// §4.6. Não tem scroll interno próprio: a altura já cresce o suficiente
/// para caber os filhos (o scroll vertical é o do Grid pai).
class ColunaNodeWidget extends StatelessWidget {
  final ColunaNode node;
  final double unidadeMedida;
  final bool modoEdicaoAtivo;
  final double faseWiggle;
  final List<Product> produtosDisponiveis;
  final EditarLojaCubit cubit;

  const ColunaNodeWidget({
    super.key,
    required this.node,
    required this.unidadeMedida,
    required this.modoEdicaoAtivo,
    required this.faseWiggle,
    required this.produtosDisponiveis,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: node.children.map((filho) {
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
              }).toList(),
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
}
