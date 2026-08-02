import 'package:incasa_app/data/models/my_store/store_layout_model.dart';

/// Data Source remota (Supabase) para o layout da `EditarLojaView`.
///
/// TODO: a tabela de layout ainda não existe no banco — o schema definitivo
/// (nome, colunas jsonb/version, RLS) será definido em etapa posterior
/// (ai/EDITAR_LOJA_VIEW.md §8.5). Até lá, esta implementação não tem
/// contraparte remota real: `getVersion` reporta "sem versão remota" e as
/// demais operações falham explicitamente em vez de gravar num schema
/// inventado.
abstract class MyStoreLayoutSupabaseDataSource {
  Future<String?> getVersion(String ownerId);
  Future<StoreLayoutModel> getLayout(String ownerId);
  Future<void> saveLayout(String ownerId, StoreLayoutModel layout);
}

class MyStoreLayoutSupabaseDataSourceImpl
    implements MyStoreLayoutSupabaseDataSource {
  @override
  Future<String?> getVersion(String ownerId) async {
    return null;
  }

  @override
  Future<StoreLayoutModel> getLayout(String ownerId) async {
    throw UnimplementedError(
      'Persistência remota do layout ainda não implementada (schema pendente '
      '— ver ai/EDITAR_LOJA_VIEW.md §8.5)',
    );
  }

  @override
  Future<void> saveLayout(String ownerId, StoreLayoutModel layout) async {
    throw UnimplementedError(
      'Persistência remota do layout ainda não implementada (schema pendente '
      '— ver ai/EDITAR_LOJA_VIEW.md §8.5)',
    );
  }
}
