import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_incasa_app/data/models/product_model.dart';
import 'package:projeto_incasa_app/features/my_store/pages/add_product_page.dart';
import '../cubits/my_store_cubit.dart';
import '../states/my_store_state.dart';

class MyStorePage extends StatefulWidget {
  const MyStorePage({super.key});

  @override
  State<MyStorePage> createState() => _MyStorePageState();
}

class _MyStorePageState extends State<MyStorePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late MyStoreCubit myStoreCubit;

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
            // Aba "Minha vitrine" - apenas produtos disponíveis
            BlocBuilder<MyStoreCubit, MyStoreState>(
              builder: (context, state) {
                if (state is LoadingMyStoreState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LoadedMyStoreState) {
                  final availableProducts = state.products
                      .where((product) => product.isAvailable ?? false)
                      .toList();

                  if (availableProducts.isEmpty) {
                    return const Center(
                        child: Text('Nenhum produto disponível na vitrine.'));
                  }
                  return ListView.builder(
                    itemCount: availableProducts.length,
                    itemBuilder: (context, index) {
                      final product = availableProducts[index];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product.name.toString()),
                            Text('Estoque: ${product.stock ?? '-'}'),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preço: R\$ ${product.price}'),
                            Text('Descrição: ${product.description}'),
                            Text(
                                'Prazo de entrega: ${product.leadTimeDays ?? '-'} dias'),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is ErrorMyStoreState) {
                  return Center(child: Text('Erro: ${state.errorMessage}'));
                }
                return const SizedBox.shrink();
              },
            ),
            // Aba "Meus produtos" - todos os produtos
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
                  // ...existing code...
                  return ListView.builder(
                    itemCount: state.products.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return StatefulBuilder(
                        builder: (context, setState) {
                          bool? isAvailable = product.isAvailable;
                          return ListTile(
                            title: Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estoque: ${product.stock ?? 'zerado'} ',
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Preço: R\$ ${product.price}'),
                                    Text(
                                      (isAvailable ?? false)
                                          ? "Disponível"
                                          : "Indisponível",
                                    ),
                                  ],
                                ),
                                Text('Descrição: ${product.description}'),
                                Text(
                                    'Prazo de entrega: ${product.leadTimeDays ?? '-'} dias'),
                              ],
                            ),
                            trailing: Switch(
                              value: isAvailable ?? false,
                              onChanged: (value) async {
                                setState(() => isAvailable =
                                    value); // Atualiza visualmente
                                product.isAvailable =
                                    value; // Atualiza o atributo do objeto localmente
                                await context
                                    .read<MyStoreCubit>()
                                    .updateAvailability(product.id, value,
                                        refresh: false);
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
// ...existing code...
                } else if (state is ErrorMyStoreState) {
                  return Center(child: Text('Erro: ${state.errorMessage}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
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
      ),
    );
  }
}
