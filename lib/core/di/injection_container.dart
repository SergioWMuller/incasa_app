import 'package:get_it/get_it.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/data/datasources/local/marketplace_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/profile_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/theme_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/marketplace_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/profile_remote_data_source.dart';
import 'package:incasa_app/data/repositories/marketplace/marketplace_repository_impl.dart';
import 'package:incasa_app/data/repositories/my_store/my_store_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/theme_repository_impl.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';
import 'package:incasa_app/domain/repositories/profile/profile_repository.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_categories.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_products.dart';
import 'package:incasa_app/domain/usecases/marketplace/search_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_store.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/get_user_profile.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_mode.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initializeDependencies() async {
  // ============== Core ==============
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // ============== Data Sources - Marketplace ==============
  sl.registerLazySingleton<MarketplaceLocalDataSource>(
    () => MarketplaceLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(sl()),
  );

  // ============== Data Sources - MyStore ==============
  sl.registerLazySingleton<MyStoreLocalDataSource>(
    () => MyStoreLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<MyStoreRemoteDataSource>(
    () => MyStoreRemoteDataSourceImpl(sl()),
  );

  // ============== Data Sources - Profile ==============
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // ============== Data Sources - Theme ==============
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(),
  );

  // ============== Repositories - Marketplace ==============
  sl.registerLazySingleton<MarketplaceRepository>(
    () => MarketplaceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ============== Repositories - MyStore ==============
  sl.registerLazySingleton<MyStoreRepository>(
    () => MyStoreRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // ============== Repositories - Profile ==============
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // ============== Repositories - Theme ==============
  sl.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()));

  // ============== Use Cases - Marketplace ==============
  // Use Cases são stateless, não precisam ser singleton
  sl.registerFactory(() => GetProducts(sl()));
  sl.registerFactory(() => GetCategories(sl()));
  sl.registerFactory(() => SearchProducts(sl()));

  // ============== Use Cases - MyStore ==============
  sl.registerFactory(() => GetMyStore(sl()));
  sl.registerFactory(() => GetMyProducts(sl()));

  // ============== Use Cases - Profile ==============
  sl.registerFactory(() => GetUserProfile(sl()));

  // ============== Use Cases - Theme ==============
  sl.registerFactory(() => GetThemeMode(sl()));
  sl.registerFactory(() => SaveThemeMode(sl()));

  // ============== Cubits - Marketplace ==============
  sl.registerFactory(
    () => MarketplaceCubit(
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      searchProductsUseCase: sl(),
    ),
  );

  // ============== Cubits - MyStore ==============
  sl.registerFactory(
    () => MyStoreCubit(getMyStoreUseCase: sl(), getMyProductsUseCase: sl()),
  );

  // ============== Cubits - Profile ==============
  sl.registerFactory(() => ProfileCubit(getUserProfileUseCase: sl()));

  // ============== Cubits - Auth ==============
  sl.registerFactory(() => AuthCubit(authService: sl()));

  // ============== Cubits - Theme ==============
  sl.registerFactory(
    () => ThemeCubit(getThemeModeUseCase: sl(), saveThemeModeUseCase: sl()),
  );
}
