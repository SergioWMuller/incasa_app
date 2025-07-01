import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_incasa_app/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileCubit profileCubit;

  @override
  void initState() {
    profileCubit = ProfileCubit();
    profileCubit.loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: profileCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = FirebaseAuth.instance.currentUser;
          final photoUrl = user?.photoURL;
          final isLoggedIn = user != null;

          return Scaffold(
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 32),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                      isLoggedIn ? 'Sair desta conta' : 'Entrar com Google'),
                  trailing: Icon(isLoggedIn ? Icons.logout : Icons.login),
                  onTap: () async {
                    if (isLoggedIn) {
                      await context.read<ProfileCubit>().signOut();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Logout realizado com sucesso!')),
                      );
                      setState(() {}); // Atualiza avatar após logout
                    } else {
                      final userCredential = await signInWithGoogle();
                      if (!mounted) return;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              userCredential != null ? 'Sucesso' : 'Falha'),
                          content: Text(userCredential != null
                              ? 'Login Google realizado com sucesso!'
                              : 'Login cancelado ou falhou.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(userCredential != null
                              ? 'Login Google realizado!'
                              : 'Login cancelado ou falhou.'),
                        ),
                      );
                      setState(() {}); // Atualiza avatar após login
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
            ),
          );
        },
      ),
    );
  }
}
