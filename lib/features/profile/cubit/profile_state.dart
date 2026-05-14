import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/profile/user.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, errorMessage];

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
