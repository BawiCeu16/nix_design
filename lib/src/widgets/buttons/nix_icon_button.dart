import 'package:flutter/material.dart';
import '../../theme/nix_size.dart';
import '../../theme/nix_theme_data.dart';
import 'nix_button.dart';

/// A stadium/circular pill icon button with Material 3 Expressive shape morphing
/// across hover, focus, and press/hold states.
///
/// In idle state, the button is circular/stadium. When hovered or focused, it softens into
/// an intermediate squircle. When pressed or held, it snaps into a crisp squircle.
class NixIconButton extends StatefulWidget {
  const NixIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.variant = NixButtonVariant.ghost,
    this.size = NixSize.medium,
    this.tooltip,
    this.badge,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.autofocus = false,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  });

  const NixIconButton.filled({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.size = NixSize.medium,
    this.tooltip,
    this.badge,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.autofocus = false,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.filled;

  const NixIconButton.tonal({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.size = NixSize.medium,
    this.tooltip,
    this.badge,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.autofocus = false,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.tonal;

  const NixIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.size = NixSize.medium,
    this.tooltip,
    this.badge,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.autofocus = false,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.outlined;

  final Widget icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final NixButtonVariant variant;
  final NixSize size;
  final String? tooltip;
  final Widget? badge;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? pressedRadius;
  final ShapeBorder? pressedShape;
  final double? hoveredRadius;
  final ShapeBorder? hoveredShape;
  final bool enableShapeMorph;
  final Duration? shapeMorphDuration;

  bool get enabled => onPressed != null;

  @override
  State<NixIconButton> createState() => _NixIconButtonState();
}

class _NixIconButtonState extends State<NixIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shapeController;
  late final Animation<double> _shapeAnimation;

  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;

  ShapeBorder? _startShape;
  ShapeBorder? _targetShape;

  @override
  void initState() {
    super.initState();
    _shapeController = AnimationController(
      vsync: this,
      duration: widget.shapeMorphDuration ?? const Duration(milliseconds: 90),
    );
    _shapeAnimation = CurvedAnimation(
      parent: _shapeController,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _shapeController.dispose();
    super.dispose();
  }

  double _defaultPressedRadius(NixSize size) {
    switch (size) {
      case NixSize.small:
        return 6.0;
      case NixSize.medium:
        return 8.0;
      case NixSize.large:
        return 10.0;
    }
  }

  double _defaultHoveredRadius(NixSize size) {
    switch (size) {
      case NixSize.small:
        return 11.0;
      case NixSize.medium:
        return 15.0;
      case NixSize.large:
        return 19.0;
    }
  }

  ShapeBorder _resolveTargetShape({
    required NixThemeData nixTheme,
    required BorderSide borderSide,
    required Color primaryColor,
  }) {
    final restingShape = StadiumBorder(side: borderSide);
    if (!widget.enabled || !widget.enableShapeMorph || !nixTheme.enableExpressiveShapeMorph) {
      return restingShape;
    }

    if (_isPressed) {
      final pr = widget.pressedRadius ?? nixTheme.buttonPressedRadius ?? _defaultPressedRadius(widget.size);
      return widget.pressedShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pr),
            side: borderSide,
          );
    }

    if (_isHovered || _isFocused) {
      final hr = widget.hoveredRadius ?? nixTheme.buttonHoveredRadius ?? _defaultHoveredRadius(widget.size);
      final effectiveFocusSide = _isFocused
          ? BorderSide(color: primaryColor, width: 2.0)
          : borderSide;
      return widget.hoveredShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(hr),
            side: effectiveFocusSide,
          );
    }

    return restingShape;
  }

  void _updateState({
    bool? pressed,
    bool? hovered,
    bool? focused,
    required NixThemeData nixTheme,
    required BorderSide borderSide,
    required Color primaryColor,
  }) {
    final wasPressed = _isPressed;
    final wasHovered = _isHovered;
    final wasFocused = _isFocused;

    if (pressed != null) _isPressed = pressed;
    if (hovered != null) _isHovered = hovered;
    if (focused != null) _isFocused = focused;

    if (wasPressed != _isPressed || wasHovered != _isHovered || wasFocused != _isFocused) {
      final newTarget = _resolveTargetShape(
        nixTheme: nixTheme,
        borderSide: borderSide,
        primaryColor: primaryColor,
      );

      _startShape = _getCurrentShape(borderSide);
      _targetShape = newTarget;

      final Duration targetDuration;
      if (_isPressed) {
        targetDuration = widget.shapeMorphDuration ?? nixTheme.shapeMorphDuration;
      } else {
        targetDuration = const Duration(milliseconds: 120);
      }

      _shapeController.duration = targetDuration;
      _shapeController.reset();
      _shapeController.forward();
    }
  }

  ShapeBorder _getCurrentShape(BorderSide borderSide) {
    final restingShape = StadiumBorder(side: borderSide);
    final from = _startShape ?? restingShape;
    final to = _targetShape ?? restingShape;

    if (_shapeController.value == 0.0) return from;
    if (_shapeController.value == 1.0) return to;
    return ShapeBorder.lerp(from, to, _shapeAnimation.value) ?? to;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    Color bg;
    Color fg;
    Color? border;

    switch (widget.variant) {
      case NixButtonVariant.filled:
        bg = widget.backgroundColor ?? (nixTheme.primary ?? colors.primary);
        fg = widget.foregroundColor ?? (nixTheme.onPrimary ?? colors.onPrimary);
        border = null;
        break;
      case NixButtonVariant.tonal:
        bg = widget.backgroundColor ?? (nixTheme.surfaceContainer ?? colors.surfaceContainerHighest);
        fg = widget.foregroundColor ?? (nixTheme.onSurface ?? colors.onSurfaceVariant);
        border = null;
        break;
      case NixButtonVariant.outlined:
        bg = widget.backgroundColor ?? Colors.transparent;
        fg = widget.foregroundColor ?? (nixTheme.primary ?? colors.primary);
        border = widget.borderColor ?? (nixTheme.outline ?? colors.outline);
        break;
      case NixButtonVariant.text:
      case NixButtonVariant.ghost:
        bg = widget.backgroundColor ?? Colors.transparent;
        fg = widget.foregroundColor ?? (nixTheme.onSurface ?? colors.onSurface);
        border = null;
        break;
    }

    final disabledFg = colors.onSurface.withValues(alpha: 0.38);
    final disabledBg = colors.onSurface.withValues(alpha: 0.12);

    final finalBg = widget.enabled
        ? bg
        : (widget.variant == NixButtonVariant.filled || widget.variant == NixButtonVariant.tonal
            ? disabledBg
            : Colors.transparent);
    final finalFg = widget.enabled ? fg : disabledFg;

    final borderSide = border != null && widget.enabled
        ? BorderSide(color: border, width: 1.2)
        : BorderSide.none;

    final primaryColor = nixTheme.primary ?? colors.primary;

    if (_targetShape == null) {
      _startShape = StadiumBorder(side: borderSide);
      _targetShape = StadiumBorder(side: borderSide);
    }

    final dimension = widget.size.height;

    Widget content = IconTheme(
      data: IconThemeData(
        color: finalFg,
        size: widget.size.iconSize,
      ),
      child: widget.icon,
    );

    if (widget.badge != null) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          content,
          Positioned(
            top: 2,
            right: 2,
            child: widget.badge!,
          ),
        ],
      );
    }

    final shouldMorph = widget.enableShapeMorph && nixTheme.enableExpressiveShapeMorph && widget.enabled;

    Widget button = AnimatedBuilder(
      animation: _shapeAnimation,
      builder: (context, _) {
        final currentShape = _getCurrentShape(borderSide);

        return Material(
          color: finalBg,
          shape: currentShape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: currentShape,
            onTap: widget.enabled ? widget.onPressed : null,
            onLongPress: widget.enabled ? widget.onLongPress : null,
            onTapDown: shouldMorph
                ? (_) => _updateState(
                      pressed: true,
                      nixTheme: nixTheme,
                      borderSide: borderSide,
                      primaryColor: primaryColor,
                    )
                : null,
            onTapUp: shouldMorph
                ? (_) => _updateState(
                      pressed: false,
                      nixTheme: nixTheme,
                      borderSide: borderSide,
                      primaryColor: primaryColor,
                    )
                : null,
            onTapCancel: shouldMorph
                ? () => _updateState(
                      pressed: false,
                      nixTheme: nixTheme,
                      borderSide: borderSide,
                      primaryColor: primaryColor,
                    )
                : null,
            onHover: shouldMorph
                ? (hovered) => _updateState(
                      hovered: hovered,
                      nixTheme: nixTheme,
                      borderSide: borderSide,
                      primaryColor: primaryColor,
                    )
                : null,
            onFocusChange: shouldMorph
                ? (focused) => _updateState(
                      focused: focused,
                      nixTheme: nixTheme,
                      borderSide: borderSide,
                      primaryColor: primaryColor,
                    )
                : null,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            child: SizedBox(
              width: dimension,
              height: dimension,
              child: Center(child: content),
            ),
          ),
        );
      },
    );

    if (shouldMorph) {
      button = Listener(
        onPointerDown: (_) => _updateState(
          pressed: true,
          nixTheme: nixTheme,
          borderSide: borderSide,
          primaryColor: primaryColor,
        ),
        onPointerUp: (_) => _updateState(
          pressed: false,
          nixTheme: nixTheme,
          borderSide: borderSide,
          primaryColor: primaryColor,
        ),
        onPointerCancel: (_) => _updateState(
          pressed: false,
          nixTheme: nixTheme,
          borderSide: borderSide,
          primaryColor: primaryColor,
        ),
        behavior: HitTestBehavior.translucent,
        child: button,
      );
    }

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
