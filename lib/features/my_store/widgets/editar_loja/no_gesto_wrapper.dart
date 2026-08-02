import 'package:flutter/material.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'wiggle_wrapper.dart';

/// Envolve qualquer `GridNode` renderizado com os gestos de edição
/// (ai/EDITAR_LOJA_VIEW.md §6): long-press ativa o modo de edição, e — já em
/// modo de edição — arrastar move o nó pela tela. Também aplica o wiggle
/// enquanto o modo de edição está ativo.
///
/// Redimensionar é feito pelas alças de borda (`RedimensionarAlcaWidget`),
/// não por aqui — o pinça de 2 dedos foi removido (era pior que arrastar
/// uma alça com 1 dedo em blocos pequenos). Por isso o gesto de mover usa
/// `onPan*` (1 dedo só), não `onScale*`.
class NoGestoWrapper extends StatelessWidget {
  final String nodeId;
  final bool modoEdicaoAtivo;
  final double faseWiggle;
  final EditarLojaCubit cubit;
  final Widget child;

  const NoGestoWrapper({
    super.key,
    required this.nodeId,
    required this.modoEdicaoAtivo,
    required this.faseWiggle,
    required this.cubit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = WiggleWrapper(
      ativo: modoEdicaoAtivo,
      faseWiggle: faseWiggle,
      nodeId: nodeId,
      child: child,
    );

    if (!modoEdicaoAtivo) {
      return GestureDetector(
        onLongPress: () => cubit.ativarModoEdicao(nodeId),
        child: conteudo,
      );
    }

    return GestureDetector(
      onLongPress: () => cubit.iniciarArrasto(nodeId),
      onPanStart: (_) => cubit.iniciarArrasto(nodeId),
      onPanUpdate: (details) => cubit.atualizarArrastoPorDelta(
        nodeId,
        details.delta.dx,
        details.delta.dy,
      ),
      onPanEnd: (_) => cubit.finalizarArrasto(nodeId),
      child: conteudo,
    );
  }
}
