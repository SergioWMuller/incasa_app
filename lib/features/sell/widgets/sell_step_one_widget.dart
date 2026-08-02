import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';

/// Passo 1 do wizard — sobre o produto (tipo, nome, categoria, descrição),
/// mesmos campos e validações da tela "Adicionar Produto".
class SellStepOneWidget extends StatelessWidget {
  final SellState state;
  final GlobalKey<FormState> formKey;

  const SellStepOneWidget({
    super.key,
    required this.state,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sobre o que você vai anunciar',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'produto',
                label: Text('Produto'),
                icon: Icon(Icons.shopping_bag),
              ),
              ButtonSegment(
                value: 'servico',
                label: Text('Serviço'),
                icon: Icon(Icons.design_services),
              ),
            ],
            selected: {state.tipo},
            onSelectionChanged: (selection) =>
                sl<SellCubit>().setTipo(selection.first),
          ),
          const SizedBox(height: 20),
          Text(
            'Nome',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.title,
            onChanged: (value) => sl<SellCubit>().setTitle(value),
            decoration: const InputDecoration(
              hintText: 'Ex.: Bolo de cenoura caseiro',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Categoria',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.category,
            onChanged: (value) => sl<SellCubit>().setCategory(value),
            decoration: const InputDecoration(
              hintText: 'Ex.: Doces, Artesanato, Serviço…',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Descrição',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.description,
            onChanged: (value) => sl<SellCubit>().setDescription(value),
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Conte como é feito, ingredientes, porções…',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
