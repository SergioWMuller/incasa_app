import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';
import 'package:incasa_app/core/theme/theme_cubit.dart';
import 'package:incasa_app/features/profile/widgets/theme_slide_selector_widget.dart';
import 'package:incasa_app/features/profile/widgets/color_slide_selector_widget.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';

class ProfileMenuWidget extends StatefulWidget {
  final bool showLogout;
  final bool isAuthenticated;

  const ProfileMenuWidget({
    super.key,
    this.showLogout = false,
    this.isAuthenticated = false,
  });

  @override
  State<ProfileMenuWidget> createState() => _ProfileMenuWidgetState();
}

class _ProfileMenuWidgetState extends State<ProfileMenuWidget>
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
    context.read<ThemeCubit>().changeThemeMode(mode);
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
    context.read<ThemeCubit>().changeThemeColor(color);
    _toggleColorSelector();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.chat),
          title: const Text('Conversas'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para conversas
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificações'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para notificações
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Pagamentos'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para pagamentos
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Favoritos'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para favoritos
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Endereços'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para endereços
          },
        ),
        const Divider(),
        BlocBuilder<ThemeCubit, ThemeState>(
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
        const Divider(),
        BlocBuilder<ThemeCubit, ThemeState>(
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
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Ajuda'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para ajuda
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Navegar para configurações
          },
        ),
        const Divider(),
        if (widget.showLogout && widget.isAuthenticated)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Captura o AuthCubit antes de abrir o dialog
              final authCubit = context.read<AuthCubit>();

              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Confirmar logout'),
                  content: const Text(
                    'Você tem certeza que deseja sair da sua conta?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        print('🔘 Botão Sair pressionado no dialog');
                        Navigator.of(dialogContext).pop();
                        authCubit.signOut();
                      },
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (widget.showLogout && widget.isAuthenticated) const Divider(),
      ],
    );
  }
}
