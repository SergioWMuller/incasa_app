import 'package:flutter/material.dart';
import 'package:incasa_app/core/constants/theme_color_constants.dart';

class ColorSlideSelectorWidget extends StatefulWidget {
  final AppThemeColor currentColor;
  final Function(AppThemeColor) onColorSelected;
  final VoidCallback onCollapse;

  const ColorSlideSelectorWidget({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
    required this.onCollapse,
  });

  @override
  State<ColorSlideSelectorWidget> createState() =>
      _ColorSlideSelectorWidgetState();
}

class _ColorSlideSelectorWidgetState extends State<ColorSlideSelectorWidget>
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

  void _handleSelection(AppThemeColor color) {
    _controller.reverse().then((_) {
      widget.onColorSelected(color);
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
          children: AppThemeColor.values.map((color) {
            final isSelected = color == widget.currentColor;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleSelection(color),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: _getContrastColor(color.color),
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          color.displayName,
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

  Color _getContrastColor(Color color) {
    // Calcula a luminância relativa usando o padrão recomendado
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
