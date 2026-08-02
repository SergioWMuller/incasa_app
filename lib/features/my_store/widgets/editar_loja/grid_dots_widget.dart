import 'package:flutter/material.dart';

/// Camada de fundo do grid (ai/EDITAR_LOJA_VIEW.md §5) — desenha pontos
/// cinza nas interseções entre unidades, dando ao usuário noção visual dos
/// 6 espaços horizontais e das linhas verticais do grid.
class GridDotsWidget extends StatelessWidget {
  final double unidadeMedida;
  final int colunas;
  final int linhas;

  const GridDotsWidget({
    super.key,
    required this.unidadeMedida,
    required this.linhas,
    this.colunas = 6,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(colunas * unidadeMedida, linhas * unidadeMedida),
        painter: _GridDotsPainter(
          unidadeMedida: unidadeMedida,
          colunas: colunas,
          linhas: linhas,
        ),
      ),
    );
  }
}

class _GridDotsPainter extends CustomPainter {
  final double unidadeMedida;
  final int colunas;
  final int linhas;

  const _GridDotsPainter({
    required this.unidadeMedida,
    required this.colunas,
    required this.linhas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withValues(alpha: 0.5);
    for (var col = 0; col <= colunas; col++) {
      for (var row = 0; row <= linhas; row++) {
        canvas.drawCircle(
          Offset(col * unidadeMedida, row * unidadeMedida),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridDotsPainter oldDelegate) {
    return oldDelegate.unidadeMedida != unidadeMedida ||
        oldDelegate.colunas != colunas ||
        oldDelegate.linhas != linhas;
  }
}
