import 'package:flutter/material.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/domain/entities/my_store/resize_axis.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'no_gesto_wrapper.dart';
import 'redimensionar_alca_widget.dart';

/// Renderiza um `ItemNode` (bloco de produto) — ai/EDITAR_LOJA_VIEW.md §4.4.
class ItemNodeWidget extends StatelessWidget {
  final ItemNode node;
  final double unidadeMedida;
  final bool modoEdicaoAtivo;
  final double faseWiggle;
  final List<Product> produtosDisponiveis;
  final EditarLojaCubit cubit;

  const ItemNodeWidget({
    super.key,
    required this.node,
    required this.unidadeMedida,
    required this.modoEdicaoAtivo,
    required this.faseWiggle,
    required this.produtosDisponiveis,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    Product? produto;
    for (final p in produtosDisponiveis) {
      if (p.id == node.productId) {
        produto = p;
        break;
      }
    }

    return NoGestoWrapper(
      nodeId: node.id,
      modoEdicaoAtivo: modoEdicaoAtivo,
      faseWiggle: faseWiggle,
      cubit: cubit,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            // Encolhe o cartão do Item em 5px de cada lado, para que ele
            // fique visualmente menor que Linha e Coluna (que preenchem
            // toda a célula) e se destaque como o bloco "folha" da árvore.
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: produto == null
                  ? const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            produto.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            produto.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (modoEdicaoAtivo)
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => cubit.removerNo(node.id),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          // Alças de redimensionamento por borda (§6.3) — alternativa ao
          // pinça, mais fácil de usar num bloco pequeno como o Item.
          //
          // Ficam ancoradas na borda mas SEM overflow (right/bottom: 0, não
          // valores negativos): um `Positioned` que transborda os limites
          // do `Stack` não recebe toque no Flutter (o hit-test do pai só
          // desce para um filho se o toque cair dentro do tamanho que o
          // próprio pai reservou para ele) — então a alça precisa caber
          // inteira dentro da célula do nó para ser clicável de forma
          // confiável, mesmo com `clipBehavior: Clip.none` permitindo
          // desenhar fora visualmente.
          if (modoEdicaoAtivo) ...[
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 32,
              child: Center(
                child: RedimensionarAlcaWidget(
                  nodeId: node.id,
                  eixo: EixoRedimensionamento.larguraApenas,
                  icone: Icons.swap_horiz,
                  cubit: cubit,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 32,
              child: Center(
                child: RedimensionarAlcaWidget(
                  nodeId: node.id,
                  eixo: EixoRedimensionamento.alturaApenas,
                  icone: Icons.swap_vert,
                  cubit: cubit,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              width: 32,
              height: 32,
              child: RedimensionarAlcaWidget(
                nodeId: node.id,
                eixo: EixoRedimensionamento.ambos,
                icone: Icons.open_in_full,
                cubit: cubit,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
