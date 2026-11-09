import 'package:flutter/material.dart';
import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';
import '../common/nix_pressable.dart';

/// A stadium/pill filter chip with animated selection states.
class NixFilterChip extends StatelessWidget {
  const NixFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.avatar,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.showCheckmark = true,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final bool showCheckmark;

  bool get enabled => onSelected != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bg = selected
        ? (selectedColor ?? (nixTheme.primary ?? colors.primary))
        : (unselectedColor ?? (nixTheme.surfaceContainer ?? colors.surfaceContainerHighest.withValues(alpha: 0.5)));

    final fg = selected
        ? (selectedTextColor ?? (nixTheme.onPrimary ?? colors.onPrimary))
        : (unselectedTextColor ?? (nixTheme.onSurface ?? colors.onSurface));

    final shape = NixGeometry.stadiumBorder;

    return AnimatedContainer(
      duration: nixTheme.animationDuration,
      curve: nixTheme.animationCurve,
      child: Material(
        color: bg,
        shape: shape,
        child: NixPressable(
          onPressed: enabled ? () => onSelected!(!selected) : null,
          shape: shape,
          child: Container(
            height: 34.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showCheckmark && selected) ...[
                  Icon(Icons.check_rounded, size: 16.0, color: fg),
                  const SizedBox(width: 6.0),
                ] else if (avatar != null) ...[
                  avatar!,
                  const SizedBox(width: 6.0),
                ],
                DefaultTextStyle(
                  style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
