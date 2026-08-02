import 'package:equatable/equatable.dart';

/// Tipo de nó da árvore de layout da `EditarLojaView`.
///
/// Espelha o campo `type` do documento JSON serializado
/// (ver ai/EDITAR_LOJA_VIEW.md §8.1).
enum GridNodeType { item, coluna, linha }

/// Nó da árvore de layout customizável da loja.
///
/// Toda a grade é medida em unidades (não em pixels) — ver
/// ai/EDITAR_LOJA_VIEW.md §4.1. `x`/`y`/`w`/`h` são sempre relativos ao pai
/// (raiz do Grid, ou o `ColunaNode`/`LinhaNode` que contém este nó).
sealed class GridNode extends Equatable {
  final String id;
  final int x;
  final int y;
  final int w;
  final int h;

  const GridNode({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  GridNodeType get type;

  /// Retorna uma cópia deste nó (do subtipo concreto) com nova posição.
  GridNode copyWithPosition({int? x, int? y});

  /// Retorna uma cópia deste nó (do subtipo concreto) com novo tamanho.
  GridNode copyWithSize({int? w, int? h});

  Map<String, dynamic> toJson();

  /// Reconstrói o subtipo correto a partir do campo `type` do JSON.
  static GridNode fromJson(Map<String, dynamic> json) {
    final tipo = json['type'] as String;
    return switch (tipo) {
      'item' => ItemNode.fromJson(json),
      'coluna' => ColunaNode.fromJson(json),
      'linha' => LinhaNode.fromJson(json),
      _ => throw FormatException('Tipo de GridNode desconhecido: $tipo'),
    };
  }

  @override
  List<Object?> get props => [id, x, y, w, h];
}

/// Bloco de produto — folha da árvore (ai/EDITAR_LOJA_VIEW.md §4.4).
class ItemNode extends GridNode {
  static const int larguraMinima = 1;
  static const int larguraMaxima = 6;
  static const int alturaMinima = 1;
  static const int alturaMaxima = 6;
  static const int larguraInicial = 2;
  static const int alturaInicial = 2;

  final String productId;

  const ItemNode({
    required super.id,
    required super.x,
    required super.y,
    super.w = larguraInicial,
    super.h = alturaInicial,
    required this.productId,
  });

  @override
  GridNodeType get type => GridNodeType.item;

  ItemNode copyWith({int? x, int? y, int? w, int? h, String? productId}) {
    return ItemNode(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      productId: productId ?? this.productId,
    );
  }

  @override
  ItemNode copyWithPosition({int? x, int? y}) => copyWith(x: x, y: y);

  @override
  ItemNode copyWithSize({int? w, int? h}) => copyWith(w: w, h: h);

  factory ItemNode.fromJson(Map<String, dynamic> json) {
    return ItemNode(
      id: json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      w: json['w'] as int,
      h: json['h'] as int,
      productId: json['productId'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'item',
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'productId': productId,
  };

  @override
  List<Object?> get props => [...super.props, productId];
}

/// Carrossel vertical — container (ai/EDITAR_LOJA_VIEW.md §4.6).
///
/// Só pode conter `ItemNode` ou `LinhaNode`, nunca outro `ColunaNode`.
class ColunaNode extends GridNode {
  static const int larguraMinima = 2;
  static const int larguraMaxima = 6;
  static const int alturaMinima = 3;
  static const int alturaMaxima = 12;
  static const int larguraInicial = 2;
  static const int alturaInicial = 6;
  static const int itensParaComecarACrescerEmAltura = 6;
  static const int capacidadeMaxima = 12;

  final List<GridNode> children;

  const ColunaNode({
    required super.id,
    required super.x,
    required super.y,
    super.w = larguraInicial,
    super.h = alturaInicial,
    this.children = const [],
  });

  @override
  GridNodeType get type => GridNodeType.coluna;

  ColunaNode copyWith({
    int? x,
    int? y,
    int? w,
    int? h,
    List<GridNode>? children,
  }) {
    return ColunaNode(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      children: children ?? this.children,
    );
  }

  @override
  ColunaNode copyWithPosition({int? x, int? y}) => copyWith(x: x, y: y);

  @override
  ColunaNode copyWithSize({int? w, int? h}) => copyWith(w: w, h: h);

  factory ColunaNode.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>? ?? const [];
    return ColunaNode(
      id: json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      w: json['w'] as int,
      h: json['h'] as int,
      children: childrenJson
          .map((c) => GridNode.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'coluna',
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'children': children.map((c) => c.toJson()).toList(),
  };

  @override
  List<Object?> get props => [...super.props, children];
}

/// Carrossel horizontal — container (ai/EDITAR_LOJA_VIEW.md §4.5).
///
/// Só pode conter `ItemNode` ou `ColunaNode`, nunca outro `LinhaNode`.
class LinhaNode extends GridNode {
  static const int larguraMinima = 3;
  static const int larguraMaxima = 6;
  static const int alturaMinima = 2;
  static const int alturaMaxima = 6;
  static const int larguraInicial = 6;
  static const int alturaInicial = 2;
  static const int capacidadeMaxima = 12;

  final List<GridNode> children;

  const LinhaNode({
    required super.id,
    required super.x,
    required super.y,
    super.w = larguraInicial,
    super.h = alturaInicial,
    this.children = const [],
  });

  @override
  GridNodeType get type => GridNodeType.linha;

  LinhaNode copyWith({
    int? x,
    int? y,
    int? w,
    int? h,
    List<GridNode>? children,
  }) {
    return LinhaNode(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      children: children ?? this.children,
    );
  }

  @override
  LinhaNode copyWithPosition({int? x, int? y}) => copyWith(x: x, y: y);

  @override
  LinhaNode copyWithSize({int? w, int? h}) => copyWith(w: w, h: h);

  factory LinhaNode.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>? ?? const [];
    return LinhaNode(
      id: json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      w: json['w'] as int,
      h: json['h'] as int,
      children: childrenJson
          .map((c) => GridNode.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'linha',
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'children': children.map((c) => c.toJson()).toList(),
  };

  @override
  List<Object?> get props => [...super.props, children];
}
