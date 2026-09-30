import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/core/network/dio_client.dart';
import 'package:incasa_app/core/network/supabase_rest_dio.dart';
import 'package:incasa_app/core/network/supabase_session.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/data/datasources/local/marketplace_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/my_store_layout_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/profile_local_data_source.dart';
import 'package:incasa_app/data/datasources/local/theme_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/marketplace_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/my_store_layout_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/product_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/profile_remote_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/phone_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/address_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/registration_supabase_data_source.dart';
import 'package:incasa_app/data/repositories/marketplace/marketplace_repository_impl.dart';
import 'package:incasa_app/data/repositories/my_store/my_store_repository_impl.dart';
import 'package:incasa_app/data/repositories/my_store/layout_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/theme_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/address_repository_impl.dart';
import 'package:incasa_app/data/repositories/profile/registration_repository_impl.dart';
import 'package:incasa_app/domain/repositories/marketplace/marketplace_repository.dart';
import 'package:incasa_app/domain/repositories/my_store/my_store_repository.dart';
import 'package:incasa_app/domain/repositories/my_store/layout_repository.dart';
import 'package:incasa_app/domain/repositories/profile/profile_repository.dart';
import 'package:incasa_app/domain/repositories/profile/theme_repository.dart';
import 'package:incasa_app/domain/repositories/profile/address_repository.dart';
import 'package:incasa_app/domain/repositories/profile/registration_repository.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_categories.dart';
import 'package:incasa_app/domain/usecases/marketplace/get_products.dart';
import 'package:incasa_app/domain/usecases/marketplace/search_products.dart';
import 'package:incasa_app/domain/usecases/my_store/add_product.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_products.dart';
import 'package:incasa_app/domain/usecases/my_store/get_my_store.dart';
import 'package:incasa_app/domain/usecases/my_store/get_store_layout.dart';
import 'package:incasa_app/domain/usecases/my_store/save_store_layout.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/get_theme_color.dart';
import 'package:incasa_app/domain/usecases/profile/get_user_profile.dart';
import 'package:incasa_app/domain/usecases/profile/get_registration_info.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_mode.dart';
import 'package:incasa_app/domain/usecases/profile/save_theme_color.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/registration_cubit.dart';
import 'package:incasa_app/core/shell/app_shell_cubit.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/features/chat/cubit/chat_cubit.dart';
import 'package:incasa_app/features/checkout/cubit/pix_cubit.dart';
import 'package:incasa_app/features/home/cubit/home_cubit.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_cubit.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initializeDependencies() async {
  // ============== Core ==============

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // MVP - Firebase (Auth) ✅
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

  // Dio do REST/RPC do Supabase (<SUPABASE_URL>/rest/v1) — padrão para novas
  // chamadas à API. Envia `apikey` + JWT do Supabase do usuário logado.
  sl.registerLazySingleton<Dio>(
    () => createSupabaseRestDio(
      supabaseUrl: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
      accessToken: SupabaseSession.instance.validToken,
    ),
    instanceName: supabaseRestDioName,
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
  sl.registerLazySingleton<MyStoreLayoutLocalDataSource>(
    () => MyStoreLayoutLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<MyStoreLayoutSupabaseDataSource>(
    () => MyStoreLayoutSupabaseDataSourceImpl(),
  );

  // ============== Data Sources - Profile ==============
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(authLocalDataSource: sl()),
  );

  // MVP - Supabase (USAR AGORA) ✅
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileSupabaseDataSourceImpl(
      userSupabaseDataSource: sl(),
      firebaseAuth: sl(),
    ),
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

  // ============== Data Sources - Phone (Supabase) ==============
  sl.registerLazySingleton<PhoneSupabaseDataSource>(
    () => PhoneSupabaseDataSourceImpl(supabase: sl()),
  );

  // ============== Data Sources - Address (Supabase) ==============
  sl.registerLazySingleton<AddressSupabaseDataSource>(
    () => AddressSupabaseDataSourceImpl(supabase: sl()),
  );

  // ============== Data Sources - Registration (Supabase RPC) ==============
  sl.registerLazySingleton<RegistrationSupabaseDataSource>(
    () => RegistrationSupabaseDataSourceImpl(
      dio: sl<Dio>(instanceName: supabaseRestDioName),
    ),
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
    () => MyStoreRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<LayoutRepository>(
    () => LayoutRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // ============== Repositories - Profile ==============
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // ============== Repositories - Address ==============
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(dataSource: sl()),
  );

  // ============== Repositories - Registration ==============
  sl.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(dataSource: sl()),
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
  sl.registerFactory(() => GetStoreLayout(sl()));
  sl.registerFactory(() => SaveStoreLayout(sl()));

  // ============== Use Cases - Profile ==============
  sl.registerFactory(() => GetUserProfile(sl()));
  sl.registerFactory(() => GetRegistrationInfo(sl()));

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
  // Factory pois cada tela de endereço é independente (formulário ou lista)
  sl.registerFactory(() => AddressCubit(sl(), sl(), sl(), sl()));

  // ============== Cubits - Registration ==============
  // Factory pois é uma tela empilhada (Configurações > Minha Conta) — cada
  // abertura recarrega os dados.
  sl.registerFactory(
    () => RegistrationCubit(getRegistrationInfoUseCase: sl()),
  );

  // ============== Cubits - EditarLoja ==============
  // Factory pois é uma tela empilhada (precedente: AddressCubit) — cada
  // abertura da EditarLojaView começa com um estado limpo.
  sl.registerFactory(
    () => EditarLojaCubit(
      getStoreLayoutUseCase: sl(),
      saveStoreLayoutUseCase: sl(),
      getMyProductsUseCase: sl(),
    ),
  );

  // ============== Design Handoff (provisório, mock) ==============
  // Telas do design_handoff_incasa. Na fase de mesclagem, o mock dará lugar
  // aos usecases/repositories reais das features existentes.
  sl.registerLazySingleton<DesignMockDataSource>(
    () => DesignMockDataSourceImpl(),
  );

  // Cubit do shell (tab selecionada)
  sl.registerLazySingleton(() => AppShellCubit());

  // Cubits de tab — singletons como os demais cubits de tab
  sl.registerLazySingleton(() => HomeCubit(mockDataSource: sl())..loadHome());
  sl.registerLazySingleton(() => SellCubit(myStoreCubit: sl()));
  sl.registerLazySingleton(
    () => ChatCubit(mockDataSource: sl())..loadThreads(),
  );

  // Cubits de telas empilhadas — factory (precedente: AddressCubit)
  sl.registerFactory(() => ProductDetailCubit(mockDataSource: sl()));
  sl.registerFactory(() => SellerStoreCubit(mockDataSource: sl()));
  sl.registerFactory(() => PixCubit(mockDataSource: sl()));

  // ============== Geolocator ==============
  sl.registerLazySingleton<GeolocatorPlatform>(
    () => GeolocatorPlatform.instance,
  );
}
