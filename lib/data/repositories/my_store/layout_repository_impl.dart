import 'package:incasa_app/core/error/failures.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_layout_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_layout_supabase_data_source.dart';
import 'package:incasa_app/data/models/my_store/store_layout_model.dart';
import 'package:incasa_app/domain/entities/my_store/store_layout.dart';
import 'package:incasa_app/domain/repositories/my_store/layout_repository.dart';

class LayoutRepositoryImpl implements LayoutRepository {
  final MyStoreLayoutLocalDataSource localDataSource;
  final MyStoreLayoutSupabaseDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  LayoutRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  Future<String?> _resolveOwnerId() async {
    final userData = await authLocalDataSource.getUserData();
    return userData?['id'] as String?;
  }

  @override
  Future<Result<StoreLayout?>> getLocalLayout() async {
    try {
      final layout = await localDataSource.getLayout();
      return Success(layout);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveLocalLayout(StoreLayout layout) async {
    try {
      await localDataSource.saveLayout(StoreLayoutModel.fromEntity(layout));
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<String?>> getRemoteVersion() async {
    try {
      final ownerId = await _resolveOwnerId();
      if (ownerId == null) {
        return Error(UnexpectedFailure('Usuário não autenticado'));
      }
      final version = await remoteDataSource.getVersion(ownerId);
      return Success(version);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<StoreLayout>> getRemoteLayout() async {
    try {
      final ownerId = await _resolveOwnerId();
      if (ownerId == null) {
        return Error(UnexpectedFailure('Usuário não autenticado'));
      }
      final layout = await remoteDataSource.getLayout(ownerId);
      return Success(layout);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveRemoteLayout(StoreLayout layout) async {
    try {
      final ownerId = await _resolveOwnerId();
      if (ownerId == null) {
        return Error(UnexpectedFailure('Usuário não autenticado'));
      }
      await remoteDataSource.saveLayout(
        ownerId,
        StoreLayoutModel.fromEntity(layout),
      );
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
