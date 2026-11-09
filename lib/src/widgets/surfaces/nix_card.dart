import 'package:flutter/material.dart';
import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';
import '../common/nix_pressable.dart';

/// Style variants of [NixCard].
enum NixCardVariant {
  /// Elevated card with shadow.
  elevated,

  /// Flat card with container background.
  filled,

  /// Card with an outline border.
  outlined,
}

/// A pill/capsule-rounded surface container following Flutter's native [Card] ergonomics.
class NixCard extends StatelessWidget {
  const NixCard({
    super.key,
    required this.child,
    this.variant = NixCardVariant.filled,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.isPill = false,
    this.elevation,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  });

  /// Factory for a full stadium pill card.
  const NixCard.pill({
    super.key,
    required this.child,
    this.variant = NixCardVariant.filled,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.elevation,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    this.margin = EdgeInsets.zero,
  })  : isPill = true,
        borderRadius = null;

  final Widget child;
  final NixCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool isPill;
  final double? elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    Color bg;
    Color? border;
    double resolvedElevation;

    switch (variant) {
      case NixCardVariant.elevated:
        bg = color ?? (nixTheme.surface ?? colors.surface);
        border = null;
        resolvedElevation = elevation ?? 2.0;
        break;
      case NixCardVariant.filled:
        bg = color ??
            (nixTheme.surfaceContainer ?? colors.surfaceContainerLow);
        border = null;
        resolvedElevation = elevation ?? 0.0;
        break;
      case NixCardVariant.outlined:
        bg = color ?? (nixTheme.surface ?? colors.surface);
        border = borderColor ?? (nixTheme.outlineVariant ?? colors.outlineVariant);
        resolvedElevation = elevation ?? 0.0;
        break;
    }

    final effectiveRadius = isPill
        ? NixGeometry.pillBorderRadius
        : (borderRadius ?? BorderRadius.circular(nixTheme.cardRadius));

    final effectiveShape = isPill
        ? StadiumBorder(
            side: border != null ? BorderSide(color: border) : BorderSide.none,
          )
        : RoundedRectangleBorder(
            borderRadius: effectiveRadius,
            side: border != null ? BorderSide(color: border) : BorderSide.none,
          );

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      content = NixPressable(
        onPressed: onTap,
        onLongPress: onLongPress,
        shape: effectiveShape,
        borderRadius: isPill ? null : effectiveRadius.resolve(Directionality.of(context)),
        child: content,
      );
    }

    return Padding(
      padding: margin,
      child: Material(
        color: bg,
        elevation: resolvedElevation,
        shape: effectiveShape,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
