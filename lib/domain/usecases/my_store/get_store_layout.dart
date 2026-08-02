import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/my_store/store_layout.dart';
import 'package:incasa_app/domain/repositories/my_store/layout_repository.dart';

/// Resolve qual layout usar seguindo o fluxo de comparação de versão de
/// ai/EDITAR_LOJA_VIEW.md §8.2: só busca o documento remoto completo quando a
/// versão local está desatualizada. Sem contraparte remota (schema pendente),
/// sempre usa o cache local — ou um layout vazio, se não houver cache ainda.
class GetStoreLayout extends UseCase<StoreLayout, NoParams> {
  final LayoutRepository repository;

  GetStoreLayout(this.repository);

  @override
  Future<Result<StoreLayout>> call(NoParams params) async {
    final localResult = await repository.getLocalLayout();
    final local = switch (localResult) {
      Success(:final data) => data,
      Error() => null,
    };

    final remoteVersionResult = await repository.getRemoteVersion();
    final remoteVersion = switch (remoteVersionResult) {
      Success(:final data) => data,
      Error() => null,
    };

    if (remoteVersion == null) {
      return Success(local ?? StoreLayout.vazio());
    }

    if (local != null && local.version == remoteVersion) {
      return Success(local);
    }

    return await repository.getRemoteLayout();
  }
}
