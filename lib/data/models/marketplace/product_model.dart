import 'package:incasa_app/domain/entities/marketplace/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.tipo,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.category,
    super.estoque,
    super.prazoProducaoDias,
    super.prazoEntregaHoras,
    super.prazoMinimoEncomendaDias,
    super.disponivelVenda = true,
    super.prontaEntrega = true,
    super.aceitaEncomenda = false,
    required super.createdAt,
  });

  // Criar ProductModel a partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      tipo: json['tipo'] as String? ?? 'produto',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      estoque: json['estoque'] as int?,
      prazoProducaoDias: json['prazoProducaoDias'] as int?,
      prazoEntregaHoras: json['prazoEntregaHoras'] as int?,
      prazoMinimoEncomendaDias: json['prazoMinimoEncomendaDias'] as int?,
      disponivelVenda: json['disponivelVenda'] as bool? ?? true,
      prontaEntrega: json['prontaEntrega'] as bool? ?? true,
      aceitaEncomenda: json['aceitaEncomenda'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created'] as String? ?? json['createdAt'] as String,
      ),
    );
  }

  // Converter ProductModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'estoque': estoque,
      'prazoProducaoDias': prazoProducaoDias,
      'prazoEntregaHoras': prazoEntregaHoras,
      'prazoMinimoEncomendaDias': prazoMinimoEncomendaDias,
      'disponivelVenda': disponivelVenda,
      'prontaEntrega': prontaEntrega,
      'aceitaEncomenda': aceitaEncomenda,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Converter Entity para Model
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
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
    );
  }

  // Criar ProductModel a partir do Supabase
  factory ProductModel.fromSupabase(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
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
    );
  }

  // Converter ProductModel para Supabase (para INSERT/UPDATE)
  Map<String, dynamic> toSupabase() {
    return {
      // Não incluir 'id' no insert (será gerado pelo Supabase)
      // Incluir apenas em updates
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
      // created_at e updated_at são gerenciados pelo Supabase
    };
  }
}
