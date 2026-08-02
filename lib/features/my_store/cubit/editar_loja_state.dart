import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';

enum StatusCarregamentoLayout { inicial, carregando, carregado, erro }

enum StatusSalvamentoLayout { ocioso, salvando, sucesso, erro, conflito }

/// Toda a variável mutável da `EditarLojaView` vive aqui — nenhum estado
/// local em widget (ai/EDITAR_LOJA_VIEW.md §2 e §7.2).
class EditarLojaState extends Equatable {
  final List<GridNode> nodes;
  final double unidadeMedida;
  final bool modoEdicaoAtivo;
  final GridNode? noFlutuante;
  final String? noEmArrasto;
  final String? noEmResize;
  final String? versaoCarregada;
  final StatusCarregamentoLayout statusCarregamento;
  final StatusSalvamentoLayout statusSalvamento;
  final List<Product> produtosDisponiveis;

  /// Direção-alvo (1 ou -1) do wiggle, alternada periodicamente pelo Cubit
  /// (ai/EDITAR_LOJA_VIEW.md §7.3, estratégia recomendada). Os widgets usam
  /// `TweenAnimationBuilder` para animar suavemente até este valor, com um
  /// deslocamento de fase por-nó para não ficarem sincronizados.
  final double faseWiggle;

  final String? erroMensagem;

  const EditarLojaState({
    this.nodes = const [],
    this.unidadeMedida = 0,
    this.modoEdicaoAtivo = false,
    this.noFlutuante,
    this.noEmArrasto,
    this.noEmResize,
    this.versaoCarregada,
    this.statusCarregamento = StatusCarregamentoLayout.inicial,
    this.statusSalvamento = StatusSalvamentoLayout.ocioso,
    this.produtosDisponiveis = const [],
    this.faseWiggle = 0,
    this.erroMensagem,
  });

  EditarLojaState copyWith({
    List<GridNode>? nodes,
    double? unidadeMedida,
    bool? modoEdicaoAtivo,
    GridNode? noFlutuante,
    bool limparNoFlutuante = false,
    String? noEmArrasto,
    bool limparNoEmArrasto = false,
    String? noEmResize,
    bool limparNoEmResize = false,
    String? versaoCarregada,
    StatusCarregamentoLayout? statusCarregamento,
    StatusSalvamentoLayout? statusSalvamento,
    List<Product>? produtosDisponiveis,
    double? faseWiggle,
    String? erroMensagem,
    bool limparErro = false,
  }) {
    return EditarLojaState(
      nodes: nodes ?? this.nodes,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      modoEdicaoAtivo: modoEdicaoAtivo ?? this.modoEdicaoAtivo,
      noFlutuante: limparNoFlutuante ? null : (noFlutuante ?? this.noFlutuante),
      noEmArrasto: limparNoEmArrasto
          ? null
          : (noEmArrasto ?? this.noEmArrasto),
      noEmResize: limparNoEmResize ? null : (noEmResize ?? this.noEmResize),
      versaoCarregada: versaoCarregada ?? this.versaoCarregada,
      statusCarregamento: statusCarregamento ?? this.statusCarregamento,
      statusSalvamento: statusSalvamento ?? this.statusSalvamento,
      produtosDisponiveis: produtosDisponiveis ?? this.produtosDisponiveis,
      faseWiggle: faseWiggle ?? this.faseWiggle,
      erroMensagem: limparErro ? null : (erroMensagem ?? this.erroMensagem),
    );
  }

  @override
  List<Object?> get props => [
    nodes,
    unidadeMedida,
    modoEdicaoAtivo,
    noFlutuante,
    noEmArrasto,
    noEmResize,
    versaoCarregada,
    statusCarregamento,
    statusSalvamento,
    produtosDisponiveis,
    faseWiggle,
    erroMensagem,
  ];
}
