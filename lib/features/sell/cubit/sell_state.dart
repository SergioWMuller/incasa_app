import 'package:equatable/equatable.dart';

class SellState extends Equatable {
  static const int totalSteps = 4;

  final int currentStep;
  final List<String> photos;
  final String tipo;
  final String title;
  final String category;
  final String description;
  final String price;
  final String estoque;
  final String prazoProducaoDias;
  final bool disponivelVenda;
  final bool prontaEntrega;
  final bool aceitaEncomenda;
  final String prazoMinimoEncomendaDias;
  final bool isPublishing;
  final String? errorMessage;
  final bool published;

  const SellState({
    this.currentStep = 1,
    this.photos = const [],
    this.tipo = 'produto',
    this.title = '',
    this.category = '',
    this.description = '',
    this.price = '',
    this.estoque = '',
    this.prazoProducaoDias = '',
    this.disponivelVenda = true,
    this.prontaEntrega = true,
    this.aceitaEncomenda = false,
    this.prazoMinimoEncomendaDias = '',
    this.isPublishing = false,
    this.errorMessage,
    this.published = false,
  });

  double get progress => currentStep / totalSteps;

  @override
  List<Object?> get props => [
    currentStep,
    photos,
    tipo,
    title,
    category,
    description,
    price,
    estoque,
    prazoProducaoDias,
    disponivelVenda,
    prontaEntrega,
    aceitaEncomenda,
    prazoMinimoEncomendaDias,
    isPublishing,
    errorMessage,
    published,
  ];

  SellState copyWith({
    int? currentStep,
    List<String>? photos,
    String? tipo,
    String? title,
    String? category,
    String? description,
    String? price,
    String? estoque,
    String? prazoProducaoDias,
    bool? disponivelVenda,
    bool? prontaEntrega,
    bool? aceitaEncomenda,
    String? prazoMinimoEncomendaDias,
    bool? isPublishing,
    String? errorMessage,
    bool clearError = false,
    bool? published,
  }) {
    return SellState(
      currentStep: currentStep ?? this.currentStep,
      photos: photos ?? this.photos,
      tipo: tipo ?? this.tipo,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      estoque: estoque ?? this.estoque,
      prazoProducaoDias: prazoProducaoDias ?? this.prazoProducaoDias,
      disponivelVenda: disponivelVenda ?? this.disponivelVenda,
      prontaEntrega: prontaEntrega ?? this.prontaEntrega,
      aceitaEncomenda: aceitaEncomenda ?? this.aceitaEncomenda,
      prazoMinimoEncomendaDias:
          prazoMinimoEncomendaDias ?? this.prazoMinimoEncomendaDias,
      isPublishing: isPublishing ?? this.isPublishing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      published: published ?? this.published,
    );
  }
}
