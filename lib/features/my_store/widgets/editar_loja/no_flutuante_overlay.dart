import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_state.dart';
import 'grid_node_widget.dart';

/// Renderiza o bloco recém-criado "flutuando" sobre a tela, ainda sem
/// posição fixa no grid (ai/EDITAR_LOJA_VIEW.md §6.4). O usuário arrasta
/// livremente; ao soltar, o bloco se encaixa na grade.
class NoFlutuanteOverlay extends StatelessWidget {
  final EditarLojaState state;
  final EditarLojaCubit cubit;

  const NoFlutuanteOverlay({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final flutuante = state.noFlutuante;
    if (flutuante == null) return const SizedBox.shrink();

    final unidade = state.unidadeMedida;

    return Positioned(
      left: flutuante.x * unidade,
      top: flutuante.y * unidade,
      width: flutuante.w * unidade,
      height: flutuante.h * unidade,
      child: GestureDetector(
        onPanUpdate: (details) =>
            cubit.moverNoFlutuantePorDelta(details.delta.dx, details.delta.dy),
        onPanEnd: (_) => cubit.confirmarPosicionamentoDoNoFlutuante(),
        child: Opacity(
          opacity: 0.85,
          child: DecoratedBox(
            decoration: neumorphicDecoration(
              context,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              depth: 7,
            ),
            child: GridNodeWidget(
              node: flutuante,
              unidadeMedida: unidade,
              modoEdicaoAtivo: false,
              faseWiggle: 0,
              produtosDisponiveis: state.produtosDisponiveis,
              cubit: cubit,
            ),
          ),
        ),
      ),
    );
  }
}
