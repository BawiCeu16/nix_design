import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';
import '../inputs/nix_switch.dart';
import 'nix_list_item.dart';
import 'nix_list_physics.dart';

/// Position of the [NixSwitch] relative to title and content inside [NixSwitchTile].
enum NixTileControlAffinity {
  /// Place the switch at the trailing edge of the tile (default).
  trailing,

  /// Place the switch at the leading edge of the tile.
  leading,
}

/// Explicit position of a tile within a group for segmented corner radius calculation.
enum NixTilePosition {
  /// Standalone isolated tile with rounded corners on all sides (12px).
  single,

  /// First item in a group (top corners 12px, bottom corners 6px).
  first,

  /// Middle item in a group between other tiles (all corners 6px).
  middle,

  /// Last item in a group (top corners 6px, bottom corners 12px).
  last,
}

/// Inherited scope providing index and count context to descendant [NixSwitchTile]s
/// when arranged inside a [NixSwitchList].
class NixSwitchScope extends InheritedWidget {
  const NixSwitchScope({
    super.key,
    required this.index,
    required this.totalCount,
    required super.child,
  });

  /// The zero-based index of this tile in the enclosing list.
  final int index;

  /// The total number of items in the enclosing list.
  final int totalCount;

  /// Retrieves the nearest [NixSwitchScope] from the given build context, if any.
  static NixSwitchScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NixSwitchScope>();
  }

  @override
  bool updateShouldNotify(NixSwitchScope oldWidget) {
    return index != oldWidget.index || totalCount != oldWidget.totalCount;
  }
}

/// A premium, segmented switch tile designed for the Nix Design System.
///
/// Shares the exact segmented corner radii, container styling, and native Flutter
/// InkWell splash ergonomics of [NixListItem], without reordering, swipe gestures,
/// or selection/playback states.
///
/// Features:
/// - **Segmented Corner Radii**: Automatically computes 12px outer and 6px neighbor
///   radii when placed inside [NixSwitchList] or [NixListView], or 12px on all corners
///   when standalone.
/// - **Full-Surface Tap Target**: Tapping anywhere on the tile or directly on the
///   switch smoothly toggles the switch value and triggers a native ink ripple.
/// - **Configurable Control Affinity**: Position the switch at either the [NixTileControlAffinity.trailing]
///   (default) or [NixTileControlAffinity.leading] edge.
/// - **Theme Integration**: Automatically inherits background, surface, text, and active
///   colors from the enclosing [ThemeData] and [NixThemeData].
class NixSwitchTile extends StatelessWidget {
  /// Creates a standard [NixSwitchTile].
  const NixSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.controlAffinity = NixTileControlAffinity.trailing,
    this.tilePosition,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.border,
    this.activeBorder,
    this.borderRadius,
    this.elevation,
    this.activeElevation,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.materialTapTargetSize,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.contentPadding,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.switchKey,
    this.child,
  });

  /// Whether this switch is currently turned on.
  final bool value;

  /// Called when the user toggles the switch by tapping the tile or the switch itself.
  /// If null, the switch tile is rendered in a disabled state.
  final ValueChanged<bool>? onChanged;

  /// Primary content of the switch tile, typically a [Text] widget.
  final Widget? title;

  /// Additional content displayed underneath the [title], typically a smaller [Text] widget.
  final Widget? subtitle;

  /// A widget displayed before the title (e.g. an [Icon] or avatar).
  final Widget? leading;

  /// A widget displayed after the title/content. If [controlAffinity] is [NixTileControlAffinity.trailing],
  /// this is placed just before the switch. If [controlAffinity] is [NixTileControlAffinity.leading],
  /// this occupies the trailing edge.
  final Widget? trailing;

  /// Whether the tile is interactive. When false, taps are ignored and text/icons
  /// are rendered with disabled opacity.
  final bool enabled;

  /// Optional extra callback invoked when the tile is tapped, in addition to [onChanged].
  final VoidCallback? onTap;

  /// Optional callback invoked when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Where to position the switch relative to the tile's content.
  /// Defaults to [NixTileControlAffinity.trailing].
  final NixTileControlAffinity controlAffinity;

  /// Optional explicit tile position for segmented corner radius computation.
  /// If null, automatically resolves from the nearest [NixSwitchScope] or [NixListScope].
  final NixTilePosition? tilePosition;

  /// Custom background color for the tile surface. Defaults to [ColorScheme.surfaceContainerLow].
  final Color? backgroundColor;

  /// Optional background color tint when [value] is true.
  final Color? activeBackgroundColor;

  /// Custom border for the tile.
  final BoxBorder? border;

  /// Custom border when [value] is true.
  final BoxBorder? activeBorder;

  /// Custom border radius override for all corners. If provided, disables automatic
  /// segmented corner calculation.
  final BorderRadius? borderRadius;

  /// Elevation / shadow distance for the tile card. Defaults to 0.0.
  final double? elevation;

  /// Elevation / shadow distance when [value] is true.
  final double? activeElevation;

  /// Custom active thumb color passed to the embedded [NixSwitch].
  final Color? activeColor;

  /// Custom inactive thumb color passed to the embedded [NixSwitch].
  final Color? inactiveColor;

  /// Custom active track color passed to the embedded [NixSwitch].
  final Color? activeTrackColor;

  /// Custom inactive track color passed to the embedded [NixSwitch].
  final Color? inactiveTrackColor;

  /// Static thumb color override passed to the embedded [NixSwitch].
  final Color? thumbColor;

  /// Configures the tap target size of the embedded switch.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Padding around the tile's inner content. Defaults to `horizontal: 16.0, vertical: 12.0`.
  final EdgeInsetsGeometry padding;

  /// Optional override for [padding].
  final EdgeInsetsGeometry? contentPadding;

  /// Ink splash ripple color on tap.
  final Color? splashColor;

  /// Ink highlight color on press and hold.
  final Color? highlightColor;

  /// Ink hover color when mouse cursor hovers over the tile.
  final Color? hoverColor;

  /// Optional Key passed directly to the internal [NixSwitch] widget.
  final Key? switchKey;

  /// Optional arbitrary widget that completely overrides the default row content.
  final Widget? child;

  bool get isInteractive => enabled && onChanged != null;

  void _handleTap() {
    if (!isInteractive) return;
    onChanged!(!value);
    onTap?.call();
    HapticFeedback.lightImpact();
  }

  BorderRadius _computeRadius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;

    if (tilePosition != null) {
      switch (tilePosition!) {
        case NixTilePosition.single:
          return NixGeometry.pillBorderRadius;
        case NixTilePosition.first:
          return const BorderRadius.only(
            topLeft: Radius.circular(NixListPhysics.outerItemRadius),
            topRight: Radius.circular(NixListPhysics.outerItemRadius),
            bottomLeft: Radius.circular(NixListPhysics.innerItemRadius),
            bottomRight: Radius.circular(NixListPhysics.innerItemRadius),
          );
        case NixTilePosition.middle:
          return const BorderRadius.all(
            Radius.circular(NixListPhysics.innerItemRadius),
          );
        case NixTilePosition.last:
          return const BorderRadius.only(
            topLeft: Radius.circular(NixListPhysics.innerItemRadius),
            topRight: Radius.circular(NixListPhysics.innerItemRadius),
            bottomLeft: Radius.circular(NixListPhysics.outerItemRadius),
            bottomRight: Radius.circular(NixListPhysics.outerItemRadius),
          );
      }
    }

    final switchScope = NixSwitchScope.of(context);
    final listScope = NixListScope.of(context);

    final int index = switchScope?.index ?? listScope?.index ?? 0;
    final int totalCount = switchScope?.totalCount ?? listScope?.totalCount ?? 1;

    if (totalCount <= 1) {
      return NixGeometry.pillBorderRadius;
    }
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(NixListPhysics.outerItemRadius),
        topRight: Radius.circular(NixListPhysics.outerItemRadius),
        bottomLeft: Radius.circular(NixListPhysics.innerItemRadius),
        bottomRight: Radius.circular(NixListPhysics.innerItemRadius),
      );
    }
    if (index == totalCount - 1) {
      return const BorderRadius.only(
        topLeft: Radius.circular(NixListPhysics.innerItemRadius),
        topRight: Radius.circular(NixListPhysics.innerItemRadius),
        bottomLeft: Radius.circular(NixListPhysics.outerItemRadius),
        bottomRight: Radius.circular(NixListPhysics.outerItemRadius),
      );
    }
    return const BorderRadius.all(
      Radius.circular(NixListPhysics.innerItemRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final computedRadius = _computeRadius(context);

    // Dynamic background color
    final baseBg = backgroundColor ?? colors.surfaceContainerLow;
    Color effectiveBgColor;
    if (value && activeBackgroundColor != null) {
      effectiveBgColor = activeBackgroundColor!;
    } else {
      effectiveBgColor = baseBg;
    }

    if (effectiveBgColor.a < 1.0) {
      effectiveBgColor = Color.alphaBlend(effectiveBgColor, colors.surface);
    }
    if (effectiveBgColor.a < 1.0) {
      effectiveBgColor = effectiveBgColor.withValues(alpha: 1.0);
    }

    // Dynamic border
    final effectiveBorder = (value ? activeBorder : null) ?? border;

    // Elevation & shadow
    final effectiveElevation = (value ? activeElevation : null) ?? elevation ?? 0.0;
    final List<BoxShadow>? effectiveShadow = effectiveElevation > 0
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: effectiveElevation * 2.5,
              offset: Offset(0, effectiveElevation),
            ),
          ]
        : null;

    final switchWidget = NixSwitch(
      key: switchKey,
      value: value,
      onChanged: isInteractive ? (val) => _handleTap() : null,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      materialTapTargetSize: materialTapTargetSize,
    );

    Widget defaultRow = Row(
      children: [
        if (controlAffinity == NixTileControlAffinity.leading) ...[
          switchWidget,
          const SizedBox(width: 14),
        ],
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(
              color: isInteractive
                  ? (value ? (nixTheme.primary ?? colors.primary) : colors.onSurfaceVariant)
                  : colors.onSurfaceVariant.withValues(alpha: 0.38),
              size: 24.0,
            ),
            child: leading!,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: (theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16))
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: isInteractive
                            ? colors.onSurface
                            : colors.onSurface.withValues(alpha: 0.38),
                      ),
                  child: title!,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 13))
                      .copyWith(
                        color: isInteractive
                            ? colors.onSurfaceVariant
                            : colors.onSurfaceVariant.withValues(alpha: 0.38),
                      ),
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
        if (controlAffinity == NixTileControlAffinity.trailing) ...[
          const SizedBox(width: 12),
          switchWidget,
        ],
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: computedRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: computedRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: computedRadius,
          splashColor: splashColor,
          highlightColor: highlightColor,
          hoverColor: hoverColor,
          onTap: isInteractive ? _handleTap : null,
          onLongPress: isInteractive ? onLongPress : null,
          child: Padding(
            padding: contentPadding ?? padding,
            child: child ?? defaultRow,
          ),
        ),
      ),
    );
  }
}

/// A segmented list container designed specifically for [NixSwitchTile]s.
///
/// Encapsulates switch tiles within a 16px stadium/capsule container with 4px padding
/// and 2px spacing, dynamically computing segmented corner radii for its tiles:
/// - Single tile: pilled / capsule radius ([NixGeometry.pillBorderRadius])
/// - First tile: 12px top corners, 6px bottom corners
/// - Middle tiles: 6px on all corners
/// - Last tile: 6px top corners, 12px bottom corners
///
/// Supports explicit [children] or lazy construction via [NixSwitchList.builder].
class NixSwitchList extends StatelessWidget {
  /// Creates a standard [NixSwitchList] with explicit [children].
  const NixSwitchList({
    super.key,
    required List<Widget> this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.enableContainer = true,
    this.containerColor,
    this.containerBorderRadius,
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.itemSpacing = 2.0,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = true,
    this.physics,
    this.controller,
  })  : itemCount = null,
        itemBuilder = null;

  /// Creates a lazily-constructed [NixSwitchList] using an [itemBuilder].
  const NixSwitchList.builder({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    this.padding = const EdgeInsets.all(16.0),
    this.enableContainer = true,
    this.containerColor,
    this.containerBorderRadius,
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.itemSpacing = 2.0,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = true,
    this.physics,
    this.controller,
  })  : children = null;

  /// The list of widgets (typically [NixSwitchTile]s) to display.
  final List<Widget>? children;

  /// The total number of items when using [NixSwitchList.builder].
  final int? itemCount;

  /// Builder callback for lazily constructing items.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Padding around the switch list container.
  final EdgeInsetsGeometry padding;

  /// Whether to encapsulate tiles within the signature Nix 16px container. Defaults to `true`.
  final bool enableContainer;

  /// Custom container background color. Defaults to [ColorScheme.surfaceContainer].
  final Color? containerColor;

  /// Border radius of the outer container. Defaults to [NixGeometry.pillBorderRadius]
  /// when single item, or `16.0px` on all corners for multi-item lists.
  final BorderRadius? containerBorderRadius;

  /// Optional border around the outer container.
  final BoxBorder? containerBorder;

  /// Padding inside the container around all tiles. Defaults to `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry containerPadding;

  /// Vertical spacing between adjacent tiles. Defaults to `2.0px`.
  final double itemSpacing;

  /// Scroll direction of the list. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the list should shrink-wrap its contents. Defaults to `true`.
  final bool shrinkWrap;

  /// Optional physics for scrollable behavior.
  final ScrollPhysics? physics;

  /// Optional controller for scrollable behavior.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final effectiveContainerColor =
        containerColor ?? colors.surfaceContainer;

    final int total = children?.length ?? itemCount ?? 0;

    Widget buildTile(int index) {
      final Widget tile = children != null
          ? children![index]
          : itemBuilder!(context, index);

      return NixSwitchScope(
        index: index,
        totalCount: total,
        child: tile,
      );
    }

    Widget content;
    if (shrinkWrap && physics == null && controller == null) {
      // Clean, unconstrained column layout when embedded inside other scroll views:
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < total; i++) ...[
            buildTile(i),
            if (i < total - 1 && itemSpacing > 0) SizedBox(height: itemSpacing),
          ],
        ],
      );
    } else {
      content = ListView.separated(
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        scrollDirection: scrollDirection,
        itemCount: total,
        separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
        itemBuilder: (context, index) => buildTile(index),
      );
    }

    Widget result;
    if (enableContainer) {
      final BorderRadius effectiveContainerRadius = containerBorderRadius ??
          (total <= 1
              ? NixGeometry.pillBorderRadius
              : const BorderRadius.all(
                  Radius.circular(NixListPhysics.containerRadius),
                ));

      result = DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveContainerColor,
          borderRadius: effectiveContainerRadius,
          border: containerBorder,
        ),
        child: Padding(
          padding: containerPadding,
          child: content,
        ),
      );
    } else {
      result = content;
    }

    if (padding != EdgeInsets.zero) {
      result = Padding(padding: padding, child: result);
    }

    return result;
  }
}

