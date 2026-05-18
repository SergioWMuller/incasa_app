import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/marketplace/view/marketplace_view.dart';
import 'package:incasa_app/features/my_store/view/my_store_view.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_state.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, authState) {
        // Quando o usuário faz logout, limpa o estado do perfil
        if (authState.isUnauthenticated) {
          sl<ProfileCubit>().clearProfile();
        }
        // Quando o usuário faz login, recarrega o perfil
        else if (authState.isAuthenticated) {
          // Evita reload se já estiver carregando ou já carregado
          final profileState = sl<ProfileCubit>().state;
          if (profileState.status != ProfileStatus.loaded) {
            sl<ProfileCubit>().loadProfile();
          }
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
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Vitrine'),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Minha Loja',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
