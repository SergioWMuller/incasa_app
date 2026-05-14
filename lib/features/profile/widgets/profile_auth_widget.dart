import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/profile/widgets/profile_menu_widget.dart';

class ProfileAuthWidget extends StatelessWidget {
  final AuthState authState;

  const ProfileAuthWidget({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    final isLoading = authState.status == AuthStatus.loading;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Seção de Login
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 32),
              Text(
                'Bem-vindo ao InCasa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Faça login para acessar seu perfil e gerenciar sua loja',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => sl<AuthCubit>().signInWithGoogle(),
                  icon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    isLoading ? 'Autenticando...' : 'Entrar com Google',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (authState.status == AuthStatus.error) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        authState.errorMessage ?? 'Erro desconhecido',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        const Divider(),
        // Menu
        ProfileMenuWidget(showLogout: false, isAuthenticated: false),
      ],
    );
  }
}
