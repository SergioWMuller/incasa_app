import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout realizado com sucesso!')),
          );
        } else if (authState is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
        } else if (authState is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(authState.message)));
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          // Se não está autenticado, mostrar tela de login
          if (authState is! AuthAuthenticated) {
            return ProfileAuthWidget(authState: authState);
          }

          // Se autenticado, mostrar o perfil com dados
          final firebaseUser = (authState as AuthAuthenticated).user;
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return switch (profileState) {
                ProfileLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ProfileLoaded(:final user) => ProfileLoadedWidget(
                  user: user,
                  firebaseUser: firebaseUser,
                ),
                ProfileError(:final message) => Center(
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
                      Text(message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().loadProfile(),
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
