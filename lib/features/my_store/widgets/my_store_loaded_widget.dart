import 'package:flutter/material.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_state.dart';
import 'package:incasa_app/features/my_store/widgets/my_store_product_card.dart';

/// Widget de apresentação para MyStore (StatelessWidget)
/// Usa DefaultTabController para gerenciar tabs sem StatefulWidget
class MyStoreLoadedWidget extends StatelessWidget {
  final MyStoreLoaded state;

  const MyStoreLoadedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Minha vitrine'),
              Tab(icon: Icon(Icons.storage_rounded), text: 'Meus produtos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Vitrine da loja
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        state.store.imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.store, size: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.store.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.store.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Chip(
                      label: Text(
                        state.store.isActive ? 'Loja Ativa' : 'Loja Inativa',
                      ),
                      backgroundColor: state.store.isActive
                          ? Colors.green
                          : Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${state.products.length} produtos cadastrados',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            // Tab 2: Lista de produtos
            Scaffold(
              body: state.products.isEmpty
                  ? const Center(child: Text('Nenhum produto cadastrado'))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        return MyStoreProductCard(
                          product: state.products[index],
                        );
                      },
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // TODO: Navegar para tela de adicionar produto
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Adicionar produto (em breve)'),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
