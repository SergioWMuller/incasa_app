import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/phone_supabase_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';
import 'package:incasa_app/features/address/view/address_list_view.dart';
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
              // Usa getter do state (lógica no State, não na View)
              if (!authState.isAuthenticated) {
                return const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    'Faça login para acessar suas configurações adicionais',
                  ),
                );
              }

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Cadastro'),
                    subtitle: const Text('Email, Telefone e CPF'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => OnboardingCubit(
                              userSupabaseDataSource:
                                  sl<UserSupabaseDataSource>(),
                              phoneDataSource: sl<PhoneSupabaseDataSource>(),
                              authLocalDataSource: sl<AuthLocalDataSource>(),
                              firebaseUser: authState.user!,
                            ),
                            child: const RegistrationView(),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  const _AddressSection(),
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
            trailing: const Icon(Icons.arrow_forward_ios),
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
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Abrir política de privacidade
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termos de Uso'),
            trailing: const Icon(Icons.arrow_forward_ios),
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

class _AddressSection extends StatefulWidget {
  const _AddressSection();

  @override
  State<_AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<_AddressSection> {
  bool _isExpanded = false;
  late final AddressCubit _addressCubit;

  @override
  void initState() {
    super.initState();
    _addressCubit = sl<AddressCubit>()..initialize();
  }

  @override
  void dispose() {
    _addressCubit.close();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _addressLabel(Address address) {
    return address.label?.isNotEmpty == true
        ? address.label!
        : '${address.street}, ${address.number ?? 'S/N'}';
  }

  Address? _primaryAddress(AddressState state) {
    if (state.addresses.isEmpty) {
      return null;
    }
    final primaryIndex = state.addresses.indexWhere(
      (address) => address.addressId == state.currentPrimaryAddressId,
    );
    return primaryIndex != -1
        ? state.addresses[primaryIndex]
        : state.addresses.first;
  }

  String _primarySubtitle(AddressState state) {
    if (state.isLoading) {
      return 'Carregando endereço principal...';
    }
    if (state.isError) {
      return 'Erro ao carregar endereço principal';
    }
    final primary = _primaryAddress(state);
    if (primary == null) {
      return 'Nenhum endereço cadastrado';
    }

    return 'Principal: ${_addressLabel(primary)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addressCubit,
      child: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final primaryLabel = _primaryAddress(state)?.label;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Row(
                  children: [
                    const Text('Endereços'),
                    Text(
                      primaryLabel?.isNotEmpty == true
                          ? ' - $primaryLabel'
                          : '',
                    ),
                  ],
                ),
                subtitle: Text(_primarySubtitle(state)),
                trailing: Icon(
                  size: 30,
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
                onTap: _toggleExpanded,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (state.isError)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                state.errorMessage ??
                                    'Erro ao carregar endereços',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          else if (state.addresses.isEmpty)
                            Column(
                              children: [
                                const ListTile(
                                  leading: Icon(Icons.location_off),
                                  title: Text('Nenhum endereço cadastrado'),
                                  subtitle: Text(
                                    'Adicione um endereço para habilitar essa opção.',
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Editar'),
                                  subtitle: const Text(
                                    'Abrir lista completa de endereços',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () async {
                                    // AddressListView usa uma instância própria
                                    // do cubit; ao voltar, recarrega a seção de
                                    // Configurações para refletir mudanças
                                    // feitas lá (criar/editar/deletar/trocar
                                    // principal).
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) =>
                                              sl<AddressCubit>()..initialize(),
                                          child: const AddressListView(),
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      await _addressCubit.refresh();
                                    }
                                  },
                                ),
                              ],
                            )
                          else
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...state.addresses.map((address) {
                                  final isPrimary =
                                      address.addressId ==
                                      state.currentPrimaryAddressId;
                                  return ListTile(
                                    leading: Icon(
                                      isPrimary
                                          ? Icons.location_on
                                          : Icons.location_on_outlined,
                                    ),
                                    title: Text(_addressLabel(address)),
                                    subtitle: Text(
                                      '${address.city} - ${address.state}',
                                    ),
                                    trailing: isPrimary
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Principal',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                    onTap: isPrimary
                                        ? null
                                        : () async {
                                            final success = await context
                                                .read<AddressCubit>()
                                                .setPrimaryAddress(
                                                  address.addressId!,
                                                );

                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Endereço ${_addressLabel(address)} definido como principal',
                                                  ),
                                                  backgroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              );
                                              _toggleExpanded();
                                            }
                                          },
                                  );
                                }),
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Editar'),
                                  subtitle: const Text(
                                    'Abrir lista completa de endereços',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () async {
                                    // AddressListView usa uma instância própria
                                    // do cubit; ao voltar, recarrega a seção de
                                    // Configurações para refletir mudanças
                                    // feitas lá (criar/editar/deletar/trocar
                                    // principal).
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) =>
                                              sl<AddressCubit>()..initialize(),
                                          child: const AddressListView(),
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      await _addressCubit.refresh();
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
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
