import 'dart:math';

final Random _random = Random();

/// Gera um identificador único no formato de um UUID v4 (RFC 4122), sem
/// depender de nenhum pacote externo.
String gerarIdUnico() {
  String hex(int digitos) {
    return List.generate(
      digitos,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
  }

  final variante = (8 + _random.nextInt(4)).toRadixString(16);
  return '${hex(8)}-${hex(4)}-4${hex(3)}-$variante${hex(3)}-${hex(12)}';
}
