import 'package:flutter/material.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final AppThemeMode currentMode;
  final Function(AppThemeMode) onModeSelected;

  const ThemeSelectorWidget({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: AppThemeMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return ListTile(
          leading: Icon(
            _getIconForMode(mode),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(
            mode.displayName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => onModeSelected(mode),
        );
      }).toList(),
    );
  }

  IconData _getIconForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}
