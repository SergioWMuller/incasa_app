import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/marketplace/view/marketplace_view.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/my_store/view/my_store_view.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/profile/view/profile_view.dart';

/// Shell principal do app com BottomNavigationBar
/// Contém as 3 principais telas: Marketplace, MyStore, Profile
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Cubits mantidos vivos durante toda a vida do AppShell
  late final AuthCubit _authCubit;
  late final MarketplaceCubit _marketplaceCubit;
  late final MyStoreCubit _myStoreCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>()..checkAuthStatus();
    _marketplaceCubit = sl<MarketplaceCubit>()..loadMarketplace();
    _myStoreCubit = sl<MyStoreCubit>()..loadMyStore();
    _profileCubit = sl<ProfileCubit>()..loadProfile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authCubit.close();
    _marketplaceCubit.close();
    _myStoreCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _marketplaceCubit),
        BlocProvider.value(value: _myStoreCubit),
        BlocProvider.value(value: _profileCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          // Quando o usuário faz logout, limpa o estado do perfil
          if (authState is AuthUnauthenticated) {
            print('🔄 Usuário deslogado - limpando estado do perfil');
            _profileCubit.clearProfile();
          }
          // Quando o usuário faz login, recarrega o perfil
          else if (authState is AuthAuthenticated) {
            print('🔄 Usuário logado - carregando perfil');
            _profileCubit.loadProfile();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('InCasa'), centerTitle: true),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const [MarketplaceView(), MyStoreView(), ProfileView()],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Vitrine',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Minha Loja',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
