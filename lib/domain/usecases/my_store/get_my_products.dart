import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';

class GetMyProducts extends UseCase<List<Product>, NoParams> {
  final MyStoreRepository repository;

  GetMyProducts(this.repository);

  @override
  Future<Result<List<Product>>> call(NoParams params) async {
    return await repository.getMyProducts();
  }
}
