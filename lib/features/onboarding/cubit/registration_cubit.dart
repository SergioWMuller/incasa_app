import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/usecases/usecase.dart';
import 'package:incasa_app/core/utils/result.dart';
import 'package:incasa_app/domain/usecases/profile/get_registration_info.dart';
import 'registration_state.dart';

/// Cubit da tela "Dados da Conta" (`RegistrationView`).
///
/// Carrega e-mail e telefone (completos) e CPF (mascarado pelo banco) via RPC
/// `get_registration_info`. O CPF em texto puro nunca chega ao app.
class RegistrationCubit extends Cubit<RegistrationState> {
  final GetRegistrationInfo getRegistrationInfoUseCase;

  RegistrationCubit({required this.getRegistrationInfoUseCase})
    : super(const RegistrationState());

  Future<void> loadRegistration() async {
    emit(const RegistrationState(status: RegistrationStatus.loading));

    final result = await getRegistrationInfoUseCase(const NoParams());

    switch (result) {
      case Success(:final data):
        emit(RegistrationState(status: RegistrationStatus.loaded, info: data));
      case Error(:final failure):
        emit(
          RegistrationState(
            status: RegistrationStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
