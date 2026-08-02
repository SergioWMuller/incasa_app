import 'package:incasa_app/domain/entities/design/chat_message.dart';
import 'package:incasa_app/domain/entities/design/chat_thread.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/domain/entities/design/neighbor_seller.dart';
import 'package:incasa_app/domain/entities/design/order_agreement.dart';
import 'package:incasa_app/domain/entities/design/pix_charge.dart';
import 'package:incasa_app/domain/entities/design/seller_store_info.dart';

/// Dados mock das telas do design_handoff_incasa (fase provisória).
///
/// DÍVIDA TÉCNICA: quando as novas telas forem mescladas com as features
/// existentes (marketplace/my_store/profile), este datasource deve ser
/// substituído por usecases/repositories reais (Supabase), seguindo o fluxo
/// UI → Cubit → UseCase → Repository → DataSource.
abstract class DesignMockDataSource {
  String get neighborhoodName;
  List<NeighborSeller> getNeighborsSellingToday();
  List<HomeProduct> getFeedProducts();
  HomeProduct getProductById(String id);
  SellerStoreInfo getSellerStore(String sellerId);
  List<ChatThread> getChatThreads();
  List<ChatMessage> getMessages(String threadId);
  OrderAgreement getAgreement(String threadId);
  PixCharge createPixCharge(HomeProduct product);
}

class DesignMockDataSourceImpl implements DesignMockDataSource {
  @override
  String get neighborhoodName => 'Jd. das Flores';

  static const _neighbors = [
    NeighborSeller(id: 'bel', name: 'Bel', distanceLabel: '600m'),
    NeighborSeller(id: 'joao', name: 'João', distanceLabel: '1,1km'),
    NeighborSeller(id: 'ana', name: 'Ana', distanceLabel: '350m'),
    NeighborSeller(id: 're', name: 'Rê', distanceLabel: '800m'),
    NeighborSeller(id: 'carlos', name: 'Carlos', distanceLabel: '1,4km'),
    NeighborSeller(id: 'mari', name: 'Mari', distanceLabel: '900m'),
  ];

  static const _products = [
    HomeProduct(
      id: 'bolo-cenoura',
      name: 'Bolo de cenoura c/ brigadeiro',
      price: 32,
      category: 'Doces',
      description:
          'Bolo de cenoura caseiro com cobertura generosa de brigadeiro, '
          'feito no dia da entrega. Serve 8 pessoas.',
      availabilityLabel: 'Retirada no bairro hoje até 18h · ou entrego até 1 km',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      distanceLabel: '600m',
      rating: 4.9,
      thumbLabel: 'foto do bolo',
    ),
    HomeProduct(
      id: 'vaso-ceramica',
      name: 'Vaso de cerâmica pintado à mão',
      price: 58,
      category: 'Artesanato',
      description:
          'Vaso de cerâmica torneado e pintado à mão, peça única. '
          'Ideal para suculentas e plantas pequenas.',
      availabilityLabel: 'Retirada no bairro · combinar horário',
      sellerId: 'joao',
      sellerName: 'Ateliê do João',
      distanceLabel: '1,1km',
      rating: 4.8,
      thumbLabel: 'foto do vaso',
    ),
    HomeProduct(
      id: 'pao-fermentacao',
      name: 'Pão de fermentação natural',
      price: 24,
      category: 'Comida',
      description:
          'Pão rústico de fermentação natural, casca crocante e miolo macio. '
          'Assado na manhã da entrega.',
      availabilityLabel: 'Retirada no bairro hoje até 12h',
      sellerId: 'ana',
      sellerName: 'Forno da Ana',
      distanceLabel: '350m',
      rating: 5.0,
      thumbLabel: 'foto do pão',
    ),
    HomeProduct(
      id: 'brigadeiro-caixa',
      name: 'Caixa de brigadeiro gourmet (12 un)',
      price: 12,
      category: 'Doces',
      description:
          'Brigadeiros gourmet feitos com chocolate 50% cacau. '
          'Caixa com 12 unidades.',
      availabilityLabel: 'Retirada no bairro hoje até 18h',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      distanceLabel: '600m',
      rating: 4.9,
      thumbLabel: 'foto dos brigadeiros',
    ),
    HomeProduct(
      id: 'conserto-roupas',
      name: 'Conserto e ajuste de roupas',
      price: 35,
      category: 'Serviço',
      description:
          'Ajustes de barra, cintura e pequenos consertos. '
          'Prazo médio de 2 dias, busco e entrego no bairro.',
      availabilityLabel: 'Atendo de segunda a sábado',
      sellerId: 're',
      sellerName: 'Ateliê da Rê',
      distanceLabel: '800m',
      rating: 4.7,
      thumbLabel: 'foto do ateliê',
    ),
  ];

  static const _belMoreProducts = [
    HomeProduct(
      id: 'brigadeiro-caixa',
      name: 'Brigadeiro',
      price: 12,
      category: 'Doces',
      description: 'Brigadeiros gourmet com chocolate 50% cacau.',
      availabilityLabel: 'Retirada no bairro hoje até 18h',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      distanceLabel: '600m',
      rating: 4.9,
      thumbLabel: 'brigadeiro',
    ),
    HomeProduct(
      id: 'torta-limao',
      name: 'Torta de limão',
      price: 45,
      category: 'Doces',
      description: 'Torta de limão com merengue maçaricado. Serve 10.',
      availabilityLabel: 'Sob encomenda · 2 dias',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      distanceLabel: '600m',
      rating: 4.9,
      thumbLabel: 'torta',
    ),
    HomeProduct(
      id: 'cookies',
      name: 'Cookies (6 un)',
      price: 18,
      category: 'Doces',
      description: 'Cookies com gotas de chocolate, assados no dia.',
      availabilityLabel: 'Retirada no bairro hoje até 18h',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      distanceLabel: '600m',
      rating: 4.9,
      thumbLabel: 'cookies',
    ),
  ];

  @override
  List<NeighborSeller> getNeighborsSellingToday() => _neighbors;

  @override
  List<HomeProduct> getFeedProducts() => _products;

  @override
  HomeProduct getProductById(String id) =>
      _products.firstWhere((p) => p.id == id, orElse: () => _products.first);

  @override
  SellerStoreInfo getSellerStore(String sellerId) {
    return SellerStoreInfo(
      id: 'bel',
      name: 'Cozinha da Bel',
      rating: 4.9,
      distanceLabel: '600m',
      salesCount: 32,
      bio: 'Bolos e doces caseiros feitos por encomenda. '
          'Atendo de terça a domingo 🧡',
      highlight: getProductById('bolo-cenoura'),
      moreProducts: _belMoreProducts,
    );
  }

  @override
  List<ChatThread> getChatThreads() => const [
    ChatThread(
      id: 'thread-bel',
      sellerId: 'bel',
      sellerName: 'Cozinha da Bel',
      lastMessage: 'Perfeito! Te espero às 17h então 🧡',
      timeLabel: '16:12',
      isOnline: true,
    ),
    ChatThread(
      id: 'thread-joao',
      sellerId: 'joao',
      sellerName: 'Ateliê do João',
      lastMessage: 'O vaso fica pronto na sexta!',
      timeLabel: 'ontem',
      isOnline: false,
    ),
  ];

  @override
  List<ChatMessage> getMessages(String threadId) => const [
    ChatMessage(
      id: 'm1',
      text: 'Oi! Vi que o pagamento caiu, obrigada! 🧡',
      isMine: false,
    ),
    ChatMessage(
      id: 'm2',
      text: 'Consigo retirar hoje às 17h, pode ser?',
      isMine: true,
    ),
    ChatMessage(
      id: 'm3',
      text: 'Pode sim! Rua das Flores, 120. Toca o interfone 12.',
      isMine: false,
    ),
    ChatMessage(id: 'm4', text: 'Perfeito! Te espero às 17h então 🧡', isMine: false),
  ];

  @override
  OrderAgreement getAgreement(String threadId) => const OrderAgreement(
    productName: 'Bolo de cenoura',
    price: 32,
    paid: true,
    placeLabel: 'Rua das Flores, 120',
    timeLabel: 'HOJE · 17h',
  );

  @override
  PixCharge createPixCharge(HomeProduct product) => const PixCharge(
    code: '00020126580014BR.GOV.BCB.PIX0136incasa-mock-pix-key520400005303986',
    expirySeconds: 600,
  );
}
