import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';

/// Passo 3 do wizard — disponibilidade, mesmos campos e validações da tela
/// "Adicionar Produto".
class SellStepThreeWidget extends StatelessWidget {
  final SellState state;

  const SellStepThreeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Já está disponível para venda'),
          subtitle: Text(
            state.disponivelVenda ? 'Produto visível' : 'Produto oculto',
          ),
          value: state.disponivelVenda,
          onChanged: (value) => sl<SellCubit>().setDisponivelVenda(value),
          secondary: Icon(
            state.disponivelVenda ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Comercializado a pronta entrega'),
          subtitle: Text(
            state.prontaEntrega
                ? 'Aceita pronta entrega'
                : 'Não aceita pronta entrega',
          ),
          value: state.prontaEntrega,
          onChanged: (value) => sl<SellCubit>().setProntaEntrega(value),
          secondary: Icon(
            state.prontaEntrega
                ? Icons.delivery_dining
                : Icons.delivery_dining_outlined,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Disponível para encomendas'),
          subtitle: Text(
            state.aceitaEncomenda
                ? 'Aceita encomendas'
                : 'Não aceita encomendas',
          ),
          value: state.aceitaEncomenda,
          onChanged: (value) => sl<SellCubit>().setAceitaEncomenda(value),
          secondary: Icon(
            state.aceitaEncomenda ? Icons.event : Icons.event_outlined,
          ),
        ),
        if (state.aceitaEncomenda) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: TextFormField(
              initialValue: state.prazoMinimoEncomendaDias,
              onChanged: (value) =>
                  sl<SellCubit>().setPrazoMinimoEncomendaDias(value),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Prazo mínimo para preparar encomenda - dias',
                border: OutlineInputBorder(),
                hintText: '0',
                helperText: 'Dias necessários para produzir sob encomenda',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
