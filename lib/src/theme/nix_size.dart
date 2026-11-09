import 'package:flutter/widgets.dart';

/// Defines standardized sizing tiers across all Nix widgets.
///
/// Follows Flutter's native enum naming and ergonomics.
enum NixSize {
  /// Compact size suitable for dense tables, toolbars, and small spaces.
  small,

  /// Standard default size suitable for primary mobile and desktop UIs.
  medium,

  /// Prominent size for hero actions, touch targets, and onboarding flows.
  large,
}

/// Helpful sizing metrics associated with each [NixSize].
extension NixSizeMetrics on NixSize {
  /// Default height for buttons, inputs, and chips.
  double get height {
    switch (this) {
      case NixSize.small:
        return 32.0;
      case NixSize.medium:
        return 44.0;
      case NixSize.large:
        return 54.0;
    }
  }

  /// Default icon size corresponding to the size tier.
  double get iconSize {
    switch (this) {
      case NixSize.small:
        return 16.0;
      case NixSize.medium:
        return 20.0;
      case NixSize.large:
        return 24.0;
    }
  }

  /// Default horizontal padding inside pill containers.
  EdgeInsetsGeometry get horizontalPadding {
    switch (this) {
      case NixSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case NixSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20.0);
      case NixSize.large:
        return const EdgeInsets.symmetric(horizontal: 28.0);
    }
  }

  /// Default font size for text inside the pill.
  double get fontSize {
    switch (this) {
      case NixSize.small:
        return 12.0;
      case NixSize.medium:
        return 14.0;
      case NixSize.large:
        return 16.0;
    }
  }

  /// Spacing between icon and label inside widgets.
  double get iconSpacing {
    switch (this) {
      case NixSize.small:
        return 6.0;
      case NixSize.medium:
        return 8.0;
      case NixSize.large:
        return 10.0;
    }
  }
}
