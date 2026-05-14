import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:incasa_app/domain/entities/profile/user.dart' as profile_user;
import 'package:incasa_app/features/profile/widgets/profile_menu_widget.dart';

class ProfileLoadedWidget extends StatelessWidget {
  final profile_user.User user;
  final firebase_auth.User? firebaseUser;

  const ProfileLoadedWidget({super.key, required this.user, this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Header com avatar e nome
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        (user.displayName ?? user.fullName ?? user.email ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName ?? user.fullName ?? 'Usuário',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (user.phoneNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        // Menu
        ProfileMenuWidget(showLogout: true, isAuthenticated: true),
      ],
    );
  }
}
