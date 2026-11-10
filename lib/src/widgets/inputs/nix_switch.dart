import 'package:flutter/material.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';

/// A stadium/pill toggle switch following Flutter's native [Switch] ergonomics
/// with animated color transitions and an accessible 48x48 tap target area.
class NixSwitch extends StatefulWidget {
  const NixSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.materialTapTargetSize,
    this.focusNode,
    this.autofocus = false,
    this.duration,
    this.curve,
  });

  /// Whether this switch is turned on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Custom active thumb color.
  final Color? activeColor;

  /// Custom inactive thumb color.
  final Color? inactiveColor;

  /// Custom active track color.
  final Color? activeTrackColor;

  /// Custom inactive track color.
  final Color? inactiveTrackColor;

  /// Static thumb color override.
  final Color? thumbColor;

  /// Configures the minimum size of the tap target.
  ///
  /// Defaults to [MaterialTapTargetSize.padded], which expands the interactive
  /// area to at least 48x48 dp ([kMinInteractiveDimension]) without changing
  /// the visual dimensions of the switch.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether to autofocus this switch.
  final bool autofocus;

  /// Duration of the toggle and color change animation.
  ///
  /// Defaults to [NixThemeData.animationDuration] (200ms).
  final Duration? duration;

  /// Curve of the toggle and color change animation.
  ///
  /// Defaults to [NixThemeData.animationCurve] ([Curves.easeOutCubic]).
  final Curve? curve;

  bool get enabled => onChanged != null;

  @override
  State<NixSwitch> createState() => _NixSwitchState();
}

class _NixSwitchState extends State<NixSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeOutCubic,
      reverseCurve: (widget.curve ?? Curves.easeOutCubic).flipped,
    );
  }

  @override
  void didUpdateWidget(NixSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration && widget.duration != null) {
      _controller.duration = widget.duration!;
    }
    if (widget.curve != oldWidget.curve && widget.curve != null) {
      _curvedAnimation.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve!,
        reverseCurve: widget.curve!.flipped,
      );
    }
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled) {
      widget.onChanged!(!widget.value);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    const travelDistance = 18.0;
    _controller.value += details.primaryDelta! / travelDistance;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    if (_controller.value >= 0.5) {
      if (!widget.value) {
        widget.onChanged!(true);
      } else {
        _controller.forward();
      }
    } else {
      if (widget.value) {
        widget.onChanged!(false);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    const trackWidth = 50.0;
    const trackHeight = 28.0;
    const thumbHeight = 22.0;
    const thumbWidth = 32.0;
    const padding = 3.0;

    final effectiveActiveTrack = widget.activeTrackColor ??
        (nixTheme.primary ?? colors.primary);
    final effectiveInactiveTrack = widget.inactiveTrackColor ??
        (nixTheme.surfaceContainerHigh ?? colors.surfaceContainerHighest);

    final effectiveActiveThumb = widget.thumbColor ??
        widget.activeColor ??
        (nixTheme.onPrimary ?? colors.onPrimary);
    final effectiveInactiveThumb = widget.thumbColor ??
        widget.inactiveColor ??
        colors.outline;

    final trackColorAnimation = ColorTween(
      begin: effectiveInactiveTrack,
      end: effectiveActiveTrack,
    ).animate(_curvedAnimation);

    final thumbColorAnimation = ColorTween(
      begin: effectiveInactiveThumb,
      end: effectiveActiveThumb,
    ).animate(_curvedAnimation);

    final alignmentAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(_curvedAnimation);

    final effectiveTapTargetSize =
        widget.materialTapTargetSize ?? theme.materialTapTargetSize;
    final bool isPadded =
        effectiveTapTargetSize == MaterialTapTargetSize.padded;
    final minTapWidth = isPadded ? kMinInteractiveDimension : 0.0;
    final minTapHeight = isPadded ? kMinInteractiveDimension : 0.0;

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      child: Semantics(
        toggled: widget.value,
        enabled: widget.enabled,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.enabled ? _handleTap : null,
            onHorizontalDragStart: widget.enabled ? _handleDragStart : null,
            onHorizontalDragUpdate: widget.enabled ? _handleDragUpdate : null,
            onHorizontalDragEnd: widget.enabled ? _handleDragEnd : null,
            behavior: HitTestBehavior.opaque,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minTapWidth,
                minHeight: minTapHeight,
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final currentTrackColor =
                        trackColorAnimation.value ?? effectiveInactiveTrack;
                    final currentThumbColor =
                        thumbColorAnimation.value ?? effectiveInactiveThumb;

                    final displayTrackColor = widget.enabled
                        ? currentTrackColor
                        : currentTrackColor.withValues(alpha: 0.38);
                    final displayThumbColor = widget.enabled
                        ? currentThumbColor
                        : currentThumbColor.withValues(alpha: 0.38);

                    return Container(
                      width: trackWidth,
                      height: trackHeight,
                      decoration: ShapeDecoration(
                        color: displayTrackColor,
                        shape: NixGeometry.stadiumBorder,
                      ),
                      padding: const EdgeInsets.all(padding),
                      child: Align(
                        alignment: alignmentAnimation.value,
                        child: Container(
                          width: thumbWidth,
                          height: thumbHeight,
                          decoration: ShapeDecoration(
                            color: displayThumbColor,
                            shape: NixGeometry.stadiumBorder,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
