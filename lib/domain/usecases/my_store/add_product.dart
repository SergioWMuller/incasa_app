import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';

class AddProduct extends UseCase<Product, AddProductParams> {
  final MyStoreRepository repository;

  AddProduct(this.repository);

  @override
  Future<Result<Product>> call(AddProductParams params) async {
    return await repository.addProduct(params.product);
  }
}

class AddProductParams {
  final Product product;

  const AddProductParams({required this.product});
}
