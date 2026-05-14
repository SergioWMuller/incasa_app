import 'package:equatable/equatable.dart';

/// Entity de Produto no domínio
/// Regras de negócio puras, sem dependência de frameworks
class Product extends Equatable {
  final String id;
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

  const Product({
    required this.id,
    required this.tipo,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.estoque,
    this.prazoProducaoDias,
    this.prazoEntregaHoras,
    this.prazoMinimoEncomendaDias,
    this.disponivelVenda = true,
    this.prontaEntrega = true,
    this.aceitaEncomenda = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
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
  ];
}
