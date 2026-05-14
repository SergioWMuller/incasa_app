import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_cubit.dart';
import 'package:incasa_app/features/marketplace/cubit/marketplace_state.dart';
import 'package:incasa_app/features/marketplace/widgets/marketplace_loaded_widget.dart';

/// View do Marketplace (StatelessWidget)
/// Usa BlocProvider existente do AppShell
class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<MarketplaceCubit, MarketplaceState>(
          bloc: sl<MarketplaceCubit>(),
          builder: (context, state) {
            // Pattern matching com switch expression
            return switch (state.status) {
              MarketplaceStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              MarketplaceStatus.loaded => MarketplaceLoadedWidget(state: state),
              MarketplaceStatus.error => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.errorMessage ?? 'Erro desconhecido'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MarketplaceCubit>().loadMarketplace(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
