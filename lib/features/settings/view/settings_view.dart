import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/view/address_view.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/view/registration_view.dart';
import 'package:incasa_app/features/profile/widgets/theme_slide_selector_widget.dart';
import 'package:incasa_app/features/profile/widgets/color_slide_selector_widget.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // Seção: Meus Dados
          _SectionHeader(title: 'Meus Dados'),

          BlocBuilder<AuthCubit, AuthState>(
            bloc: sl<AuthCubit>(),
            builder: (context, authState) {
              final isAuthenticated =
                  authState.status == AuthStatus.authenticated;
              final user = authState.user;

              if (!isAuthenticated || user == null) {
                return const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Faça login para acessar suas configurações'),
                );
              }

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Cadastro'),
                    subtitle: const Text('Email, Telefone e CPF'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => OnboardingCubit(
                              userSupabaseDataSource:
                                  sl<UserSupabaseDataSource>(),
                              authLocalDataSource: sl<AuthLocalDataSource>(),
                              firebaseUser: user,
                            ),
                            child: const RegistrationView(),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Endereço'),
                    subtitle: const Text('Editar endereço'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<AddressCubit>(),
                            child: const AddressView(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // Seção: Aparência
          _SectionHeader(title: 'Aparência'),
          const _AppearanceSection(),

          const Divider(),

          // Seção: Sobre
          _SectionHeader(title: 'Sobre'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre o App'),
            subtitle: const Text('Versão 0.1.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'inCasa',
                applicationVersion: '0.1.0',
                applicationLegalese: '© 2026 inCasa App',
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Abrir política de privacidade
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termos de Uso'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Abrir termos de uso
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatefulWidget {
  const _AppearanceSection();

  @override
  State<_AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<_AppearanceSection>
    with TickerProviderStateMixin {
  bool _isThemeSelectorExpanded = false;
  bool _isColorSelectorExpanded = false;
  late AnimationController _slideController;
  late AnimationController _colorSlideController;
  late Animation<Offset> _mainTileSlideAnimation;
  late Animation<Offset> _colorTileSlideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _colorSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _mainTileSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _colorTileSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(
            parent: _colorSlideController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _colorSlideController.dispose();
    super.dispose();
  }

  void _toggleThemeSelector() {
    setState(() {
      _isThemeSelectorExpanded = !_isThemeSelectorExpanded;
      if (_isThemeSelectorExpanded) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  void _handleThemeSelection(AppThemeMode mode) {
    sl<ThemeCubit>().changeThemeMode(mode);
    _toggleThemeSelector();
  }

  void _toggleColorSelector() {
    setState(() {
      _isColorSelectorExpanded = !_isColorSelectorExpanded;
      if (_isColorSelectorExpanded) {
        _colorSlideController.forward();
      } else {
        _colorSlideController.reverse();
      }
    });
  }

  void _handleColorSelection(AppThemeColor color) {
    sl<ThemeCubit>().changeThemeColor(color);
    _toggleColorSelector();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ThemeCubit, ThemeState>(
          bloc: sl<ThemeCubit>(),
          builder: (context, themeState) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isThemeSelectorExpanded)
                    ClipRect(
                      child: SlideTransition(
                        position: _mainTileSlideAnimation,
                        child: ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: const Text('Modo'),
                          subtitle: Text(themeState.mode.displayName),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _toggleThemeSelector,
                        ),
                      ),
                    ),
                  if (_isThemeSelectorExpanded)
                    ThemeSlideSelectorWidget(
                      currentMode: themeState.mode,
                      onModeSelected: _handleThemeSelection,
                      onCollapse: _toggleThemeSelector,
                    ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        BlocBuilder<ThemeCubit, ThemeState>(
          bloc: sl<ThemeCubit>(),
          builder: (context, themeState) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isColorSelectorExpanded)
                    ClipRect(
                      child: SlideTransition(
                        position: _colorTileSlideAnimation,
                        child: ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: themeState.color.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: const Text('Cor do Tema'),
                          subtitle: Text(themeState.color.displayName),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _toggleColorSelector,
                        ),
                      ),
                    ),
                  if (_isColorSelectorExpanded)
                    ColorSlideSelectorWidget(
                      currentColor: themeState.color,
                      onColorSelected: _handleColorSelection,
                      onCollapse: _toggleColorSelector,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
