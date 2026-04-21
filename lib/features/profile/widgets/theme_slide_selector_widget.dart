import 'package:flutter/material.dart';
import 'package:incasa_app/core/constants/theme_mode_constants.dart';

class ThemeSlideSelectorWidget extends StatefulWidget {
  final AppThemeMode currentMode;
  final Function(AppThemeMode) onModeSelected;
  final VoidCallback onCollapse;

  const ThemeSlideSelectorWidget({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    required this.onCollapse,
  });

  @override
  State<ThemeSlideSelectorWidget> createState() =>
      _ThemeSlideSelectorWidgetState();
}

class _ThemeSlideSelectorWidgetState extends State<ThemeSlideSelectorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSelection(AppThemeMode mode) {
    _controller.reverse().then((_) {
      widget.onModeSelected(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCollapse,
      behavior: HitTestBehavior.opaque,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            final isSelected = mode == widget.currentMode;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleSelection(mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForMode(mode),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          mode.displayName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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
