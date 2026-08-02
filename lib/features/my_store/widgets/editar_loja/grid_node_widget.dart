import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'coluna_node_widget.dart';
import 'item_node_widget.dart';
import 'linha_node_widget.dart';

/// Despacha um `GridNode` para o widget concreto do seu subtipo. Usado tanto
/// no `GridCanvasWidget` (nível raiz) quanto pelos próprios containers para
/// renderizar seus filhos — evita duplicar o switch por tipo em cada lugar.
class GridNodeWidget extends StatelessWidget {
  final GridNode node;
  final double unidadeMedida;
  final bool modoEdicaoAtivo;
  final double faseWiggle;
  final List<Product> produtosDisponiveis;
  final EditarLojaCubit cubit;

  const GridNodeWidget({
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
    final no = node;
    return switch (no) {
      ItemNode() => ItemNodeWidget(
        node: no,
        unidadeMedida: unidadeMedida,
        modoEdicaoAtivo: modoEdicaoAtivo,
        faseWiggle: faseWiggle,
        produtosDisponiveis: produtosDisponiveis,
        cubit: cubit,
      ),
      ColunaNode() => ColunaNodeWidget(
        node: no,
        unidadeMedida: unidadeMedida,
        modoEdicaoAtivo: modoEdicaoAtivo,
        faseWiggle: faseWiggle,
        produtosDisponiveis: produtosDisponiveis,
        cubit: cubit,
      ),
      LinhaNode() => LinhaNodeWidget(
        node: no,
        unidadeMedida: unidadeMedida,
        modoEdicaoAtivo: modoEdicaoAtivo,
        faseWiggle: faseWiggle,
        produtosDisponiveis: produtosDisponiveis,
        cubit: cubit,
      ),
    };
  }
}
