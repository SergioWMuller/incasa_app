import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/theme/app_theme.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/core/widgets/app_shell.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente do .env
  await dotenv.load(fileName: ".env");

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
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
