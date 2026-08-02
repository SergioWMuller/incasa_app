import 'package:flutter/material.dart';

/// Mostra diálogo de confirmação para deletar um endereço
/// Retorna true se o usuário confirmar, false caso contrário
Future<bool> showAddressDeleteConfirmationDialog(
  BuildContext context, {
  required String street,
  required String? number,
  required String city,
  required String state,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Deletar Endereço'),
      content: Text(
        'Tem certeza que deseja deletar o endereço:\n\n'
        '$street, ${number ?? "S/N"}\n'
        '$city - $state?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Deletar'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
