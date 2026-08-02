import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/my_store/store_layout.dart';

/// Repository interface para o layout customizável da `EditarLojaView`.
abstract class LayoutRepository {
  Future<Result<StoreLayout?>> getLocalLayout();
  Future<Result<void>> saveLocalLayout(StoreLayout layout);

  /// Consulta apenas a versão remota (query leve, sem baixar o jsonb inteiro
  /// — ai/EDITAR_LOJA_VIEW.md §8.2).
  ///
  /// TODO: o schema da tabela de layout ainda não foi definido no Supabase
  /// (ver ai/EDITAR_LOJA_VIEW.md §8.5). Enquanto isso, sempre retorna
  /// `Success(null)`, tratado pelos usecases como "sem contraparte remota" —
  /// o fluxo opera 100% local até a tabela existir.
  Future<Result<String?>> getRemoteVersion();

  Future<Result<StoreLayout>> getRemoteLayout();

  Future<Result<void>> saveRemoteLayout(StoreLayout layout);
}
