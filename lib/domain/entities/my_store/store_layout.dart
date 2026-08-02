import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/my_store/grid_node.dart';

/// Layout completo da `EditarLojaView`, serializado como um único documento
/// (ai/EDITAR_LOJA_VIEW.md §8.1) — sempre lido/escrito por inteiro, nunca em
/// partes.
class StoreLayout extends Equatable {
  final List<GridNode> nodes;

  /// Version token usado na checagem de conflito ao salvar (§8.3).
  /// String vazia significa "ainda nunca foi salvo".
  final String version;

  const StoreLayout({required this.nodes, required this.version});

  factory StoreLayout.vazio() => const StoreLayout(nodes: [], version: '');

  StoreLayout copyWith({List<GridNode>? nodes, String? version}) {
    return StoreLayout(
      nodes: nodes ?? this.nodes,
      version: version ?? this.version,
    );
  }

  factory StoreLayout.fromJson(Map<String, dynamic> json) {
    final nodesJson = json['nodes'] as List<dynamic>? ?? const [];
    return StoreLayout(
      version: json['version'] as String? ?? '',
      nodes: nodesJson
          .map((n) => GridNode.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'nodes': nodes.map((n) => n.toJson()).toList(),
  };

  @override
  List<Object?> get props => [nodes, version];
}
