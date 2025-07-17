import 'package:projeto_incasa_app/features/my_store/cubits/my_store_cubit.dart';
import 'package:projeto_incasa_app/features/my_store/states/my_store_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'add_product_page.dart';

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
    tabController = TabController(length: 2, vsync: this);
    myStoreCubit = MyStoreCubit();
    myStoreCubit.loadMyStore();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    myStoreCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
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
                  Text('Produtos e Serviços'),
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
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Aqui terá todos os seus'),
                          Text('Produtos e Serviços cadastrados.'),
                          SizedBox(height: 16),
                          Text('Nenhum produto cadastrado.'),
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
                        subtitle: Text('Estoque: ${product['stock'] ?? '-'}'),
                      );
                    },
                  );
                } else if (state is ErrorMyStoreState) {
                  return Center(child: Text('Erro: ${state.errorMessage}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        // ...existing code...
        floatingActionButton: AnimatedBuilder(
          animation: tabController,
          builder: (context, child) {
            return tabController.index == 1
                ? FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final cubit = context.read<MyStoreCubit>();
                      final wasMounted = mounted;
                      final result = await navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const AddProductPage(),
                        ),
                      );
                      if (wasMounted && mounted && result == true) {
                        cubit.loadMyStore();
                      }
                    },
                  )
                : const SizedBox.shrink();
          },
        ),
// ...existing code...
      ),
    );
  }
}
