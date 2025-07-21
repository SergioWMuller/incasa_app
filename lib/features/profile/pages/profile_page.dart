import 'package:projeto_incasa_app/features/profile/cubits/profile_cubit.dart';
import 'package:projeto_incasa_app/features/profile/cubits/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

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
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileLoggedOut) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logout realizado com sucesso!')),
            );
          } else if (state is ProfileLoggedIn) {
            // Capture the context before the async gap
            final messenger = ScaffoldMessenger.of(context);
            // 3 - Dialog de sucesso da auth
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sucesso'),
                content: const Text('Login Google realizado com sucesso!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            if (!mounted) return;
            // 4 - Snackbar de sucesso da auth
            messenger.showSnackBar(
              const SnackBar(content: Text('Login Google realizado!')),
            );
            // 5 - Snackbar de sucesso ao salvar no Supabase
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.supabaseSaved
                    ? 'Dados do usuário salvos no Supabase!'
                    : 'Falha ao salvar dados no Supabase.'),
              ),
            );
          } else if (state is ProfileLoginFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message ?? 'Login cancelado ou falhou.')),
            );
          }
        },
        builder: (context, state) {
          User? user;
          if (state is ProfileLoaded || state is ProfileLoggedIn) {
            user = (state as dynamic).user;
          } else {
            user = FirebaseAuth.instance.currentUser;
          }
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
                      context.read<ProfileCubit>().signOut();
                    } else {
                      context.read<ProfileCubit>().signInWithGoogle();
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
