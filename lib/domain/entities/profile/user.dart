import 'package:equatable/equatable.dart';

/// Entity User (Perfil do usuário)
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, phone, createdAt];
}
