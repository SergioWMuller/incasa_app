import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';

/// Passo 4 do wizard — revisão e publicação
class SellStepFourWidget extends StatelessWidget {
  final SellState state;

  const SellStepFourWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Revise seu anúncio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        NeumorphicSurface(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              row('Tipo', state.tipo == 'servico' ? 'Serviço' : 'Produto'),
              row('Nome', state.title),
              row('Categoria', state.category),
              row('Descrição', state.description),
              row('Preço', state.price.isEmpty ? '' : 'R\$ ${state.price}'),
              row('Estoque', state.estoque),
              row('Prazo de produção', _days(state.prazoProducaoDias)),
              row('Disponível p/ venda', state.disponivelVenda ? 'Sim' : 'Não'),
              row('Pronta entrega', state.prontaEntrega ? 'Sim' : 'Não'),
              row('Aceita encomenda', state.aceitaEncomenda ? 'Sim' : 'Não'),
              if (state.aceitaEncomenda)
                row(
                  'Prazo mín. encomenda',
                  _days(state.prazoMinimoEncomendaDias),
                ),
              row('Fotos', '${state.photos.length} foto(s)'),
            ],
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            'Erro: ${state.errorMessage}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  String _days(String value) => value.isEmpty ? '' : '$value dia(s)';
}
