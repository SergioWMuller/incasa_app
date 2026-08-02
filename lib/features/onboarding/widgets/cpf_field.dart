import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// -----------------------------------------------------------------------
/// CpfValidator
/// -----------------------------------------------------------------------
/// Lógica pura de validação de CPF (algoritmo Módulo 11 da Receita Federal).
/// Sem dependências externas. Espelha a função `is_valid_cpf()` do Postgres,
/// para que client e backend apliquem exatamente a mesma regra.
/// -----------------------------------------------------------------------
class CpfValidator {
  CpfValidator._();

  /// Remove tudo que não for dígito.
  static String strip(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  /// Aplica a máscara XXX.XXX.XXX-XX a uma string já contendo só dígitos
  /// (ou parcial, enquanto o usuário digita).
  static String format(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 11; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('-');
    }
    return buffer.toString();
  }

  /// Valida um CPF (aceita com ou sem máscara).
  static bool isValid(String value) {
    final digits = strip(value);

    if (digits.length != 11) return false;

    // Rejeita sequências repetidas (111.111.111-11 etc.), que passam
    // matematicamente no cálculo mas nunca existem na Receita Federal.
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;

    final numbers = digits.split('').map(int.parse).toList();

    final dv1 = _calculateDigit(numbers.sublist(0, 9), 10);
    if (dv1 != numbers[9]) return false;

    final dv2 = _calculateDigit(numbers.sublist(0, 10), 11);
    if (dv2 != numbers[10]) return false;

    return true;
  }

  /// Calcula um dígito verificador a partir de uma lista de dígitos base,
  /// usando pesos decrescentes a partir de [startWeight].
  static int _calculateDigit(List<int> digits, int startWeight) {
    var sum = 0;
    var weight = startWeight;
    for (final digit in digits) {
      sum += digit * weight;
      weight--;
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}

/// -----------------------------------------------------------------------
/// _CpfInputFormatter
/// -----------------------------------------------------------------------
/// TextInputFormatter que aplica a máscara XXX.XXX.XXX-XX conforme o
/// usuário digita, limitando a 11 dígitos.
/// -----------------------------------------------------------------------
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = CpfValidator.strip(newValue.text);

    // Se o usuário apagou (backspace) um caractere de máscara (. ou -), a
    // contagem de dígitos não muda e o formatter recolocaria a mesma
    // pontuação — dando a impressão de que o backspace não fez nada. Nesse
    // caso, remove também o último dígito.
    final isDeleting = newValue.text.length < oldValue.text.length;
    final oldDigits = CpfValidator.strip(oldValue.text);
    if (isDeleting && digits.length == oldDigits.length && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }

    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = CpfValidator.format(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// -----------------------------------------------------------------------
/// CpfField
/// -----------------------------------------------------------------------
/// Widget pronto para uso em formulários: aplica máscara automaticamente,
/// valida o dígito verificador em tempo real e mostra feedback visual
/// (borda, ícone e mensagem de erro).
///
/// Uso básico:
/// ```dart
/// final cpfController = TextEditingController();
///
/// CpfField(
///   controller: cpfController,
///   onValidCpf: (cpfDigits) {
///     // cpfDigits vem sem máscara, pronto para enviar ao backend
///   },
/// )
/// ```
///
/// Uso dentro de um Form:
/// ```dart
/// Form(
///   key: formKey,
///   child: CpfField(controller: cpfController),
/// )
/// ...
/// if (formKey.currentState!.validate()) { ... }
/// ```
/// -----------------------------------------------------------------------
class CpfField extends StatefulWidget {
  const CpfField({
    super.key,
    required this.controller,
    this.label = 'CPF',
    this.hint = '000.000.000-00',
    this.errorText = 'CPF inválido',
    this.requiredText = 'CPF é obrigatório',
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onValidCpf,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String errorText;
  final String requiredText;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  /// Chamado quando o CPF digitado se torna válido.
  /// Retorna o CPF apenas com dígitos (sem máscara).
  final ValueChanged<String>? onValidCpf;

  /// Chamado a cada alteração no campo, válido ou não.
  final ValueChanged<String>? onChanged;

  @override
  State<CpfField> createState() => _CpfFieldState();
}

class _CpfFieldState extends State<CpfField> {
  bool? _isValid; // null = ainda não avaliado (campo vazio ou intocado)

  void _handleChanged(String value) {
    final digits = CpfValidator.strip(value);

    setState(() {
      _isValid = digits.isEmpty ? null : CpfValidator.isValid(value);
    });

    widget.onChanged?.call(value);

    if (_isValid == true) {
      widget.onValidCpf?.call(digits);
    }
  }

  String? _validator(String? value) {
    final digits = CpfValidator.strip(value ?? '');
    if (digits.isEmpty) return widget.requiredText;
    if (!CpfValidator.isValid(value!)) return widget.errorText;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CpfInputFormatter(),
      ],
      autovalidateMode: widget.autovalidateMode,
      onChanged: _handleChanged,
      validator: _validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: _buildSuffixIcon(),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isValid == null) return null;
    return Icon(
      _isValid! ? Icons.check_circle : Icons.error,
      color: _isValid! ? Colors.green : Colors.red,
    );
  }
}
