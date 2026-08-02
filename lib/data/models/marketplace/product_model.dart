import 'package:incasa_app/domain/entities/marketplace/product.dart';

/// Model do recurso `products` (incasa-api.yaml).
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.tipo,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.category,
    required super.createdAt,
    super.ownerId = '',
    super.estoque,
    super.prazoProducaoDias,
    super.prazoEntregaHoras,
    super.prazoMinimoEncomendaDias,
    super.disponivelVenda = true,
    super.prontaEntrega = true,
    super.aceitaEncomenda = false,
    super.updatedAt,
  });

  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  // ========================================
  // SUPABASE
  // ========================================

  /// Converte uma linha REST da tabela `products` em [ProductModel].
  factory ProductModel.fromSupabase(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      tipo: json['tipo'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String,
      estoque: json['estoque'] as int?,
      prazoProducaoDias: json['prazo_producao_dias'] as int?,
      prazoEntregaHoras: json['prazo_entrega_horas'] as int?,
      prazoMinimoEncomendaDias: json['prazo_minimo_encomenda_dias'] as int?,
      disponivelVenda: json['disponivel_venda'] as bool? ?? true,
      prontaEntrega: json['pronta_entrega'] as bool? ?? true,
      aceitaEncomenda: json['aceita_encomenda'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  /// Payload para INSERT/UPDATE (conforme `ProductInsert`/`ProductUpdate`).
  /// `id`, `owner_id` e timestamps são gerenciados pelo backend.
  Map<String, dynamic> toSupabase() {
    return {
      'tipo': tipo,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
      'category': category,
      'estoque': estoque,
      'prazo_producao_dias': prazoProducaoDias,
      'prazo_entrega_horas': prazoEntregaHoras,
      'prazo_minimo_encomenda_dias': prazoMinimoEncomendaDias,
      'disponivel_venda': disponivelVenda,
      'pronta_entrega': prontaEntrega,
      'aceita_encomenda': aceitaEncomenda,
    };
  }

  // ========================================
  // JSON (cache local / snapshots)
  // ========================================

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      ownerId: (json['owner_id'] ?? json['ownerId'] ?? '') as String,
      tipo: json['tipo'] as String? ?? 'produto',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '') as String,
      category: json['category'] as String? ?? '',
      estoque: json['estoque'] as int?,
      prazoProducaoDias: (json['prazo_producao_dias'] ?? json['prazoProducaoDias'])
          as int?,
      prazoEntregaHoras: (json['prazo_entrega_horas'] ?? json['prazoEntregaHoras'])
          as int?,
      prazoMinimoEncomendaDias:
          (json['prazo_minimo_encomenda_dias'] ?? json['prazoMinimoEncomendaDias'])
              as int?,
      disponivelVenda:
          (json['disponivel_venda'] ?? json['disponivelVenda']) as bool? ?? true,
      prontaEntrega:
          (json['pronta_entrega'] ?? json['prontaEntrega']) as bool? ?? true,
      aceitaEncomenda:
          (json['aceita_encomenda'] ?? json['aceitaEncomenda']) as bool? ?? false,
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ),
      updatedAt: _tryParseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'tipo': tipo,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'estoque': estoque,
      'prazo_producao_dias': prazoProducaoDias,
      'prazo_entrega_horas': prazoEntregaHoras,
      'prazo_minimo_encomenda_dias': prazoMinimoEncomendaDias,
      'disponivel_venda': disponivelVenda,
      'pronta_entrega': prontaEntrega,
      'aceita_encomenda': aceitaEncomenda,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ========================================
  // ENTITY
  // ========================================

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      ownerId: product.ownerId,
      tipo: product.tipo,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      estoque: product.estoque,
      prazoProducaoDias: product.prazoProducaoDias,
      prazoEntregaHoras: product.prazoEntregaHoras,
      prazoMinimoEncomendaDias: product.prazoMinimoEncomendaDias,
      disponivelVenda: product.disponivelVenda,
      prontaEntrega: product.prontaEntrega,
      aceitaEncomenda: product.aceitaEncomenda,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
