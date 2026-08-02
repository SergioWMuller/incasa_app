import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_cubit.dart';
import 'package:incasa_app/features/product_detail/cubit/product_detail_state.dart';
import 'package:incasa_app/features/product_detail/widgets/product_detail_loaded_widget.dart';

/// View do Produto — tela 02 do design_handoff_incasa (provisória, mock).
/// O ProductDetailCubit é factory e chega via BlocProvider de quem empilha.
class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return switch (state.status) {
            ProductDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ProductDetailStatus.loaded => ProductDetailLoadedWidget(
              state: state,
            ),
            ProductDetailStatus.error => Center(
              child: Text(state.errorMessage ?? 'Erro ao carregar'),
            ),
          };
        },
      ),
    );
  }
}
