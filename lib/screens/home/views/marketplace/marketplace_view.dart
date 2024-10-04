import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_incasa_app/screens/home/widgets/category_list.dart';
import 'package:projeto_incasa_app/screens/home/widgets/category_list.dart';
import 'marketplace_cubit.dart';

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketplaceCubit(),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('Página Vitrine'),
              CardMomento('Produto 1', 'Sub 1'),
              CardMomento('Produto 2', 'Sub 2'),
            ],
          ),
        ),
      ),
    );
  }
}
