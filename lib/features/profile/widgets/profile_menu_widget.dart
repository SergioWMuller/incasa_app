import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/settings/view/settings_view.dart';

class ProfileMenuWidget extends StatelessWidget {
  final bool showLogout;
  final bool isAuthenticated;

  const ProfileMenuWidget({
    super.key,
    this.showLogout = false,
    this.isAuthenticated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NeumorphicSurface(
        padding: const EdgeInsets.symmetric(vertical: 4),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Conversas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navegar para conversas
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navegar para notificações
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Pagamentos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navegar para pagamentos
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navegar para favoritos
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ajuda'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navegar para ajuda
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsView()),
                );
              },
            ),
            const Divider(),
            if (showLogout && isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Obtém AuthCubit do GetIt
                  final authCubit = sl<AuthCubit>();

                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirmar logout'),
                      content: const Text(
                        'Você tem certeza que deseja sair da sua conta?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            log('🔘 Botão Sair pressionado no dialog');
                            Navigator.of(dialogContext).pop();
                            authCubit.signOut();
                          },
                          child: const Text(
                            'Sair',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (showLogout && isAuthenticated) const Divider(),
          ],
        ),
      ),
    );
  }
}
