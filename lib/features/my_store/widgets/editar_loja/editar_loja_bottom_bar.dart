import 'package:flutter/material.dart';
import 'package:incasa_app/core/utils/id_generator.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'menu_selecao_produto.dart';

/// Barra inferior fixa com os 3 botões de adicionar bloco — Coluna, Linha e
/// Produto (ai/EDITAR_LOJA_VIEW.md §6.4).
class EditarLojaBottomBar extends StatelessWidget {
  final EditarLojaCubit cubit;

  const EditarLojaBottomBar({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () => cubit.iniciarPosicionamentoDeNovoNo(
              ColunaNode(id: gerarIdUnico(), x: 0, y: 0),
            ),
            icon: const Icon(Icons.view_column_outlined),
            label: const Text('Coluna'),
          ),
          TextButton.icon(
            onPressed: () => cubit.iniciarPosicionamentoDeNovoNo(
              LinhaNode(id: gerarIdUnico(), x: 0, y: 0),
            ),
            icon: const Icon(Icons.view_stream_outlined),
            label: const Text('Linha'),
          ),
          TextButton.icon(
            onPressed: () => abrirMenuSelecaoProduto(context, cubit),
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Produto'),
          ),
        ],
      ),
    );
  }
}
