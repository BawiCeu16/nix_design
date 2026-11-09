import 'package:flutter/material.dart';
import '../../theme/nix_theme_data.dart';

/// A pill-shaped grouped cluster for multiple buttons.
class NixButtonGroup extends StatelessWidget {
  const NixButtonGroup({
    super.key,
    required this.children,
    this.backgroundColor,
    this.borderColor,
    this.spacing = 4.0,
    this.padding = const EdgeInsets.all(4.0),
  });

  /// The buttons inside the group.
  final List<Widget> children;

  /// Background color of the grouping pill.
  final Color? backgroundColor;

  /// Optional border around the grouping pill.
  final Color? borderColor;

  /// Spacing between buttons.
  final double spacing;

  /// Padding around the buttons inside the grouping pill.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bg = backgroundColor ?? (nixTheme.surfaceContainer ?? colors.surfaceContainerHighest.withValues(alpha: 0.5));
    final border = borderColor;

    return Material(
      color: bg,
      shape: StadiumBorder(
        side: border != null ? BorderSide(color: border) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
