import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/profile/user.dart' as profile_user;
import 'package:incasa_app/features/profile/widgets/profile_menu_widget.dart';

class ProfileLoadedWidget extends StatelessWidget {
  final profile_user.User user;
  final firebase_auth.User? firebaseUser;

  const ProfileLoadedWidget({super.key, required this.user, this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    final fallbackPhone = firebaseUser?.phoneNumber;
    final email = firebaseUser?.email;
    final avatarSource = [
      user.displayName,
      user.fullName,
      email,
    ].firstWhere((v) => v != null && v.isNotEmpty, orElse: () => 'U')!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Header com avatar e nome
        NeumorphicSurface(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              NeumorphicSurface(
                constraints: const BoxConstraints.tightFor(
                  width: 104,
                  height: 104,
                ),
                borderRadius: BorderRadius.circular(52),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          avatarSource.substring(0, 1).toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : (user.fullName.isNotEmpty ? user.fullName : 'Usuário'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(email ?? '', style: Theme.of(context).textTheme.bodyMedium),
              if (fallbackPhone != null && fallbackPhone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  fallbackPhone,
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
