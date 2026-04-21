import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';
import 'package:incasa_app/features/profile/cubit/profile_cubit.dart';
import 'package:incasa_app/core/di/injection_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileCubit profileCubit;

  @override
  void initState() {
    profileCubit = sl<ProfileCubit>();
    profileCubit.loadProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout realizado com sucesso!')),
              );
            } else if (authState is AuthAuthenticated) {
              _showAuthSuccessDialog(context, authState.user);
            } else if (authState is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(authState.message)));
            }
          },
        ),
      ],
      child: BlocProvider.value(
        value: profileCubit,
        child: Scaffold(
          body: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              User? user;
              bool isLoggedIn = false;

              if (authState is AuthAuthenticated) {
                user = authState.user;
                isLoggedIn = true;
              }

              final photoUrl = user?.photoURL;

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoggedIn)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            user?.displayName ?? 'Usuário',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      isLoggedIn ? 'Sair desta conta' : 'Entrar com Google',
                    ),
                    trailing: Icon(isLoggedIn ? Icons.logout : Icons.login),
                    onTap: () {
                      if (isLoggedIn) {
                        context.read<AuthCubit>().signOut();
                      } else {
                        context.read<AuthCubit>().signInWithGoogle();
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Conversas'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Notificações'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Pagamentos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Favoritos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Endereços'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Ajuda'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Configurações'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAuthSuccessDialog(BuildContext context, User user) async {
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso'),
        content: Text(
          'Login Google realizado com sucesso!\nBem-vindo, ${user.displayName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Login Google realizado!')),
    );
  }
}
