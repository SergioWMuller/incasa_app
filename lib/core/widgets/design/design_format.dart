/// Helpers de formatação das telas do design handoff (fase provisória).
class DesignFormat {
  DesignFormat._();

  /// Formata preço no padrão do design: "R$ 32" ou "R$ 32,50".
  static String price(double value) {
    if (value == value.roundToDouble()) {
      return 'R\$ ${value.toInt()}';
    }
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata rating com vírgula: "4,9".
  static String rating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  /// Formata segundos como MM:SS (countdown do Pix).
  static String countdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
