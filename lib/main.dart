import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/supabase_session.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/core/widgets/app_shell.dart';
import 'package:incasa_app/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente do .env
  await dotenv.load(fileName: ".env");
 
  // Valida env do Supabase antes da inicialização para evitar erros 401 difusos.

  SupabaseConstants.validateEnvOrThrow();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa Supabase.
  //
  // `accessToken` faz o cliente enviar o JWT do Supabase do usuário logado
  // (emitido pela Edge Function `auth-firebase`) em cada chamada — é o que
  // permite às policies por `app_user_id()` resolverem o usuário. Quando ainda
  // não há JWT, retorna null e o cliente usa a anon key.
  //
  // Obs.: ao usar `accessToken`, o GoTrue (Supabase Auth) fica desativado —
  // a identidade vem do Firebase, não de `client.auth`.
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
    accessToken: () async => SupabaseSession.instance.validToken(),
  );

  // Inicializa DI (Get_it)
  await initializeDependencies();

  runApp(const InCasaApp());
}

// sergio muller
class InCasaApp extends StatelessWidget {
  const InCasaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'InCasa App',
            theme: AppTheme.lightTheme(themeState.color),
            darkTheme: AppTheme.darkTheme(themeState.color),
            themeMode: _getThemeMode(themeState.mode),
            home: const AppShell(),
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode appMode) {
    switch (appMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
