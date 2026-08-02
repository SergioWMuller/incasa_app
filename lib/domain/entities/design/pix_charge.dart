import 'package:equatable/equatable.dart';

/// Cobrança Pix mock (tela 04 do design handoff).
class PixCharge extends Equatable {
  final String code;
  final int expirySeconds;

  const PixCharge({required this.code, required this.expirySeconds});

  @override
  List<Object?> get props => [code, expirySeconds];
}
