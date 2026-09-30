import 'package:equatable/equatable.dart';
import 'package:incasa_app/domain/entities/profile/registration_info.dart';

enum RegistrationStatus { loading, loaded, error }

class RegistrationState extends Equatable {
  final RegistrationStatus status;
  final RegistrationInfo? info;
  final String? errorMessage;

  const RegistrationState({
    this.status = RegistrationStatus.loading,
    this.info,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, info, errorMessage];
}
