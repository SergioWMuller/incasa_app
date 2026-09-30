import 'package:flutter/material.dart';

BoxDecoration neumorphicDecoration(
  BuildContext context, {
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
  Color? color,
  double depth = 5,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return BoxDecoration(
    color: color ?? colorScheme.surface,
    borderRadius: borderRadius,
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: isDark ? 0.34 : 0.12),
        offset: Offset(depth, depth),
        blurRadius: depth * 2.4,
      ),
      BoxShadow(
        color: (isDark ? colorScheme.surfaceContainerHighest : Colors.white)
            .withValues(alpha: isDark ? 0.24 : 0.9),
        offset: Offset(-depth, -depth),
        blurRadius: depth * 2.4,
      ),
    ],
  );
}

class NeumorphicSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final BoxConstraints? constraints;
  final Color? color;
  final VoidCallback? onTap;
  final double depth;

  const NeumorphicSurface({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.constraints,
    this.color,
    this.onTap,
    this.depth = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: constraints,
      decoration: neumorphicDecoration(
        context,
        borderRadius: borderRadius,
        color: color,
        depth: depth,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}
