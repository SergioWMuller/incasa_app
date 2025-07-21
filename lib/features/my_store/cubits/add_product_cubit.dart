import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_incasa_app/data/repositories/product_repository.dart';
import 'package:projeto_incasa_app/features/my_store/states/add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit() : super(AddProductInitial());

  Future<void> submit({
    required String type,
    required String name,
    required String description,
    required String price,
    required String? stock,
    required String? leadTimeDays,
    required String? discount,
    required String? promoCode,
    required String? category,
    required bool isAvailable,
  }) async {
    emit(AddProductLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AddProductError('Usuário não autenticado.'));
        return;
      }
      await ProductRepository().create(
        userId: user.uid,
        type: type,
        name: name,
        description: description,
        price: num.parse(price),
        stock: stock != null && stock.isNotEmpty ? int.tryParse(stock) : null,
        leadTimeDays: leadTimeDays != null && leadTimeDays.isNotEmpty
            ? int.tryParse(leadTimeDays)
            : null,
        discount: discount != null && discount.isNotEmpty
            ? num.tryParse(discount)
            : null,
        promoCode: promoCode,
        category: category,
        isAvailable: isAvailable,
      );
      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductError(e.toString()));
    }
  }
}
