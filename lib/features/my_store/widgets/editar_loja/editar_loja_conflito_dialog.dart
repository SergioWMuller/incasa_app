import 'package:flutter/material.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';

/// Diálogo exibido quando o salvamento detecta edição concorrente em outro
/// device (ai/EDITAR_LOJA_VIEW.md §8.3-b).
Future<void> mostrarDialogoConflitoDeVersao(
  BuildContext context,
  EditarLojaCubit cubit,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Conflito ao salvar'),
      content: const Text(
        'O layout da loja foi alterado em outro dispositivo depois que você '
        'abriu esta tela. Deseja sobrescrever a versão mais recente com as '
        'suas alterações?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            cubit.resolverConflitoSobrescrevendo();
          },
          child: const Text('Sobrescrever'),
        ),
      ],
    ),
  );
}
