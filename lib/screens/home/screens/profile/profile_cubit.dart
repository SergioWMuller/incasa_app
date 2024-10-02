import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PerfilState {}

class InitialPerfilState extends PerfilState {}

class PerfilCubit extends Cubit<PerfilState> {
  PerfilCubit() : super(InitialPerfilState());

  void loadPerfilInfo() {
    // Lógica para carregar informações do perfil
  }
}
