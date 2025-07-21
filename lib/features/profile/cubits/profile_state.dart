abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final dynamic user;
  ProfileLoaded({required this.user});
}

class ProfileLoggedIn extends ProfileState {
  final dynamic user;
  final bool supabaseSaved;
  ProfileLoggedIn({required this.user, required this.supabaseSaved});
}

class ProfileLoggedOut extends ProfileState {}

class ProfileLoginFailed extends ProfileState {
  final String? message;
  ProfileLoginFailed({this.message});
}

class ProfileError extends ProfileState {
  final String errorMessage;
  ProfileError({required this.errorMessage});
}
