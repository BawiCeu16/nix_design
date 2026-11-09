import 'package:flutter/material.dart';

import '../../theme/nix_size.dart';
import '../../theme/nix_theme_data.dart';

/// Visual variants of [NixButton].
enum NixButtonVariant {
  /// Prominent solid filled pill button.
  filled,

  /// Soft tonal pill button for secondary actions.
  tonal,

  /// Outlined pill button with a subtle border.
  outlined,

  /// Borderless text pill button.
  text,

  /// Minimal ghost button that blends into the background.
  ghost,
}

/// A signature stadium/pill-shaped button following Flutter's native ergonomics
/// with Material 3 Expressive shape morphing across hover, focus, and press/hold states.
///
/// In idle state, the button is a full stadium pill. When hovered or focused, its corner
/// radius subtly transitions into an expressive pill-squircle. When pressed or held, it
/// snaps into a crisp, defined squircle without shrinking or scaling the overall button dimensions.
class NixButton extends StatefulWidget {
  /// Creates a standard filled pill button.
  const NixButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.variant = NixButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Creates a primary filled pill button.
  const NixButton.filled({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.filled,
       assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Creates a secondary tonal pill button.
  const NixButton.tonal({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.tonal,
       assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Creates an outlined pill button with a stadium border.
  const NixButton.outlined({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.outlined,
       assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Creates a text pill button without borders or solid background.
  const NixButton.text({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.text,
       assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Creates a ghost pill button.
  const NixButton.ghost({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.label,
    this.icon,
    this.size = NixSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation = 0.0,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.pressedRadius,
    this.pressedShape,
    this.hoveredRadius,
    this.hoveredShape,
    this.enableShapeMorph = true,
    this.shapeMorphDuration,
  }) : variant = NixButtonVariant.ghost,
       assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// Callback when the button is tapped. If null, button appears disabled.
  final VoidCallback? onPressed;

  /// Optional long press callback.
  final VoidCallback? onLongPress;

  /// Arbitrary custom widget inside the pill.
  final Widget? child;

  /// Text or label widget inside the button.
  final Widget? label;

  /// Optional leading icon.
  final Widget? icon;

  /// The size tier: [NixSize.small], [NixSize.medium], or [NixSize.large].
  final NixSize size;

  /// The visual style variant.
  final NixButtonVariant variant;

  /// When true, renders a pill spinner in place of/alongside content and disables interaction.
  final bool isLoading;

  /// Whether the button expands to fill maximum horizontal space.
  final bool isExpanded;

  /// Custom background override. If omitted, derives from theme.
  final Color? backgroundColor;

  /// Custom foreground/text color override. If omitted, derives from theme.
  final Color? foregroundColor;

  /// Custom border color for outlined variant.
  final Color? borderColor;

  /// Custom internal padding.
  final EdgeInsetsGeometry? padding;

  /// Elevation of the button shadow.
  final double elevation;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether to autofocus this button.
  final bool autofocus;

  /// Accessibility label.
  final String? semanticLabel;

  /// Custom corner radius for the pressed/held squircle state.
  final double? pressedRadius;

  /// Custom shape override for the pressed/held squircle state.
  final ShapeBorder? pressedShape;

  /// Custom corner radius for the hovered/focused state.
  final double? hoveredRadius;

  /// Custom shape override for the hovered/focused state.
  final ShapeBorder? hoveredShape;

  /// Whether to enable Material 3 Expressive corner shape morphing on press/hold/hover.
  final bool enableShapeMorph;

  /// Custom animation duration for the shape morph transition. Defaults to snappy 90ms.
  final Duration? shapeMorphDuration;

  bool get enabled => onPressed != null && !isLoading;

  @override
  State<NixButton> createState() => _NixButtonState();
}

class _NixButtonState extends State<NixButton>
    with SingleTickerProviderStateMixin {
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
    if (!widget.enabled ||
        !widget.enableShapeMorph ||
        !nixTheme.enableExpressiveShapeMorph) {
      return restingShape;
    }

    if (_isPressed) {
      final pr =
          widget.pressedRadius ??
          nixTheme.buttonPressedRadius ??
          _defaultPressedRadius(widget.size);
      return widget.pressedShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pr),
            side: borderSide,
          );
    }

    if (_isHovered || _isFocused) {
      final hr =
          widget.hoveredRadius ??
          nixTheme.buttonHoveredRadius ??
          _defaultHoveredRadius(widget.size);
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

    if (wasPressed != _isPressed ||
        wasHovered != _isHovered ||
        wasFocused != _isFocused) {
      final newTarget = _resolveTargetShape(
        nixTheme: nixTheme,
        borderSide: borderSide,
        primaryColor: primaryColor,
      );

      _startShape = _getCurrentShape(borderSide);
      _targetShape = newTarget;

      final Duration targetDuration;
      if (_isPressed) {
        targetDuration =
            widget.shapeMorphDuration ?? nixTheme.shapeMorphDuration;
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

    // Resolve colors according to variant and theme
    final resolvedColors = _resolveColors(nixTheme, colors);
    final effectiveBg = widget.backgroundColor ?? resolvedColors.bg;
    final effectiveFg = widget.foregroundColor ?? resolvedColors.fg;
    final effectiveBorder = widget.borderColor ?? resolvedColors.border;

    final disabledFg = colors.onSurface.withValues(alpha: 0.38);
    final disabledBg = colors.onSurface.withValues(alpha: 0.12);

    final finalBg = widget.enabled
        ? effectiveBg
        : (widget.variant == NixButtonVariant.filled ||
                  widget.variant == NixButtonVariant.tonal
              ? disabledBg
              : Colors.transparent);
    final finalFg = widget.enabled ? effectiveFg : disabledFg;

    final borderSide = effectiveBorder != null && widget.enabled
        ? BorderSide(color: effectiveBorder, width: 1.2)
        : BorderSide.none;

    final primaryColor = nixTheme.primary ?? colors.primary;

    if (_targetShape == null) {
      _startShape = StadiumBorder(side: borderSide);
      _targetShape = StadiumBorder(side: borderSide);
    }

    final effectivePadding = widget.padding ?? widget.size.horizontalPadding;
    final defaultTextStyle = (theme.textTheme.labelLarge ?? const TextStyle())
        .copyWith(
          fontSize: widget.size.fontSize,
          fontWeight: FontWeight.w600,
          color: finalFg,
          letterSpacing: 0.2,
        );

    Widget content;
    if (widget.isLoading) {
      final spinnerSize = widget.size.iconSize;
      content = SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(finalFg),
        ),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      final List<Widget> children = [];
      if (widget.icon != null) {
        children.add(
          IconTheme(
            data: IconThemeData(color: finalFg, size: widget.size.iconSize),
            child: widget.icon!,
          ),
        );
        if (widget.label != null) {
          children.add(SizedBox(width: widget.size.iconSpacing));
        }
      }
      if (widget.label != null) {
        children.add(widget.label!);
      }
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    final shouldMorph =
        widget.enableShapeMorph &&
        nixTheme.enableExpressiveShapeMorph &&
        widget.enabled;

    Widget button = AnimatedBuilder(
      animation: _shapeAnimation,
      builder: (context, _) {
        final currentShape = _getCurrentShape(borderSide);

        return Material(
          color: finalBg,
          elevation: widget.enabled
              ? (_isHovered && widget.elevation > 0
                    ? widget.elevation + 1.5
                    : widget.elevation)
              : 0.0,
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
            child: Container(
              height: widget.size.height,
              padding: effectivePadding,
              alignment: Alignment.center,
              child: DefaultTextStyle(style: defaultTextStyle, child: content),
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

    if (widget.isExpanded) {
      final childWidget = button;
      button = LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedWidth) {
            return SizedBox(width: constraints.maxWidth, child: childWidget);
          }
          return childWidget;
        },
      );
    }

    if (widget.semanticLabel != null) {
      button = Semantics(
        button: true,
        label: widget.semanticLabel,
        enabled: widget.enabled,
        child: button,
      );
    }

    return button;
  }

  _ColorBundle _resolveColors(NixThemeData nix, ColorScheme colors) {
    switch (widget.variant) {
      case NixButtonVariant.filled:
        return _ColorBundle(
          bg: nix.primary ?? colors.primary,
          fg: nix.onPrimary ?? colors.onPrimary,
          border: null,
        );
      case NixButtonVariant.tonal:
        return _ColorBundle(
          bg: nix.surfaceContainer ?? colors.surfaceContainerHighest,
          fg: nix.onSurface ?? colors.onSurfaceVariant,
          border: null,
        );
      case NixButtonVariant.outlined:
        return _ColorBundle(
          bg: Colors.transparent,
          fg: nix.primary ?? colors.primary,
          border: nix.outline ?? colors.outline,
        );
      case NixButtonVariant.text:
        return _ColorBundle(
          bg: Colors.transparent,
          fg: nix.primary ?? colors.primary,
          border: null,
        );
      case NixButtonVariant.ghost:
        return _ColorBundle(
          bg: Colors.transparent,
          fg: nix.onSurface ?? colors.onSurface,
          border: null,
        );
    }
  }
}

class _ColorBundle {
  const _ColorBundle({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}
