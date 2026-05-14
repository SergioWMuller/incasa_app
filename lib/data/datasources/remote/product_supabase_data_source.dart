import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/models/marketplace/product_model.dart';

/// DataSource para operações de produtos no Supabase
///
/// Endpoint base: https://rhmmjsjbvfivtathuviv.supabase.co/rest/v1/products
abstract class ProductSupabaseDataSource {
  /// Busca todos os produtos do vendedor logado
  Future<List<ProductModel>> getMyProducts(String ownerId);

  /// Cria novo produto
  Future<ProductModel> createProduct(ProductModel product, String ownerId);

  /// Atualiza produto existente
  Future<ProductModel> updateProduct(String productId, ProductModel product);

  /// Deleta produto
  Future<void> deleteProduct(String productId);

  /// Busca produto por ID
  Future<ProductModel?> getProductById(String productId);
}

class ProductSupabaseDataSourceImpl implements ProductSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  ProductSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<ProductModel>> getMyProducts(String ownerId) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.productsTable)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      return (response as List)
          .map((json) => ProductModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos no Supabase: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(
    ProductModel product,
    String ownerId,
  ) async {
    try {
      final data = product.toSupabase();
      data['owner_id'] = ownerId; // Adiciona o owner_id

      final response = await supabase
          .from(SupabaseConstants.productsTable)
          .insert(data)
          .select()
          .single();

      return ProductModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao criar produto no Supabase: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(
    String productId,
    ProductModel product,
  ) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.productsTable)
          .update(product.toSupabase())
          .eq('id', productId)
          .select()
          .single();

      return ProductModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao atualizar produto no Supabase: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await supabase
          .from(SupabaseConstants.productsTable)
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Erro ao deletar produto no Supabase: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.productsTable)
          .select()
          .eq('id', productId)
          .maybeSingle();

      if (response == null) return null;

      return ProductModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Erro ao buscar produto no Supabase: $e');
    }
  }
}
