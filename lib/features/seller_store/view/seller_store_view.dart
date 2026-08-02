import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_cubit.dart';
import 'package:incasa_app/features/seller_store/cubit/seller_store_state.dart';
import 'package:incasa_app/features/seller_store/widgets/seller_store_loaded_widget.dart';

/// View da Loja do vendedor — tela 06 do design_handoff_incasa (mock).
/// O SellerStoreCubit é factory e chega via BlocProvider de quem empilha.
class SellerStoreView extends StatelessWidget {
  const SellerStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<SellerStoreCubit, SellerStoreState>(
        builder: (context, state) {
          return switch (state.status) {
            SellerStoreStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            SellerStoreStatus.loaded => SellerStoreLoadedWidget(state: state),
            SellerStoreStatus.error => Center(
              child: Text(state.errorMessage ?? 'Erro ao carregar'),
            ),
          };
        },
      ),
    );
  }
}
