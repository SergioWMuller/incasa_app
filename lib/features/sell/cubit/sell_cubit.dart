import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/sell/cubit/sell_state.dart';

class SellCubit extends Cubit<SellState> {
  final MyStoreCubit myStoreCubit;

  SellCubit({required this.myStoreCubit}) : super(const SellState());

  /// Avança para o próximo passo do wizard
  void nextStep() {
    if (state.currentStep < SellState.totalSteps) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Volta para o passo anterior
  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Adiciona uma foto mock (sem image picker nesta fase)
  void addPhoto() {
    if (state.photos.length >= 3) return;
    emit(
      state.copyWith(photos: [...state.photos, 'foto ${state.photos.length + 1}']),
    );
  }

  /// Remove uma foto pelo índice
  void removePhoto(int index) {
    final photos = List<String>.from(state.photos)..removeAt(index);
    emit(state.copyWith(photos: photos));
  }

  void setTipo(String tipo) => emit(state.copyWith(tipo: tipo));

  void setTitle(String title) => emit(state.copyWith(title: title));

  void setCategory(String category) =>
      emit(state.copyWith(category: category));

  void setDescription(String description) =>
      emit(state.copyWith(description: description));

  void setPrice(String price) => emit(state.copyWith(price: price));

  void setEstoque(String estoque) => emit(state.copyWith(estoque: estoque));

  void setPrazoProducaoDias(String prazoProducaoDias) =>
      emit(state.copyWith(prazoProducaoDias: prazoProducaoDias));

  void setDisponivelVenda(bool value) =>
      emit(state.copyWith(disponivelVenda: value));

  void setProntaEntrega(bool value) =>
      emit(state.copyWith(prontaEntrega: value));

  void setAceitaEncomenda(bool value) =>
      emit(state.copyWith(aceitaEncomenda: value));

  void setPrazoMinimoEncomendaDias(String prazoMinimoEncomendaDias) => emit(
    state.copyWith(prazoMinimoEncomendaDias: prazoMinimoEncomendaDias),
  );

  /// Publica o anúncio: cria o produto de verdade via [MyStoreCubit], a
  /// mesma via usada pela tela "Adicionar Produto".
  Future<void> publish() async {
    emit(state.copyWith(isPublishing: true, clearError: true));

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: state.tipo,
      name: state.title,
      description: state.description,
      price: double.parse(state.price.replaceAll(',', '.')),
      imageUrl: 'https://via.placeholder.com/300',
      category: state.category,
      estoque: state.estoque.isEmpty ? null : int.tryParse(state.estoque),
      prazoProducaoDias: state.prazoProducaoDias.isEmpty
          ? null
          : int.tryParse(state.prazoProducaoDias),
      prazoEntregaHoras: null,
      prazoMinimoEncomendaDias:
          state.aceitaEncomenda && state.prazoMinimoEncomendaDias.isNotEmpty
          ? int.tryParse(state.prazoMinimoEncomendaDias)
          : null,
      disponivelVenda: state.disponivelVenda,
      prontaEntrega: state.prontaEntrega,
      aceitaEncomenda: state.aceitaEncomenda,
      createdAt: DateTime.now(),
    );

    final success = await myStoreCubit.addProduct(product);

    if (success) {
      emit(state.copyWith(isPublishing: false, published: true));
    } else {
      emit(
        state.copyWith(
          isPublishing: false,
          errorMessage: myStoreCubit.state.errorMessage,
        ),
      );
    }
  }

  /// Reinicia o wizard para um novo anúncio
  void reset() {
    emit(const SellState());
  }
}
