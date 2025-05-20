import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/my_store_cubit.dart';
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
    super.initState();
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
                icon: Icon(
                  Icons.store,
                ),
                text: 'Minha vitrine',
              ),
              Tab(
                icon: Icon(
                  Icons.storage_rounded,
                ),
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
                  Text('Página Minha Loja'),
                  Text('Meus produtos a venda'),
                  Text('Oferecer meus Serviços'),
                ],
              ),
            ),
            Scaffold(
              body: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ...List.generate(
                    20,
                    (index) => ListTile(
                      title: Text('Produto $index'),
                      subtitle: Text('Quantidade em estoque: ${index + 1}'),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddProductPage(),
                    ),
                  );
                  // Se um produto foi adicionado, você pode recarregar a lista aqui
                  if (result == true) {
                    // TODO: Atualizar a lista de produtos
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
