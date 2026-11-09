import 'package:flutter/material.dart';
import '../../theme/nix_theme_data.dart';
import '../common/nix_pressable.dart';

/// A stadium/pill-shaped chip following Flutter's native [Chip] ergonomics.
class NixChip extends StatelessWidget {
  const NixChip({
    super.key,
    required this.label,
    this.avatar,
    this.deleteIcon,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
  });

  final Widget label;
  final Widget? avatar;
  final Widget? deleteIcon;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final defaultBg = nixTheme.surfaceContainer ?? colors.surfaceContainerHighest.withValues(alpha: 0.5);
    final defaultSelectedBg = nixTheme.primary ?? colors.primary;

    final bg = selected
        ? (selectedColor ?? defaultSelectedBg)
        : (backgroundColor ?? defaultBg);

    final fg = selected
        ? (textColor ?? (nixTheme.onPrimary ?? colors.onPrimary))
        : (textColor ?? (nixTheme.onSurface ?? colors.onSurface));

    final effectiveBorder = borderColor != null
        ? BorderSide(color: borderColor!, width: 1.0)
        : BorderSide.none;

    final shape = StadiumBorder(side: effectiveBorder);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (avatar != null) ...[
          CircleAvatar(
            radius: 10.0,
            backgroundColor: Colors.transparent,
            child: avatar,
          ),
          const SizedBox(width: 6.0),
        ],
        DefaultTextStyle(
          style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13.0,
          ),
          child: label,
        ),
        if (onDeleted != null) ...[
          const SizedBox(width: 6.0),
          GestureDetector(
            onTap: onDeleted,
            child: IconTheme(
              data: IconThemeData(
                color: fg.withValues(alpha: 0.7),
                size: 16.0,
              ),
              child: deleteIcon ?? const Icon(Icons.cancel_rounded),
            ),
          ),
        ],
      ],
    );

    Widget chip = Material(
      color: bg,
      elevation: elevation,
      shape: shape,
      child: NixPressable(
        onPressed: onPressed,
        shape: shape,
        child: Container(
          height: 32.0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    return chip;
  }
}
