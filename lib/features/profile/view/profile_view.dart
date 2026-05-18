import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/data/datasources/local/auth_local_data_source.dart';
import 'package:incasa_app/data/datasources/remote/user_supabase_data_source.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/view/onboarding_view.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_state.dart';
import 'package:incasa_app/features/profile/widgets/profile_loaded_widget.dart';
import 'package:incasa_app/features/profile/widgets/profile_auth_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthStateManager(
      child: BlocListener<AuthCubit, AuthState>(
        bloc: sl<AuthCubit>(),
        listener: (context, authState) async {
          final stateManager = context
              .findAncestorStateOfType<_AuthStateManagerState>();

          if (authState.isUnauthenticated) {
            sl<ProfileCubit>().clearProfile();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logout realizado com sucesso!')),
            );
          } else if (authState.isAuthenticated) {
            // Só navega se ainda não navegou nesta sessão
            if (stateManager != null &&
                !stateManager._hasNavigatedToOnboarding &&
                authState.user != null) {
              // Marca antes de navegar para evitar múltiplas chamadas
              stateManager._markAsNavigated();

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => OnboardingCubit(
                      userSupabaseDataSource: sl<UserSupabaseDataSource>(),
                      authLocalDataSource: sl<AuthLocalDataSource>(),
                      firebaseUser: authState.user!,
                    ),
                    child: const OnboardingView(),
                  ),
                ),
              );

              if (context.mounted) {
                // Carrega o perfil após retornar do onboarding
                sl<ProfileCubit>().loadProfile();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result == true
                          ? '✅ Cadastro completo!'
                          : 'Bem-vindo! Você pode completar seu cadastro depois.',
                    ),
                  ),
                );
              }
            }
          } else if (authState.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.errorMessage ?? 'Erro desconhecido'),
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: sl<AuthCubit>(),
          builder: (context, authState) {
            // Se não está autenticado, mostrar tela de login
            if (!authState.isAuthenticated) {
              return ProfileAuthWidget(authState: authState);
            }

            // Se autenticado, mostrar o perfil com dados
            final firebaseUser = authState.user!;
            return BlocBuilder<ProfileCubit, ProfileState>(
              bloc: sl<ProfileCubit>(),
              builder: (context, profileState) {
                return switch (profileState.status) {
                  ProfileStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ProfileStatus.loaded => ProfileLoadedWidget(
                    user: profileState.user!,
                    firebaseUser: firebaseUser,
                  ),
                  ProfileStatus.error => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar perfil',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(profileState.errorMessage ?? 'Erro desconhecido'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => sl<ProfileCubit>().loadProfile(),
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                };
              },
            );
          },
        ),
      ),
    );
  }
}

/// Widget auxiliar para gerenciar estado de navegação ao onboarding
/// Previne múltiplas navegações na mesma sessão
class _AuthStateManager extends StatefulWidget {
  final Widget child;

  const _AuthStateManager({required this.child});

  @override
  State<_AuthStateManager> createState() => _AuthStateManagerState();
}

class _AuthStateManagerState extends State<_AuthStateManager> {
  bool _hasNavigatedToOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Carrega o perfil se usuário já estiver autenticado
    final authState = sl<AuthCubit>().state;

    if (authState.isAuthenticated) {
      final profileState = sl<ProfileCubit>().state;
      if (profileState.status == ProfileStatus.loading) {
        sl<ProfileCubit>().loadProfile();
      }
      // Marca como já navegado se já estiver autenticado no init
      _hasNavigatedToOnboarding = true;
    }
  }

  void _markAsNavigated() {
    setState(() {
      _hasNavigatedToOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, state) {
        // Reset flag quando usuário desloga
        if (state.isUnauthenticated) {
          setState(() {
            _hasNavigatedToOnboarding = false;
          });
        }
      },
      child: widget.child,
    );
  }
}
