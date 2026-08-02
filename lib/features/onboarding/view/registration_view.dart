import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:incasa_app/features/onboarding/cubit/onboarding_state.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), centerTitle: true),
      body: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final isEmailVerified = state.emailVerified;
          final isPhoneVerified = state.phoneVerified;
          final isCpfVerified = state.cpf != null && state.cpf!.isNotEmpty;
          final email = state.email ?? 'usuario@email.com';
          final phoneNumber = state.phoneNumber ?? '';
          final cpf = state.cpf ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo Email (não editável)
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IgnorePointer(
                      child: Checkbox(value: isEmailVerified, onChanged: null),
                    ),
                    const Text('Verificado'),
                  ],
                ),
                const SizedBox(height: 24),
                // Campo Telefone
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '(00) 00000-0000',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IgnorePointer(
                      child: Checkbox(value: isPhoneVerified, onChanged: null),
                    ),
                    const Text('Verificado'),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo CPF
                TextFormField(
                  initialValue: cpf,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    hintText: '000.000.000-00',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IgnorePointer(
                      child: Checkbox(value: isCpfVerified, onChanged: null),
                    ),
                    const Text('Verificado'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
