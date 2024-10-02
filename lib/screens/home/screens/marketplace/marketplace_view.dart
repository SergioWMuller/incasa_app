import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'marketplace_cubit.dart';

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketplaceCubit(),
      child: Scaffold(
        body: Center(
          child: Text('Página Vitrine'),
        ),
      ),
    );
  }
}
