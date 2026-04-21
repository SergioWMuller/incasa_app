import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';

class GetMyStore extends UseCase<Store, NoParams> {
  final MyStoreRepository repository;

  GetMyStore(this.repository);

  @override
  Future<Result<Store>> call(NoParams params) async {
    return await repository.getMyStore();
  }
}
