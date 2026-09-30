import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/domain/entities/my_store/store.dart';
import 'package:incasa_app/features/my_store/widgets/showcase/my_store_showcase_tab.dart';

void main() {
  testWidgets('a vitrine pública exibe apenas anúncios disponíveis', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 9, 28);
    final store = Store(
      id: 'store-1',
      name: 'Ateliê da Ana',
      description: 'Peças feitas à mão',
      ownerId: 'owner-1',
      imageUrl: '',
      isActive: true,
      createdAt: now,
    );
    final products = [
      Product(
        id: 'service-1',
        tipo: 'servico',
        name: 'Ajuste de roupas',
        description: 'Ajustes sob medida',
        price: 40,
        imageUrl: '',
        category: 'servicos',
        disponivelVenda: true,
        createdAt: now,
      ),
      Product(
        id: 'product-1',
        tipo: 'produto',
        name: 'Bolsa pausada',
        description: 'Bolsa artesanal',
        price: 90,
        imageUrl: '',
        category: 'artesanato',
        disponivelVenda: false,
        createdAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyStoreShowcaseTab(store: store, products: products),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ajuste de roupas'), findsOneWidget);
    expect(find.text('Bolsa pausada'), findsNothing);
    expect(find.text('1 anúncio'), findsOneWidget);
  });
}
