import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/id_generator.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';
import 'package:incasa_app/domain/entities/my_store/resize_axis.dart';
import 'package:incasa_app/domain/entities/my_store/store_layout.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_store_layout.dart';
import 'package:incasa_app/domain/usecases/my_store/save_store_layout.dart';
import 'editar_loja_state.dart';

/// Único Cubit responsável por toda a `EditarLojaView`
/// (ai/EDITAR_LOJA_VIEW.md §2, §7). Nenhum widget desta feature guarda
/// estado próprio — toda mutação passa por aqui.
class EditarLojaCubit extends Cubit<EditarLojaState> {
  static const int _larguraGrid = 6;
  static const double _margin = 4;
  static const double _padding = 4;

  final GetStoreLayout getStoreLayoutUseCase;
  final SaveStoreLayout saveStoreLayoutUseCase;
  final GetMyProducts getMyProductsUseCase;

  Timer? _wiggleTimer;

  /// Snapshot do nó no instante em que o gesto (arrasto/resize) começou —
  /// usado como referência para os deltas incrementais recebidos da UI.
  /// Bookkeeping interno do Cubit, não faz parte de `EditarLojaState` (não
  /// é informação relevante para o restage da tela, só para o gesto em
  /// andamento).
  GridNode? _snapshotGesto;
  double _arrastoAcumuladoXPx = 0;
  double _arrastoAcumuladoYPx = 0;

  /// Fotografia da árvore de nível raiz no instante em que o arrasto
  /// começou (§6.2). Cada atualização do arrasto recalcula a prévia de
  /// reflow A PARTIR DESTA fotografia — nunca em cima da prévia anterior —
  /// para que nós empurrados por uma colisão voltem exatamente ao lugar se
  /// o usuário se afastar sem soltar ali. Só é "de verdade" quando o gesto
  /// termina (`finalizarArrasto`); até lá é só preview visual.
  List<GridNode>? _nodesAntesDoArrasto;

  GridNode? _flutuanteOrigem;
  double _flutuanteAcumuladoXPx = 0;
  double _flutuanteAcumuladoYPx = 0;

  /// Snapshot equivalente a `_snapshotGesto`, mas para o gesto de arrastar
  /// uma alça de borda (1 dedo) em vez do pinça — gestos distintos, então
  /// bookkeeping separado para não conflitarem se o usuário alternar entre
  /// os dois.
  GridNode? _snapshotBorda;
  double _bordaAcumuladoXPx = 0;
  double _bordaAcumuladoYPx = 0;

  EditarLojaCubit({
    required this.getStoreLayoutUseCase,
    required this.saveStoreLayoutUseCase,
    required this.getMyProductsUseCase,
  }) : super(const EditarLojaState());

  // ---------------------------------------------------------------------
  // Inicialização
  // ---------------------------------------------------------------------

  /// Calcula `unidadeMedida` (§4.1) e dispara o carregamento inicial. Seguro
  /// para chamar em todo `build()` da view — só age na primeira vez.
  void inicializar(double larguraTelaFisica) {
    if (state.unidadeMedida == 0 && larguraTelaFisica > 0) {
      final unidade =
          (larguraTelaFisica - _margin * 2 - _padding * 2) / _larguraGrid;
      emit(state.copyWith(unidadeMedida: unidade));
    }
    if (state.statusCarregamento == StatusCarregamentoLayout.inicial) {
      carregarLayout();
      carregarProdutosDisponiveis();
    }
  }

  Future<void> carregarLayout() async {
    emit(
      state.copyWith(statusCarregamento: StatusCarregamentoLayout.carregando),
    );
    final resultado = await getStoreLayoutUseCase(const NoParams());
    switch (resultado) {
      case Success(:final data):
        emit(
          state.copyWith(
            nodes: data.nodes,
            versaoCarregada: data.version,
            statusCarregamento: StatusCarregamentoLayout.carregado,
          ),
        );
      case Error(:final failure):
        emit(
          state.copyWith(
            statusCarregamento: StatusCarregamentoLayout.erro,
            erroMensagem: failure.message,
          ),
        );
    }
  }

  Future<void> carregarProdutosDisponiveis() async {
    final resultado = await getMyProductsUseCase(const NoParams());
    if (resultado case Success(:final data)) {
      emit(state.copyWith(produtosDisponiveis: data));
    }
  }

  // ---------------------------------------------------------------------
  // Modo de edição (wiggle) — §6.1, §7.3
  // ---------------------------------------------------------------------

  void ativarModoEdicao(String nodeId) {
    if (state.modoEdicaoAtivo) return;
    emit(state.copyWith(modoEdicaoAtivo: true));
    _wiggleTimer?.cancel();
    _wiggleTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      final novaFase = state.faseWiggle <= 0 ? 1.0 : -1.0;
      emit(state.copyWith(faseWiggle: novaFase));
    });
  }

  void desativarModoEdicao() {
    _wiggleTimer?.cancel();
    _wiggleTimer = null;
    emit(
      state.copyWith(
        modoEdicaoAtivo: false,
        faseWiggle: 0,
        limparNoEmArrasto: true,
        limparNoEmResize: true,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Fluxo de adicionar bloco — BottomBar (§6.4)
  // ---------------------------------------------------------------------

  void iniciarPosicionamentoDeNovoNo(GridNode node) {
    _flutuanteOrigem = node;
    _flutuanteAcumuladoXPx = 0;
    _flutuanteAcumuladoYPx = 0;
    emit(state.copyWith(noFlutuante: node));
  }

  void moverNoFlutuanteParaPosicao(int x, int y) {
    final flutuante = state.noFlutuante;
    if (flutuante == null) return;
    final xClampado = x.clamp(0, _larguraGrid - flutuante.w);
    final yClampado = y < 0 ? 0 : y;
    emit(
      state.copyWith(
        noFlutuante: flutuante.copyWithPosition(x: xClampado, y: yClampado),
      ),
    );
  }

  /// Converte um delta incremental em pixels em posição absoluta em
  /// unidades para o nó flutuante ainda sem posição fixa (§6.4).
  void moverNoFlutuantePorDelta(double deltaXPx, double deltaYPx) {
    final origem = _flutuanteOrigem;
    if (origem == null || state.unidadeMedida == 0) return;

    _flutuanteAcumuladoXPx += deltaXPx;
    _flutuanteAcumuladoYPx += deltaYPx;

    final novoX =
        origem.x + (_flutuanteAcumuladoXPx / state.unidadeMedida).round();
    final novoY =
        origem.y + (_flutuanteAcumuladoYPx / state.unidadeMedida).round();
    moverNoFlutuanteParaPosicao(novoX, novoY);
  }

  void confirmarPosicionamentoDoNoFlutuante() {
    final flutuante = state.noFlutuante;
    if (flutuante == null) return;
    final novosNodes = _reflowRaiz(
      [...state.nodes, flutuante],
      alvoId: flutuante.id,
    );
    _flutuanteOrigem = null;
    emit(state.copyWith(nodes: novosNodes, limparNoFlutuante: true));
  }

  void cancelarPosicionamentoDoNoFlutuante() {
    _flutuanteOrigem = null;
    emit(state.copyWith(limparNoFlutuante: true));
  }

  // ---------------------------------------------------------------------
  // Arrastar (§6.2)
  // ---------------------------------------------------------------------

  /// Enquanto uma alça de borda está sendo arrastada (`_snapshotBorda` !=
  /// null), o gesto ancestral do `NoGestoWrapper` (que cobre a mesma área de
  /// toque — long-press/onPan do bloco inteiro) é ignorado. Sem essa trava,
  /// tocar numa alça também arrastaria o nó inteiro pelo gesto do wrapper,
  /// já que os dois `GestureDetector`s aninhados disputam o mesmo ponteiro.
  void iniciarArrasto(String nodeId) {
    if (_snapshotBorda != null) return;
    _snapshotGesto = _localizarNo(nodeId, state.nodes);
    _nodesAntesDoArrasto = state.nodes;
    _arrastoAcumuladoXPx = 0;
    _arrastoAcumuladoYPx = 0;
    emit(state.copyWith(noEmArrasto: nodeId));
  }

  /// Atualiza a posição do nó durante o arrasto. No nível raiz, nada é
  /// "de verdade" ainda — cada chamada recalcula uma PRÉVIA de reflow (§6.2)
  /// a partir do layout ORIGINAL (`_nodesAntesDoArrasto`, fotografado em
  /// `iniciarArrasto`), nunca em cima da prévia da chamada anterior. Isso é
  /// o que garante que, ao passar por cima de outro bloco sem soltar ali, o
  /// bloco empurrado volte exatamente à posição original assim que o
  /// arrasto se afastar — nada foi de fato commitado até `finalizarArrasto`.
  /// Nós de nível raiz ficam presos às 6 unidades de largura do Grid (§5).
  void atualizarArrasto(String nodeId, int novoX, int novoY) {
    final nodesBase = _nodesAntesDoArrasto ?? state.nodes;
    final no = _localizarNo(nodeId, nodesBase);
    if (no == null) return;
    final ehRaiz = _localizarContainerPai(nodeId, nodesBase) == null;

    final xFinal = ehRaiz ? novoX.clamp(0, _larguraGrid - no.w) : novoX;
    final yFinal = ehRaiz && novoY < 0 ? 0 : novoY;

    final movido = _atualizarNo(
      nodesBase,
      nodeId,
      (node) => node.copyWithPosition(x: xFinal, y: yFinal),
    );
    final preview = ehRaiz ? _reflowRaiz(movido, alvoId: nodeId) : movido;
    emit(state.copyWith(nodes: preview));
  }

  /// Converte um delta incremental em pixels (ex: `DragUpdateDetails.delta`)
  /// em posição absoluta em unidades, acumulando desde o início do gesto
  /// (`iniciarArrasto`), e aplica via `atualizarArrasto`.
  void atualizarArrastoPorDelta(String nodeId, double deltaXPx, double deltaYPx) {
    if (_snapshotBorda != null) return;
    final snapshot = _snapshotGesto;
    if (snapshot == null || state.unidadeMedida == 0) return;

    _arrastoAcumuladoXPx += deltaXPx;
    _arrastoAcumuladoYPx += deltaYPx;

    final novoX =
        snapshot.x + (_arrastoAcumuladoXPx / state.unidadeMedida).round();
    final novoY =
        snapshot.y + (_arrastoAcumuladoYPx / state.unidadeMedida).round();
    atualizarArrasto(nodeId, novoX, novoY);
  }

  /// Ao soltar, o preview computado a cada `atualizarArrasto` vira
  /// definitivo — o reflow aqui é só uma garantia idempotente (o layout já
  /// deve estar sem sobreposições nesse ponto).
  void finalizarArrasto(String nodeId) {
    if (_snapshotBorda != null) return;
    final novosNodes = _reflowAposMudanca(state.nodes, nodeId);
    _snapshotGesto = null;
    _nodesAntesDoArrasto = null;
    emit(state.copyWith(nodes: novosNodes, limparNoEmArrasto: true));
  }

  // ---------------------------------------------------------------------
  // Redimensionar (§6.3)
  // ---------------------------------------------------------------------

  void redimensionar(String nodeId, int novoW, int novoH) {
    final no = _localizarNo(nodeId, state.nodes);
    if (no == null) return;

    final GridNode redimensionado = switch (no) {
      ItemNode() => no.copyWith(
        w: novoW.clamp(ItemNode.larguraMinima, ItemNode.larguraMaxima),
        h: novoH.clamp(ItemNode.alturaMinima, ItemNode.alturaMaxima),
      ),
      LinhaNode() => _clampLinha(no, novoW, novoH),
      ColunaNode() => _clampColuna(no, novoW, novoH),
    };

    // No nível raiz, o nó não é mais reempacotado ao final do gesto — então
    // ele não pode crescer para além das 6 unidades de largura do Grid (§5)
    // a partir da posição `x` onde já está.
    final ehRaiz = _localizarContainerPai(nodeId, state.nodes) == null;
    final limitado = ehRaiz && redimensionado.x + redimensionado.w > _larguraGrid
        ? redimensionado.copyWithSize(w: _larguraGrid - redimensionado.x)
        : redimensionado;

    final atualizados = _atualizarNo(
      state.nodes,
      nodeId,
      (_) => limitado,
    );
    final reordenados = _reflowAposMudanca(atualizados, nodeId);
    emit(state.copyWith(nodes: reordenados, noEmResize: nodeId));
  }

  LinhaNode _clampLinha(LinhaNode linha, int novoW, int novoH) {
    final w = novoW.clamp(LinhaNode.larguraMinima, LinhaNode.larguraMaxima);
    var h = novoH.clamp(LinhaNode.alturaMinima, LinhaNode.alturaMaxima);
    if (h > w) h = w; // h nunca pode ser maior que w (§4.5)
    return linha.copyWith(w: w, h: h);
  }

  // ---------------------------------------------------------------------
  // Redimensionar por alça de borda — 1 dedo (§6.3, alternativa ao pinça)
  // ---------------------------------------------------------------------

  void iniciarRedimensionamentoPorBorda(String nodeId) {
    _snapshotBorda = _localizarNo(nodeId, state.nodes);
    _bordaAcumuladoXPx = 0;
    _bordaAcumuladoYPx = 0;
    emit(state.copyWith(noEmResize: nodeId));
  }

  /// Converte o arrasto de 1 dedo numa alça de borda em novo tamanho
  /// absoluto, acumulando desde `iniciarRedimensionamentoPorBorda`. Qual
  /// eixo (`largura`, `altura` ou `ambos`) é alterado depende de qual borda
  /// o usuário agarrou — a alça em si sabe disso e informa via `eixo`.
  void atualizarRedimensionamentoPorBorda(
    String nodeId,
    EixoRedimensionamento eixo,
    double deltaXPx,
    double deltaYPx,
  ) {
    final snapshot = _snapshotBorda;
    if (snapshot == null || state.unidadeMedida == 0) return;

    _bordaAcumuladoXPx += deltaXPx;
    _bordaAcumuladoYPx += deltaYPx;

    final novoW = eixo == EixoRedimensionamento.alturaApenas
        ? snapshot.w
        : snapshot.w + (_bordaAcumuladoXPx / state.unidadeMedida).round();
    final novoH = eixo == EixoRedimensionamento.larguraApenas
        ? snapshot.h
        : snapshot.h + (_bordaAcumuladoYPx / state.unidadeMedida).round();

    redimensionar(nodeId, novoW, novoH);
  }

  void finalizarRedimensionamentoPorBorda(String nodeId) {
    _snapshotBorda = null;
    emit(state.copyWith(limparNoEmResize: true));
  }

  ColunaNode _clampColuna(ColunaNode coluna, int novoW, int novoH) {
    final h = novoH.clamp(ColunaNode.alturaMinima, ColunaNode.alturaMaxima);
    var w = novoW.clamp(ColunaNode.larguraMinima, ColunaNode.larguraMaxima);
    if (w > h) w = h; // w nunca pode ser maior que h (§4.6)
    return coluna.copyWith(w: w, h: h);
  }

  // ---------------------------------------------------------------------
  // Containers — adicionar item e reordenar (§4.5, §4.6, §6.1)
  // ---------------------------------------------------------------------

  void adicionarItemAoContainer(String containerId, ItemNode item) {
    final container = _localizarNo(containerId, state.nodes);

    if (container is ColunaNode) {
      if (container.children.length >= ColunaNode.capacidadeMaxima) return;
      final novoContainer = _reflowColuna(
        container.copyWith(children: [...container.children, item]),
      );
      emit(
        state.copyWith(
          nodes: _atualizarNo(state.nodes, containerId, (_) => novoContainer),
        ),
      );
      return;
    }

    if (container is LinhaNode) {
      if (container.children.length >= LinhaNode.capacidadeMaxima) return;
      final novoContainer = _reflowLinha(
        container.copyWith(children: [...container.children, item]),
      );
      emit(
        state.copyWith(
          nodes: _atualizarNo(state.nodes, containerId, (_) => novoContainer),
        ),
      );
      return;
    }
  }

  /// Reordenação por wiggle+drag dentro do carrossel de uma Linha (§4.5).
  void reordenarItemNaLinha(String linhaId, int deIndex, int paraIndex) {
    final no = _localizarNo(linhaId, state.nodes);
    if (no is! LinhaNode) return;
    if (deIndex < 0 || deIndex >= no.children.length) return;

    final filhos = [...no.children];
    final item = filhos.removeAt(deIndex);
    filhos.insert(paraIndex.clamp(0, filhos.length), item);

    final novoNo = _reflowLinha(no.copyWith(children: filhos));
    emit(
      state.copyWith(nodes: _atualizarNo(state.nodes, linhaId, (_) => novoNo)),
    );
  }

  /// Remove o nó. Nós de nível raiz não são reempacotados — cada bloco
  /// mantém a posição em que o usuário o deixou (§6.2); só os containers
  /// (Coluna/Linha), que são listas 1D, precisam fechar o buraco deixado.
  void removerNo(String nodeId) {
    final pai = _localizarContainerPai(nodeId, state.nodes);
    var novosNodes = _removerNoRecursivo(state.nodes, nodeId);
    if (pai != null) {
      novosNodes = _atualizarNo(novosNodes, pai.id, _reflowContainer);
    }
    emit(state.copyWith(nodes: novosNodes));
  }

  // ---------------------------------------------------------------------
  // Persistência (§8)
  // ---------------------------------------------------------------------

  Future<void> salvarLayout() => _salvar(sobrescrever: false);

  Future<void> resolverConflitoSobrescrevendo() => _salvar(sobrescrever: true);

  Future<void> _salvar({required bool sobrescrever}) async {
    emit(state.copyWith(statusSalvamento: StatusSalvamentoLayout.salvando));

    final resultado = await saveStoreLayoutUseCase(
      SaveStoreLayoutParams(
        layout: StoreLayout(
          nodes: state.nodes,
          version: state.versaoCarregada ?? '',
        ),
        versaoCarregada: state.versaoCarregada,
        gerarNovaVersao: gerarIdUnico,
        sobrescrever: sobrescrever,
      ),
    );

    switch (resultado) {
      case Success(:final data):
        switch (data.status) {
          case SaveLayoutStatus.salvo:
            emit(
              state.copyWith(
                versaoCarregada: data.layout.version,
                statusSalvamento: StatusSalvamentoLayout.sucesso,
              ),
            );
          case SaveLayoutStatus.conflito:
            emit(
              state.copyWith(statusSalvamento: StatusSalvamentoLayout.conflito),
            );
        }
      case Error(:final failure):
        emit(
          state.copyWith(
            statusSalvamento: StatusSalvamentoLayout.erro,
            erroMensagem: failure.message,
          ),
        );
    }
  }

  // ---------------------------------------------------------------------
  // Árvore de nós — busca, atualização e reflow
  // ---------------------------------------------------------------------

  GridNode? _localizarNo(String id, List<GridNode> lista) {
    for (final node in lista) {
      if (node.id == id) return node;
      final filhos = switch (node) {
        ColunaNode(:final children) => children,
        LinhaNode(:final children) => children,
        ItemNode() => null,
      };
      if (filhos != null) {
        final achado = _localizarNo(id, filhos);
        if (achado != null) return achado;
      }
    }
    return null;
  }

  GridNode? _localizarContainerPai(String id, List<GridNode> lista) {
    for (final node in lista) {
      final filhos = switch (node) {
        ColunaNode(:final children) => children,
        LinhaNode(:final children) => children,
        ItemNode() => null,
      };
      if (filhos == null) continue;
      if (filhos.any((c) => c.id == id)) return node;
      final achadoNeto = _localizarContainerPai(id, filhos);
      if (achadoNeto != null) return achadoNeto;
    }
    return null;
  }

  List<GridNode> _atualizarNo(
    List<GridNode> lista,
    String id,
    GridNode Function(GridNode) atualizar,
  ) {
    return lista.map((node) {
      if (node.id == id) return atualizar(node);
      return switch (node) {
        ColunaNode() => node.copyWith(
          children: _atualizarNo(node.children, id, atualizar),
        ),
        LinhaNode() => node.copyWith(
          children: _atualizarNo(node.children, id, atualizar),
        ),
        ItemNode() => node,
      };
    }).toList();
  }

  List<GridNode> _removerNoRecursivo(List<GridNode> lista, String id) {
    return lista
        .where((n) => n.id != id)
        .map((node) {
          return switch (node) {
            ColunaNode() => node.copyWith(
              children: _removerNoRecursivo(node.children, id),
            ),
            LinhaNode() => node.copyWith(
              children: _removerNoRecursivo(node.children, id),
            ),
            ItemNode() => node,
          };
        })
        .toList();
  }

  GridNode _reflowContainer(GridNode container) {
    return switch (container) {
      LinhaNode() => _reflowLinha(container),
      ColunaNode() => _reflowColuna(container),
      ItemNode() => container,
    };
  }

  List<GridNode> _reflowAposMudanca(List<GridNode> nodes, String nodeId) {
    final pai = _localizarContainerPai(nodeId, nodes);
    if (pai == null) return _reflowRaiz(nodes, alvoId: nodeId);
    return _atualizarNo(nodes, pai.id, _reflowContainer);
  }

  bool _sobrepoe(GridNode a, GridNode b) {
    return a.x < b.x + b.w &&
        b.x < a.x + a.w &&
        a.y < b.y + b.h &&
        b.y < a.y + a.h;
  }

  /// Reflow 2D do nível raiz (§6.2): o nó recém-solto/redimensionado
  /// (`alvoId`) fica exatamente onde o usuário tirou o dedo da tela — nunca
  /// é reempacotado junto com o resto. Só os nós que efetivamente colidem
  /// com ele são empurrados (para a direita da posição de soltura e, se não
  /// houver espaço, para a linha seguinte), em cascata até não sobrar
  /// nenhuma sobreposição — análogo ao reflow de ícones do iOS.
  List<GridNode> _reflowRaiz(List<GridNode> nodes, {required String alvoId}) {
    final porId = {for (final n in nodes) n.id: n};
    final pendentes = [alvoId];
    final emPendencia = {alvoId};

    var protecaoContraLoop = nodes.length * nodes.length + nodes.length;
    while (pendentes.isNotEmpty && protecaoContraLoop-- > 0) {
      final idAtual = pendentes.removeAt(0);
      emPendencia.remove(idAtual);
      final atual = porId[idAtual];
      if (atual == null) continue;

      for (final outro in porId.values.toList()) {
        if (outro.id == idAtual || !_sobrepoe(atual, outro)) continue;

        var novoX = atual.x + atual.w;
        var novoY = atual.y;
        if (novoX + outro.w > _larguraGrid) {
          novoX = 0;
          novoY = atual.y + atual.h;
        }

        porId[outro.id] = outro.copyWithPosition(x: novoX, y: novoY);
        if (emPendencia.add(outro.id)) pendentes.add(outro.id);
      }
    }

    return nodes.map((n) => porId[n.id]!).toList();
  }

  /// Reflow 1D horizontal — os filhos de uma Linha ficam lado a lado.
  LinhaNode _reflowLinha(LinhaNode linha) {
    var xAtual = 0;
    final filhos = linha.children.map((c) {
      final posicionado = c.copyWithPosition(x: xAtual, y: 0);
      xAtual += c.w;
      return posicionado;
    }).toList();
    return linha.copyWith(children: filhos);
  }

  /// Reflow 1D vertical — os filhos de uma Coluna ficam empilhados, e a
  /// altura cresce automaticamente a partir do 6º item (§4.6).
  ///
  /// A altura mínima necessária é a soma das alturas dos filhos (em vez da
  /// heurística "+1 por item além do 6º" tomada ao pé da letra) — isso
  /// mantém o container sempre grande o bastante para caber o conteúdo sem
  /// cortar nada, mesmo quando os itens não têm todos a mesma altura.
  ColunaNode _reflowColuna(ColunaNode coluna) {
    var yAtual = 0;
    final filhos = coluna.children.map((c) {
      final posicionado = c.copyWithPosition(x: 0, y: yAtual);
      yAtual += c.h;
      return posicionado;
    }).toList();

    final alturaNecessaria = yAtual.clamp(
      ColunaNode.alturaMinima,
      ColunaNode.alturaMaxima,
    );

    return coluna.copyWith(
      children: filhos,
      h: alturaNecessaria > coluna.h ? alturaNecessaria : coluna.h,
    );
  }

  @override
  Future<void> close() {
    _wiggleTimer?.cancel();
    return super.close();
  }
}
