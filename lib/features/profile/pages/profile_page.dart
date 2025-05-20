import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_incasa_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/profile_cubit.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    return BlocProvider.value(
      value: profileCubit,
      child: Scaffold(
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
              title: const Text('Entrar com Google'),
              trailing: const Icon(Icons.login),
              onTap: () async {
                final userCredential = await signInWithGoogle();
                setState(() {}); // Atualiza avatar após login
                if (userCredential != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login Google realizado!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login cancelado ou falhou.')),
                  );
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
      ),
    );
  }
}
