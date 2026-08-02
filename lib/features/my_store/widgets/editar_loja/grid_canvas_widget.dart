import 'package:flutter/material.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_state.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'grid_dots_widget.dart';
import 'grid_node_widget.dart';

/// Grid pai (raiz) da `EditarLojaView` — ai/EDITAR_LOJA_VIEW.md §5. Largura
/// fixa em 6 unidades, altura cresce conforme os blocos, e a tela toda é
/// rolável verticalmente. Posicionamento livre via `Stack` + `Positioned`
/// (não `GridView`, que não suporta sobreposição/reflow).
class GridCanvasWidget extends StatelessWidget {
  final EditarLojaState state;
  final EditarLojaCubit cubit;

  const GridCanvasWidget({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final unidade = state.unidadeMedida;
    if (unidade <= 0 || state.statusCarregamento == StatusCarregamentoLayout.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    var alturaMaxima = 0;
    for (final node in state.nodes) {
      final baixo = node.y + node.h;
      if (baixo > alturaMaxima) alturaMaxima = baixo;
    }
    // Um pouco de folga no final para o usuário soltar blocos além do último.
    final alturaTotalPx = (alturaMaxima + 2) * unidade;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: 6 * unidade,
        height: alturaTotalPx,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GridDotsWidget(
              unidadeMedida: unidade,
              linhas: alturaMaxima + 2,
            ),
            for (final node in state.nodes)
              Positioned(
                left: node.x * unidade,
                top: node.y * unidade,
                width: node.w * unidade,
                height: node.h * unidade,
                child: GridNodeWidget(
                  node: node,
                  unidadeMedida: unidade,
                  modoEdicaoAtivo: state.modoEdicaoAtivo,
                  faseWiggle: state.faseWiggle,
                  produtosDisponiveis: state.produtosDisponiveis,
                  cubit: cubit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
