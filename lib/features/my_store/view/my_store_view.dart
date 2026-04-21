import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_state.dart';
import 'package:incasa_app/features/my_store/widgets/my_store_loaded_widget.dart';

class MyStoreView extends StatelessWidget {
  const MyStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyStoreCubit, MyStoreState>(
      builder: (context, state) {
        return switch (state) {
          MyStoreLoading() => const Center(child: CircularProgressIndicator()),
          MyStoreLoaded() => MyStoreLoadedWidget(state: state),
          MyStoreError(:final message) => Center(
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
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<MyStoreCubit>().loadMyStore(),
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
