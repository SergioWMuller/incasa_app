import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';

/// Use Case para buscar todos os produtos
class GetProducts extends UseCase<List<Product>, NoParams> {
  final MarketplaceRepository repository;

  GetProducts(this.repository);

  @override
  Future<Result<List<Product>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}
