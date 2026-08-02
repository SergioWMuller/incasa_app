import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/data/datasources/local/design_mock_data_source.dart';
import 'package:incasa_app/domain/entities/design/home_product.dart';
import 'package:incasa_app/features/checkout/cubit/pix_state.dart';

class PixCubit extends Cubit<PixState> {
  final DesignMockDataSource mockDataSource;
  Timer? _countdownTimer;

  PixCubit({required this.mockDataSource}) : super(const PixState());

  /// Cria a cobrança mock e inicia o countdown de expiração (~10min)
  void start(HomeProduct product) {
    final charge = mockDataSource.createPixCharge(product);
    emit(
      PixState(
        product: product,
        charge: charge,
        remainingSeconds: charge.expirySeconds,
      ),
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    });
  }

  /// Copia o código copia-e-cola para a área de transferência
  Future<void> copyCode() async {
    final code = state.charge?.code;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    emit(state.copyWith(codeCopied: true));
  }

  /// "Já paguei" — marca o pedido como pago (mock)
  void confirmPaid() {
    _countdownTimer?.cancel();
    emit(state.copyWith(status: PixStatus.pago));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
