import 'package:flutter/material.dart';

enum AppThemeColor {
  orange,
  blue,
  green,
  red,
  purple,
  pink,
  yellow,
  black;

  String get displayName {
    switch (this) {
      case AppThemeColor.orange:
        return 'Laranja';
      case AppThemeColor.blue:
        return 'Azul';
      case AppThemeColor.green:
        return 'Verde';
      case AppThemeColor.red:
        return 'Vermelho';
      case AppThemeColor.purple:
        return 'Roxo';
      case AppThemeColor.pink:
        return 'Rosa';
      case AppThemeColor.yellow:
        return 'Amarelo';
      case AppThemeColor.black:
        return 'Preto';
    }
  }

  Color get color {
    switch (this) {
      case AppThemeColor.orange:
        return const Color(0xFFFF6B35); // Deep Orange
      case AppThemeColor.blue:
        return const Color(0xFF2196F3); // Blue
      case AppThemeColor.green:
        return const Color(0xFF4CAF50); // Green
      case AppThemeColor.red:
        return const Color(0xFFF44336); // Red
      case AppThemeColor.purple:
        return const Color(0xFF9C27B0); // Purple
      case AppThemeColor.pink:
        return const Color(0xFFE91E63); // Pink
      case AppThemeColor.yellow:
        return const Color(0xFFFFC107); // Amber/Yellow
      case AppThemeColor.black:
        return const Color(0xFF212121); // Dark Grey (quase preto)
    }
  }

  static AppThemeColor fromString(String value) {
    return AppThemeColor.values.firstWhere(
      (color) => color.name == value,
      orElse: () => AppThemeColor.blue,
    );
  }
}
