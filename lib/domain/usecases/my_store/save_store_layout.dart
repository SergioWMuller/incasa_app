import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/my_store/store_layout.dart';
import 'package:incasa_app/domain/repositories/my_store/layout_repository.dart';

enum SaveLayoutStatus { salvo, conflito }

class SaveLayoutResult {
  final SaveLayoutStatus status;
  final StoreLayout layout;

  const SaveLayoutResult({required this.status, required this.layout});
}

class SaveStoreLayoutParams {
  final StoreLayout layout;
  final String? versaoCarregada;
  final bool sobrescrever;
  final String Function() gerarNovaVersao;

  const SaveStoreLayoutParams({
    required this.layout,
    required this.versaoCarregada,
    required this.gerarNovaVersao,
    this.sobrescrever = false,
  });
}

/// Implementa o fluxo de salvamento com checagem de conflito de
/// ai/EDITAR_LOJA_VIEW.md §8.3.
///
/// Sem contraparte remota ainda (schema pendente — ver `LayoutRepository`),
/// `getRemoteVersion()` sempre retorna null, então nenhum conflito é
/// detectado por enquanto: o salvamento sempre segue o fluxo normal (a). A
/// lógica de conflito já fica pronta para quando o schema remoto existir.
class SaveStoreLayout extends UseCase<SaveLayoutResult, SaveStoreLayoutParams> {
  final LayoutRepository repository;

  SaveStoreLayout(this.repository);

  @override
  Future<Result<SaveLayoutResult>> call(SaveStoreLayoutParams params) async {
    final remoteVersionResult = await repository.getRemoteVersion();
    final remoteVersion = switch (remoteVersionResult) {
      Success(:final data) => data,
      Error() => null,
    };

    final houveEdicaoConcorrente =
        remoteVersion != null && remoteVersion != params.versaoCarregada;

    if (houveEdicaoConcorrente && !params.sobrescrever) {
      return Success(
        SaveLayoutResult(
          status: SaveLayoutStatus.conflito,
          layout: params.layout,
        ),
      );
    }

    final layoutParaSalvar = params.layout.copyWith(
      version: params.gerarNovaVersao(),
    );

    final localSaveResult = await repository.saveLocalLayout(
      layoutParaSalvar,
    );
    if (localSaveResult case Error(:final failure)) {
      return Error(failure);
    }

    // Persistência remota é melhor-esforço: falha aqui (schema ainda
    // pendente) não deve derrubar o salvamento local já concluído.
    await repository.saveRemoteLayout(layoutParaSalvar);

    return Success(
      SaveLayoutResult(
        status: SaveLayoutStatus.salvo,
        layout: layoutParaSalvar,
      ),
    );
  }
}
