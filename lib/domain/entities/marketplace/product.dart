import 'package:equatable/equatable.dart';

/// Entity de Produto no domínio.
///
/// Reflete o recurso `products` exposto pela API (incasa-api.yaml).
/// `ownerId` é definido pelo backend a partir do usuário autenticado, por isso
/// é opcional ao construir um produto novo no app.
class Product extends Equatable {
  final String id;
  final String ownerId;
  final String tipo; // 'produto' ou 'servico'
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int? estoque;
  final int? prazoProducaoDias;
  final int? prazoEntregaHoras;
  final int? prazoMinimoEncomendaDias;
  final bool disponivelVenda;
  final bool prontaEntrega;
  final bool aceitaEncomenda;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.tipo,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    this.ownerId = '',
    this.estoque,
    this.prazoProducaoDias,
    this.prazoEntregaHoras,
    this.prazoMinimoEncomendaDias,
    this.disponivelVenda = true,
    this.prontaEntrega = true,
    this.aceitaEncomenda = false,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    ownerId,
    tipo,
    name,
    description,
    price,
    imageUrl,
    category,
    estoque,
    prazoProducaoDias,
    prazoEntregaHoras,
    prazoMinimoEncomendaDias,
    disponivelVenda,
    prontaEntrega,
    aceitaEncomenda,
    createdAt,
    updatedAt,
  ];
}
