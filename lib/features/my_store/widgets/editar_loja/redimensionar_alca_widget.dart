import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/my_store/resize_axis.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';

/// Alça de redimensionamento de borda de um `GridNode` (ai/EDITAR_LOJA_VIEW.md
/// §6.3) — um pequeno círculo, visível só durante o modo de edição, que o
/// usuário arrasta com 1 dedo para esticar a borda/canto do bloco (parecido
/// com o redimensionamento de widgets na home screen do Android).
///
/// Usa `Listener` (eventos brutos de ponteiro) em vez de `GestureDetector`:
/// o `NoGestoWrapper` ancestral também escuta a mesma área via
/// `onScale*`/`onLongPress`, e dois `GestureDetector`s aninhados disputariam
/// o mesmo ponteiro na gesture arena (o que fazia o bloco inteiro se mexer
/// junto ao tentar redimensionar). `Listener` não entra nessa disputa — só
/// observa — então a alça acompanha o dedo de forma exata e imediata; quem
/// evita o efeito duplo é o Cubit, que ignora o gesto do wrapper enquanto
/// `_snapshotBorda` está ativo.
class RedimensionarAlcaWidget extends StatelessWidget {
  static const double _alvoDeToque = 32;
  static const double _tamanhoVisivel = 18;

  final String nodeId;
  final EixoRedimensionamento eixo;
  final IconData icone;
  final EditarLojaCubit cubit;

  const RedimensionarAlcaWidget({
    super.key,
    required this.nodeId,
    required this.eixo,
    required this.icone,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => cubit.iniciarRedimensionamentoPorBorda(nodeId),
      onPointerMove: (event) => cubit.atualizarRedimensionamentoPorBorda(
        nodeId,
        eixo,
        event.delta.dx,
        event.delta.dy,
      ),
      onPointerUp: (_) => cubit.finalizarRedimensionamentoPorBorda(nodeId),
      onPointerCancel: (_) => cubit.finalizarRedimensionamentoPorBorda(nodeId),
      child: SizedBox(
        // Alvo de toque bem maior que o desenho — mesma lógica dos alvos
        // mínimos de 48dp do Material Design, importante aqui porque a
        // alça precisa caber inteira dentro da área tocável do bloco (ver
        // nota em item_node_widget.dart sobre overflow de `Positioned`).
        width: _alvoDeToque,
        height: _alvoDeToque,
        child: Center(
          child: Container(
            width: _tamanhoVisivel,
            height: _tamanhoVisivel,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icone, size: 11, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
