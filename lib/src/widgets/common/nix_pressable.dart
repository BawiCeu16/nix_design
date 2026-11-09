import 'package:flutter/material.dart';

/// A wrapper that applies native Flutter ripple and interaction to pill components
/// without any scale, shrink, or size-altering animations.
class NixPressable extends StatelessWidget {
  const NixPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.shape = const StadiumBorder(),
    this.borderRadius,
    this.cursor,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ShapeBorder shape;
  final BorderRadius? borderRadius;
  final MouseCursor? cursor;
  final FocusNode? focusNode;
  final bool autofocus;

  bool get enabled => onPressed != null || onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      customBorder: borderRadius != null ? null : shape,
      borderRadius: borderRadius,
      onTap: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      mouseCursor: cursor,
      child: child,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: content,
    );
  }
}
