import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/features/profile/cubit/profile_state.dart';
import 'package:incasa_app/features/profile/widgets/profile_loaded_widget.dart';
import 'package:incasa_app/features/profile/widgets/profile_auth_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, authState) {
        if (authState.isUnauthenticated) {
          sl<ProfileCubit>().setOnboardingPhase(false);
          sl<ProfileCubit>().clearProfile();
        } else if (authState.isAuthenticated) {
          sl<ProfileCubit>().setOnboardingPhase(false);
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
    );
  }
}
