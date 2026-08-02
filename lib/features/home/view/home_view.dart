import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/home/cubit/home_cubit.dart';
import 'package:incasa_app/features/home/cubit/home_state.dart';
import 'package:incasa_app/features/home/widgets/home_loaded_widget.dart';

/// View do Início — tela 01 do design_handoff_incasa (provisória, dados mock)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: sl<HomeCubit>(),
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            HomeStatus.loaded => HomeLoadedWidget(state: state),
            HomeStatus.error => Center(
              child: Text(state.errorMessage ?? 'Erro ao carregar'),
            ),
          };
        },
      ),
    );
  }
}
