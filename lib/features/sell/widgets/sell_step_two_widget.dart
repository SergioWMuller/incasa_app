import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/design_thumb_widget.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';

/// Passo 2 do wizard — fotos, preço, estoque e prazo de produção, mesmos
/// campos e validações da tela "Adicionar Produto".
class SellStepTwoWidget extends StatelessWidget {
  final SellState state;
  final GlobalKey<FormState> formKey;

  const SellStepTwoWidget({
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
            'Fotos do seu produto',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: i < state.photos.length
                        ? GestureDetector(
                            onLongPress: () =>
                                sl<SellCubit>().removePhoto(i),
                            child: DesignThumbWidget(
                              label: state.photos[i],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                        : InkWell(
                            onTap: () => sl<SellCubit>().addPhoto(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Preço',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.price,
            onChanged: (value) => sl<SellCubit>().setPrice(value),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
              hintText: '0,00',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              final price = double.tryParse(value.replaceAll(',', '.'));
              if (price == null || price <= 0) {
                return 'Preço inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Estoque (opcional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.estoque,
            onChanged: (value) => sl<SellCubit>().setEstoque(value),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Prazo de Produção - dias (opcional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.prazoProducaoDias,
            onChanged: (value) => sl<SellCubit>().setPrazoProducaoDias(value),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
