import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/my_store_cubit.dart';
import '../cubit/my_store_state.dart';

class MyStorePage extends StatefulWidget {
  const MyStorePage({super.key});

  @override
  State<MyStorePage> createState() => _MyStorePageState();
}

class _MyStorePageState extends State<MyStorePage>
    with SingleTickerProviderStateMixin {
  late MyStoreCubit myStoreCubit;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    myStoreCubit = MyStoreCubit();
    myStoreCubit.loadMyStore();
  }

  @override
  void dispose() {
    tabController.dispose();
    myStoreCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyStoreCubit>.value(
      value: myStoreCubit,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.store),
                text: 'Minha vitrine',
              ),
              Tab(
                icon: Icon(Icons.storage_rounded),
                text: 'Meus produtos',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Aqui ficará seus'),
                  Text('Produtos ou Serviços'),
                  Text('disponíveis para venda.'),
                ],
              ),
            ),
            BlocBuilder<MyStoreCubit, MyStoreState>(
              builder: (context, state) {
                if (state is LoadingMyStoreState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LoadedMyStoreState) {
                  if (state.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Aqui terá todos os seus'),
                          const Text('Produtos e Serviços cadastrados.'),
                          const SizedBox(height: 16),
                          const Text('Nenhum produto cadastrado.'),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ListTile(
                        title: Text(product['name'] ?? ''),
                        subtitle: Text(product['description'] ?? ''),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
