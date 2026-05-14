import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_state.dart';
import 'package:incasa_app/features/my_store/widgets/my_store_loaded_widget.dart';

class MyStoreView extends StatelessWidget {
  const MyStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyStoreCubit, MyStoreState>(
      bloc: sl<MyStoreCubit>(),
      builder: (context, state) {
        return switch (state.status) {
          MyStoreStatus.inicial => const Center(
            child: CircularProgressIndicator(),
          ),
          MyStoreStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MyStoreStatus.loaded => MyStoreLoadedWidget(state: state),
          MyStoreStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar loja',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(state.errorMessage ?? 'Erro desconhecido'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => sl<MyStoreCubit>().loadMyStore(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        };
      },
    );
  }
}
