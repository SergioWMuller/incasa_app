import 'package:flutter/material.dart';

/// Aplica o efeito de "wiggle" (leve rotação oscilante) a qualquer child,
/// sem exigir `StatefulWidget` próprio: usa `TweenAnimationBuilder`, cujo
/// gerenciamento de animação é interno do framework — a estratégia
/// recomendada em ai/EDITAR_LOJA_VIEW.md §7.3.
///
/// O Cubit apenas alterna `faseWiggle` entre 1 e -1 periodicamente; este
/// widget anima suavemente até o ângulo-alvo e usa o `id` do nó para
/// desincronizar a fase entre nós.
class WiggleWrapper extends StatelessWidget {
  static const double _anguloBaseRadianos = 0.02;

  final bool ativo;
  final double faseWiggle;
  final String nodeId;
  final Widget child;

  const WiggleWrapper({
    super.key,
    required this.ativo,
    required this.faseWiggle,
    required this.nodeId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final deslocamentoFase = (nodeId.hashCode % 100) / 100;
    final multiplicador = 0.7 + (deslocamentoFase * 0.6);
    final anguloAlvo = ativo
        ? _anguloBaseRadianos * faseWiggle * multiplicador
        : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: anguloAlvo),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
      builder: (context, angulo, child) {
        return Transform.rotate(angle: angulo, child: child);
      },
      child: child,
    );
  }
}
