import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/data/datasources/local/marketplace_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/profile_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/theme_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/marketplace_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/product_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/profile_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
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
import 'package:incasa_app/domain/usecases/my_store/add_product.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_store.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_color.dart';
import 'package:incasa_app/domain/usecases/profile/get_user_profile.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_color.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initializeDependencies() async {
  // ============== Core ==============

  // MVP - Firebase (Auth) ✅
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // MVP - Supabase (Database) ✅
  sl.registerLazySingleton<SupabaseClientWrapper>(
    () => SupabaseClientWrapper(),
  );

  // DioClient para Marketplace/MyStore (até migrar para Supabase) ✅
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Dio para chamadas HTTP simples (CEP, etc)
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
  );

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
    () => MyStoreRemoteDataSourceImpl(productDataSource: sl(), supabase: sl()),
  );

  // ============== Data Sources - Profile ==============
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(authLocalDataSource: sl()),
  );

  // MVP - Firebase (USAR AGORA) ✅
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileFirebaseDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // Futuro - Laravel (descomentar quando migrar) 📦
  // sl.registerLazySingleton<ProfileRemoteDataSource>(
  //   () => ProfileApiDataSourceImpl(sl()),
  // );

  // ============== Data Sources - Theme ==============
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(),
  );

  // ============== Data Sources - Auth ==============
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // ============== Data Sources - User (Supabase) ==============
  sl.registerLazySingleton<UserSupabaseDataSource>(
    () => UserSupabaseDataSourceImpl(supabase: sl()),
  );

  // ============== Data Sources - Product (Supabase) ==============
  sl.registerLazySingleton<ProductSupabaseDataSource>(
    () => ProductSupabaseDataSourceImpl(supabase: sl()),
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
  sl.registerFactory(() => AddProduct(sl()));

  // ============== Use Cases - Profile ==============
  sl.registerFactory(() => GetUserProfile(sl()));

  // ============== Use Cases - Theme ==============
  sl.registerFactory(() => GetThemeMode(sl()));
  sl.registerFactory(() => SaveThemeMode(sl()));
  sl.registerFactory(() => GetThemeColor(sl()));
  sl.registerFactory(() => SaveThemeColor(sl()));

  // ============== Cubits - Auth ==============
  // Singleton pois precisa manter estado de autenticação global
  sl.registerLazySingleton(
    () => AuthCubit(
      authService: sl(),
      authLocalDataSource: sl(),
      userSupabaseDataSource: sl(),
    )..checkAuthStatus(),
  );

  // ============== Cubits - Theme ==============
  // Singleton pois o tema é global na aplicação
  sl.registerLazySingleton(
    () => ThemeCubit(
      getThemeModeUseCase: sl(),
      saveThemeModeUseCase: sl(),
      getThemeColorUseCase: sl(),
      saveThemeColorUseCase: sl(),
    )..loadThemeSettings(),
  );

  // ============== Cubits - Marketplace ==============
  // Singleton para manter cache dos produtos
  sl.registerLazySingleton(
    () => MarketplaceCubit(
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      searchProductsUseCase: sl(),
    )..loadMarketplace(),
  );

  // ============== Cubits - MyStore ==============
  // Singleton para manter estado da loja
  sl.registerLazySingleton(
    () => MyStoreCubit(
      getMyStoreUseCase: sl(),
      getMyProductsUseCase: sl(),
      addProductUseCase: sl(),
    )..loadMyStore(),
  );

  // ============== Cubits - Profile ==============
  // Singleton para manter dados do perfil
  // Nota: loadProfile() é chamado pelo AuthCubit listener quando usuário loga
  sl.registerLazySingleton(() => ProfileCubit(getUserProfileUseCase: sl()));

  // ============== Cubits - Address ==============
  // Factory pois cada tela de cadastro de endereço é independente
  sl.registerFactory(() => AddressCubit(sl()));
}
