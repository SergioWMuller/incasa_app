import 'package:equatable/equatable.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';

/// Parâmetros para buscar produtos por categoria
class SearchParams extends Equatable {
  final String query;

  const SearchParams(this.query);

  @override
  List<Object?> get props => [query];
}

/// Use Case para buscar produtos
class SearchProducts extends UseCase<List<Product>, SearchParams> {
  final MarketplaceRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Result<List<Product>>> call(SearchParams params) async {
    return await repository.searchProducts(params.query);
  }
}
