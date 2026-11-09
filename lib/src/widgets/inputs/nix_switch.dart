import 'package:flutter/material.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';

/// A stadium/pill toggle switch following Flutter's native [Switch] ergonomics.
class NixSwitch extends StatelessWidget {
  const NixSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.focusNode,
    this.autofocus = false,
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

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether to autofocus this switch.
  final bool autofocus;

  bool get enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    const trackWidth = 50.0;
    const trackHeight = 28.0;
    const thumbSize = 22.0;
    const padding = 3.0;

    final effectiveActiveTrack =
        activeTrackColor ?? (nixTheme.primary ?? colors.primary);
    final effectiveInactiveTrack =
        inactiveTrackColor ??
        (nixTheme.surfaceContainerHigh ?? colors.surfaceContainerHighest);

    final effectiveActiveThumb =
        thumbColor ?? activeColor ?? (nixTheme.onPrimary ?? colors.onPrimary);
    final effectiveInactiveThumb =
        thumbColor ?? inactiveColor ?? colors.outline;

    final trackColor = value ? effectiveActiveTrack : effectiveInactiveTrack;
    final finalThumbColor = value
        ? effectiveActiveThumb
        : effectiveInactiveThumb;

    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: nixTheme.animationDuration,
          curve: nixTheme.animationCurve,
          width: trackWidth,
          height: trackHeight,
          decoration: ShapeDecoration(
            color: enabled ? trackColor : trackColor.withValues(alpha: 0.38),
            shape: NixGeometry.stadiumBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: AnimatedAlign(
              duration: nixTheme.animationDuration,
              curve: nixTheme.animationCurve,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: ShapeDecoration(
                  color: enabled
                      ? finalThumbColor
                      : finalThumbColor.withValues(alpha: 0.38),
                  shape: const CircleBorder(),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      // blurRadius: 3,
                      // offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
