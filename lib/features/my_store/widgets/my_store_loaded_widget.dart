import 'package:flutter/material.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_state.dart';
import 'package:incasa_app/features/my_store/widgets/my_store_product_card.dart';
import 'package:incasa_app/features/my_store/widgets/showcase/my_store_showcase_tab.dart';
import 'package:incasa_app/features/sell/widgets/sell_wizard_widget.dart';

/// Widget de apresentação para MyStore (StatelessWidget)
/// Usa DefaultTabController para gerenciar tabs sem StatefulWidget
class MyStoreLoadedWidget extends StatelessWidget {
  final MyStoreState state;

  const MyStoreLoadedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Vitrine'),
              Tab(icon: Icon(Icons.storage_rounded), text: 'Produtos'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Adicionar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Vitrine padrão da loja (layout automático — ver
            // ai/EDITAR_LOJA_VIEW.md sobre a variante de grid customizável,
            // hoje pausada e fora do fluxo principal).
            MyStoreShowcaseTab(store: state.store!, products: state.products!),

            // Tab 2: Lista de produtos
            Scaffold(
              body: state.products!.isEmpty
                  ? Builder(
                      builder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum produto ou serviço cadastrado',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => DefaultTabController.of(
                                  context,
                                ).animateTo(2),
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.products!.length,
                      itemBuilder: (context, index) {
                        return MyStoreProductCard(
                          product: state.products![index],
                        );
                      },
                    ),
            ),

            // Tab 3: Wizard de anúncio (tela 03 do design_handoff_incasa)
            const SellWizardWidget(),
          ],
        ),
      ),
    );
  }
}
