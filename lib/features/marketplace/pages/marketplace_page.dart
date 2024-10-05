import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/marketplace_cubit.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  late MarketplaceCubit marketplaceCubit;

  @override
  void initState() {
    marketplaceCubit = MarketplaceCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: marketplaceCubit,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(20, (index) {
                return Card(
                  child: ListTile(
                    title: Text('Produto $index'),
                    subtitle: Text('Sub $index'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
