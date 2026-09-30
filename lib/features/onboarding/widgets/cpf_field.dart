import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final digits = CPFValidator.strip(value);

    setState(() {
      _isValid = digits.isEmpty ? null : CPFValidator.isValid(value);
    });

    widget.onChanged?.call(value);

    if (_isValid == true) {
      widget.onValidCpf?.call(digits);
    }
  }

  String? _validator(String? value) {
    final digits = CPFValidator.strip(value ?? '');
    if (digits.isEmpty) return widget.requiredText;
    if (!CPFValidator.isValid(value!)) return widget.errorText;
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
        CpfInputFormatter(),
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
