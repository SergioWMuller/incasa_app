import 'package:flutter/material.dart';

/// Mostra diálogo informativo quando o usuário tenta deletar um endereço principal
Future<void> showAddressPrimaryDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Endereço Principal'),
      content: const Text(
        'Seu endereço principal não pode ser apagado.\n\n'
        'Para apagar este endereço, primeiro defina outro endereço como principal.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}
