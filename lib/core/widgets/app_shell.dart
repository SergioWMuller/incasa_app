import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/shell/app_shell_cubit.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/chat/view/chat_view.dart';
import 'package:incasa_app/features/home/view/home_view.dart';
import 'package:incasa_app/features/my_store/view/my_store_view.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/view/onboarding_view.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_state.dart';
import 'package:incasa_app/features/profile/view/profile_view.dart';

/// Shell principal do app com BottomNavigationBar.
///
/// Navegação principal: Início, Minha Loja, Chat e Perfil. O "Vender" (wizard)
/// fica na aba Adicionar de Minha Loja; a busca vive no campo do Início.
/// Stateful apenas pelo guard do onboarding; a tab selecionada vive no
/// AppShellCubit.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Evita empilhar o wizard de onboarding mais de uma vez.
  bool _onboardingRouteOpen = false;

  /// Empurra o wizard de onboarding (3 etapas) com seu próprio OnboardingCubit.
  /// Ao retornar, reavalia o status para limpar `needsOnboarding`.
  Future<void> _openOnboarding(BuildContext context, User firebaseUser) async {
    _onboardingRouteOpen = true;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OnboardingCubit(
            userSupabaseDataSource: sl(),
            phoneDataSource: sl(),
            authLocalDataSource: sl(),
            firebaseUser: firebaseUser,
          ),
          child: const OnboardingView(),
        ),
      ),
    );
    _onboardingRouteOpen = false;
    await sl<AuthCubit>().refreshOnboardingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, authState) async {
        // Quando o usuário faz logout, limpa o estado do perfil
        if (authState.isUnauthenticated) {
          _onboardingRouteOpen = false;
          sl<ProfileCubit>().clearProfile();
        }
        // Quando o usuário faz login, recarrega o perfil
        else if (authState.isAuthenticated) {
          // Evita reload se já estiver carregando ou já carregado
          final profileState = sl<ProfileCubit>().state;
          if (profileState.status != ProfileStatus.loaded) {
            sl<ProfileCubit>().loadProfile();
          }

          // Cadastro incompleto → abre o wizard de onboarding.
          if (authState.needsOnboarding && !_onboardingRouteOpen) {
            _openOnboarding(context, authState.user!);
          }
        }
      },
      child: BlocBuilder<AppShellCubit, AppShellState>(
        bloc: sl<AppShellCubit>(),
        builder: (context, shellState) {
          return Scaffold(
            appBar: AppBar(title: const Text('inCasa'), centerTitle: true),
            body: IndexedStack(
              index: shellState.selectedIndex,
              children: [
                // Novo design (design_handoff_incasa)
                const HomeView(),
                MyStoreView(key: ValueKey(shellState.selectedIndex == 1)),
                const ChatView(),
                const ProfileView(),
              ],
            ),
            bottomNavigationBar: NeumorphicSurface(
              depth: 4,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                currentIndex: shellState.selectedIndex,
                onTap: (index) => sl<AppShellCubit>().selectTab(index),
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 10,
                unselectedFontSize: 9,
                elevation: 0,
                backgroundColor: Colors.transparent,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Início',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: 'Minha Loja',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
