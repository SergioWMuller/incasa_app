import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_store_cubit.dart';

class MyStoreView extends StatelessWidget {
  const MyStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesCubit(),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Página Minha Loja'),
              Text('Meus produtos a venda'),
              Text('Oferecer meus Serviços'),
            ],
          ),
        ),
      ),
    );
  }
}
