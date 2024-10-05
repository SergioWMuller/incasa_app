final class ProfileState {}

final class LoadingProfileState extends ProfileState {}

final class LoadedProfileState extends ProfileState {
  LoadedProfileState();
}

final class ErrorProfileState extends ProfileState {
  final String errorMessage;
  ErrorProfileState({required this.errorMessage});
}
