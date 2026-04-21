import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/category.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';

/// Use Case para buscar todas as categorias
class GetCategories extends UseCase<List<Category>, NoParams> {
  final MarketplaceRepository repository;

  GetCategories(this.repository);

  @override
  Future<Result<List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
