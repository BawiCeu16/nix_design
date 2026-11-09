import 'package:flutter/material.dart';

import 'nix_geometry.dart';

/// Theme configuration for the Nix Design System.
///
/// Implements Flutter's native [ThemeExtension] pattern so it can be registered
/// directly inside [ThemeData.extensions] or accessed via [NixThemeData.of].
///
/// If no custom [NixThemeData] is provided in the developer's app theme, all
/// colors and typography automatically derive from the developer's [ColorScheme]
/// and [TextTheme] defined in standard Flutter [ThemeData].
class NixThemeData extends ThemeExtension<NixThemeData> {
  const NixThemeData({
    this.primary,
    this.onPrimary,
    this.secondary,
    this.onSecondary,
    this.surface,
    this.onSurface,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.outline,
    this.outlineVariant,
    this.error,
    this.onError,
    this.cardRadius = 24.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.enablePressFeedback = true,
    this.enableExpressiveShapeMorph = true,
    this.shapeMorphDuration = const Duration(milliseconds: 90),
    this.buttonPressedRadius,
    this.buttonHoveredRadius,
  });

  /// Primary accent color for prominent pill elements.
  /// If null, falls back to [ColorScheme.primary].
  final Color? primary;

  /// Text and icon color placed on top of [primary].
  /// If null, falls back to [ColorScheme.onPrimary].
  final Color? onPrimary;

  /// Secondary accent color.
  /// If null, falls back to [ColorScheme.secondary].
  final Color? secondary;

  /// Text and icon color on top of [secondary].
  /// If null, falls back to [ColorScheme.onSecondary].
  final Color? onSecondary;

  /// Base surface color for cards and containers.
  /// If null, falls back to [ColorScheme.surface].
  final Color? surface;

  /// Content color for text and icons on [surface].
  /// If null, falls back to [ColorScheme.onSurface].
  final Color? onSurface;

  /// Subdued container surface for tonal buttons, chips, and fields.
  /// If null, falls back to [ColorScheme.surfaceContainer].
  final Color? surfaceContainer;

  /// Elevated container surface for active pill highlights and popovers.
  /// If null, falls back to [ColorScheme.surfaceContainerHigh].
  final Color? surfaceContainerHigh;

  /// Border and divider color for outlined pills.
  /// If null, falls back to [ColorScheme.outline].
  final Color? outline;

  /// Subtle outline color for faint borders.
  /// If null, falls back to [ColorScheme.outlineVariant].
  final Color? outlineVariant;

  /// Destructive/error color for alert badges, error fields, and warning pills.
  /// If null, falls back to [ColorScheme.error].
  final Color? error;

  /// Text and icon color on top of [error].
  /// If null, falls back to [ColorScheme.onError].
  final Color? onError;

  /// Corner radius for larger pill-styled surfaces like [NixCard].
  final double cardRadius;

  /// Default animation duration for interactive transitions.
  final Duration animationDuration;

  /// Default animation curve for fluid pill transitions.
  final Curve animationCurve;

  /// Whether buttons and interactive surfaces exhibit gentle haptic-like scale compression.
  final bool enablePressFeedback;

  /// Whether buttons morph their pill shape to an expressive squircle on press/hold,
  /// matching Material 3 Expressive standards.
  final bool enableExpressiveShapeMorph;

  /// Duration of the shape morph animation on press/hold.
  /// Defaults to a snappy 90ms.
  final Duration shapeMorphDuration;

  /// Global override for button corner radius when pressed/held.
  /// If null, derives a crisp squircle from button size (e.g. 8.0 for medium).
  final double? buttonPressedRadius;

  /// Global override for button corner radius when hovered/focused.
  /// If null, derives an intermediate expressive squircle (e.g. 15.0 for medium).
  final double? buttonHoveredRadius;

  /// Factory constructor that initializes all values from Flutter's native [ThemeData].
  factory NixThemeData.fromTheme(ThemeData theme) {
    final colors = theme.colorScheme;
    return NixThemeData(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceContainerHigh,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      error: colors.error,
      onError: colors.onError,
    );
  }

  /// Retrieves the nearest [NixThemeData] from the ambient [BuildContext].
  ///
  /// If a [NixThemeData] was registered in [ThemeData.extensions], that is returned.
  /// Otherwise, returns an instance derived directly from [Theme.of(context)].
  static NixThemeData of(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<NixThemeData>();
    if (ext != null) {
      return ext.resolveWithTheme(theme);
    }
    return NixThemeData.fromTheme(theme);
  }

  /// Merges unset values with ambient theme colors.
  NixThemeData resolveWithTheme(ThemeData theme) {
    final colors = theme.colorScheme;
    return NixThemeData(
      primary: primary ?? colors.primary,
      onPrimary: onPrimary ?? colors.onPrimary,
      secondary: secondary ?? colors.secondary,
      onSecondary: onSecondary ?? colors.onSecondary,
      surface: surface ?? colors.surface,
      onSurface: onSurface ?? colors.onSurface,
      surfaceContainer: surfaceContainer ?? colors.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? colors.surfaceContainerHigh,
      outline: outline ?? colors.outline,
      outlineVariant: outlineVariant ?? colors.outlineVariant,
      error: error ?? colors.error,
      onError: onError ?? colors.onError,
      cardRadius: cardRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      enablePressFeedback: enablePressFeedback,
      enableExpressiveShapeMorph: enableExpressiveShapeMorph,
      shapeMorphDuration: shapeMorphDuration,
      buttonPressedRadius: buttonPressedRadius,
      buttonHoveredRadius: buttonHoveredRadius,
    );
  }

  /// Standard stadium border for this theme.
  StadiumBorder get stadiumBorder => NixGeometry.stadiumBorder;

  @override
  NixThemeData copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? onError,
    double? cardRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enablePressFeedback,
    bool? enableExpressiveShapeMorph,
    Duration? shapeMorphDuration,
    double? buttonPressedRadius,
    double? buttonHoveredRadius,
  }) {
    return NixThemeData(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      cardRadius: cardRadius ?? this.cardRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enablePressFeedback: enablePressFeedback ?? this.enablePressFeedback,
      enableExpressiveShapeMorph:
          enableExpressiveShapeMorph ?? this.enableExpressiveShapeMorph,
      shapeMorphDuration: shapeMorphDuration ?? this.shapeMorphDuration,
      buttonPressedRadius: buttonPressedRadius ?? this.buttonPressedRadius,
      buttonHoveredRadius: buttonHoveredRadius ?? this.buttonHoveredRadius,
    );
  }

  @override
  NixThemeData lerp(ThemeExtension<NixThemeData>? other, double t) {
    if (other is! NixThemeData) return this;
    return NixThemeData(
      primary: Color.lerp(primary, other.primary, t),
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t),
      surface: Color.lerp(surface, other.surface, t),
      onSurface: Color.lerp(onSurface, other.onSurface, t),
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t),
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      ),
      outline: Color.lerp(outline, other.outline, t),
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t),
      error: Color.lerp(error, other.error, t),
      onError: Color.lerp(onError, other.onError, t),
      cardRadius: (cardRadius + (other.cardRadius - cardRadius) * t),
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
      enablePressFeedback: t < 0.5
          ? enablePressFeedback
          : other.enablePressFeedback,
      enableExpressiveShapeMorph: t < 0.5
          ? enableExpressiveShapeMorph
          : other.enableExpressiveShapeMorph,
      shapeMorphDuration: t < 0.5
          ? shapeMorphDuration
          : other.shapeMorphDuration,
      buttonPressedRadius: t < 0.5
          ? buttonPressedRadius
          : other.buttonPressedRadius,
      buttonHoveredRadius: t < 0.5
          ? buttonHoveredRadius
          : other.buttonHoveredRadius,
    );
  }
}
