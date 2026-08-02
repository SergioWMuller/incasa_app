import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppShellState extends Equatable {
  final int selectedIndex;

  const AppShellState({this.selectedIndex = 0});

  @override
  List<Object?> get props => [selectedIndex];

  AppShellState copyWith({int? selectedIndex}) {
    return AppShellState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(const AppShellState());

  /// Seleciona a tab do BottomNavigationBar
  void selectTab(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
