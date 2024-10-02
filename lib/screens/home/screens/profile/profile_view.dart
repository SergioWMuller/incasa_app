import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_cubit.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PerfilCubit(),
      child: Scaffold(
        body: Center(
          child: Text('Página Perfil'),
        ),
      ),
    );
  }
}
