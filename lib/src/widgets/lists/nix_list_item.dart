import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';
import 'nix_list_physics.dart';
import 'nix_music_equalizer.dart';
import 'nix_swipe_action.dart';

/// Communication scope between [NixListView] and its descendant [NixListItem]s.
class NixListScope extends InheritedWidget {
  const NixListScope({
    super.key,
    required this.index,
    required this.totalCount,
    required this.isSelected,
    required this.isSelectable,
    required this.isPlaying,
    required this.prevDetached,
    required this.nextDetached,
    required this.squishTopReach,
    required this.squishBottomReach,
    required this.displacementOffsetY,
    required this.scaleX,
    required this.scaleY,
    required this.swipePullOffsetX,
    required this.swipePullOffsetY,
    required this.swipePullScaleY,
    required this.isDragged,
    required this.isReordering,
    required this.onStartReorder,
    required this.onCancelReorder,
    required this.onSwipeUpdate,
    required this.onSwipeEnd,
    required this.onItemSelect,
    required super.child,
  });

  final int index;
  final int totalCount;
  final bool isSelected;
  final bool isSelectable;
  final bool isPlaying;
  final bool prevDetached;
  final bool nextDetached;
  final double squishTopReach;
  final double squishBottomReach;
  final double displacementOffsetY;
  final double scaleX;
  final double scaleY;
  final double swipePullOffsetX;
  final double swipePullOffsetY;
  final double swipePullScaleY;
  final bool isDragged;
  final bool isReordering;
  final void Function(int index, PointerDownEvent event)? onStartReorder;
  final VoidCallback? onCancelReorder;
  final void Function(int index, double offset)? onSwipeUpdate;
  final void Function(int index)? onSwipeEnd;
  final void Function(int index, bool selected)? onItemSelect;

  static NixListScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NixListScope>();
  }

  @override
  bool updateShouldNotify(NixListScope oldWidget) {
    return index != oldWidget.index ||
        totalCount != oldWidget.totalCount ||
        isSelected != oldWidget.isSelected ||
        isSelectable != oldWidget.isSelectable ||
        isPlaying != oldWidget.isPlaying ||
        prevDetached != oldWidget.prevDetached ||
        nextDetached != oldWidget.nextDetached ||
        squishTopReach != oldWidget.squishTopReach ||
        squishBottomReach != oldWidget.squishBottomReach ||
        displacementOffsetY != oldWidget.displacementOffsetY ||
        scaleX != oldWidget.scaleX ||
        scaleY != oldWidget.scaleY ||
        swipePullOffsetX != oldWidget.swipePullOffsetX ||
        swipePullOffsetY != oldWidget.swipePullOffsetY ||
        swipePullScaleY != oldWidget.swipePullScaleY ||
        isDragged != oldWidget.isDragged ||
        isReordering != oldWidget.isReordering;
  }
}

/// An ergonomic reorder handle widget for [NixListItem].
///
/// Place this in [NixListItem.trailing] or [NixListItem.leading] to allow
/// immediate drag-to-reorder on pointer down.
class NixReorderHandle extends StatelessWidget {
  /// Creates a [NixReorderHandle].
  const NixReorderHandle({
    super.key,
    this.icon = const Icon(Icons.drag_handle_rounded),
    this.padding = const EdgeInsets.all(8.0),
  });

  /// The handle icon widget. Defaults to [Icons.drag_handle_rounded].
  final Widget icon;

  /// Touch padding around the handle.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scope = NixListScope.of(context);
    final theme = Theme.of(context);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (scope?.onStartReorder != null) {
          scope!.onStartReorder!(scope.index, event);
        }
      },
      child: Padding(
        padding: padding,
        child: IconTheme(
          data: IconThemeData(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 20.0,
          ),
          child: icon,
        ),
      ),
    );
  }
}

/// A premium, interactive list item designed for [NixListView].
///
/// Features:
/// - **Dynamic Segmented Corner Radii**: Seamlessly fits into 16px container
///   with 12px outer corners, 6px inner/neighbor corners, and dynamically morphs
///   into an isolated 14px card when selected, active, or playing.
/// - **Neighbour Squish Physics**: Responds organically to drag proximity
///   with spring-driven displacement and volume-preserving squash & stretch.
/// - **Independent Left/Right Dismiss**: Supports different actions, colors,
///   icons, and thresholds for left and right swipes.
/// - **Multi-Select & Active/Playing States**: Supports batch selection mode
///   and music player track states with built-in [NixMusicEqualizer].
class NixListItem extends StatefulWidget {
  /// Creates a [NixListItem].
  const NixListItem({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.isSelected = false,
    this.isSelectable = false,
    this.onSelectionChanged,
    this.isPlaying = false,
    this.isActive = false,
    this.leftAction,
    this.rightAction,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.activeBackgroundColor,
    this.borderRadius,
    this.selectedBorderRadius,
    this.activeBorderRadius,
    this.border,
    this.selectedBorder,
    this.activeBorder,
    this.elevation,
    this.selectedElevation,
    this.activeElevation,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.contentPadding,
    this.child,
    this.reorderHandle,
    this.customEqualizer,
    this.showEqualizerWhenPlaying = true,
    this.showSelectionIndicator = true,
  });

  /// Widget placed at the start of the item (e.g. icon, avatar, checkbox).
  final Widget? leading;

  /// Primary text or widget.
  final Widget? title;

  /// Secondary descriptive text or widget.
  final Widget? subtitle;

  /// Widget placed at the end of the item (e.g. trailing action, chevron, duration).
  final Widget? trailing;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Called when the item is pressed and held.
  final VoidCallback? onLongPress;

  /// Whether the item is interactive.
  final bool enabled;

  /// Whether this item is currently selected in a selection mode.
  final bool isSelected;

  /// Whether selection mode is enabled for this item.
  final bool isSelectable;

  /// Called when the selection state is toggled.
  final ValueChanged<bool>? onSelectionChanged;

  /// Whether this item represents an active playing track or media item.
  final bool isPlaying;

  /// Alias for active highlight state.
  final bool isActive;

  /// Independent action triggered by swiping right (from left edge).
  final NixSwipeAction? leftAction;

  /// Independent action triggered by swiping left (from right edge).
  final NixSwipeAction? rightAction;

  /// Normal background color. Defaults to [ColorScheme.surfaceContainerLow].
  final Color? backgroundColor;

  /// Background color when [isSelected] is true.
  final Color? selectedBackgroundColor;

  /// Background color when [isPlaying] or [isActive] is true.
  final Color? activeBackgroundColor;

  /// Custom corner radius. If null, automatically computes dynamic segmented radius.
  final BorderRadius? borderRadius;

  /// Custom corner radius when [isSelected] is true.
  final BorderRadius? selectedBorderRadius;

  /// Custom corner radius when [isPlaying] or [isActive] is true.
  final BorderRadius? activeBorderRadius;

  /// Normal border side/decoration.
  final BoxBorder? border;

  /// Border side when [isSelected] is true.
  final BoxBorder? selectedBorder;

  /// Border side when [isPlaying] or [isActive] is true.
  final BoxBorder? activeBorder;

  /// Normal elevation. Defaults to 0.0.
  final double? elevation;

  /// Elevation when [isSelected] is true.
  final double? selectedElevation;

  /// Elevation when [isPlaying] or [isActive] is true.
  final double? activeElevation;

  /// Inner padding around the item content.
  final EdgeInsetsGeometry padding;

  /// Inner padding around the main horizontal content row.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom full-width child. If provided, replaces standard leading/title/subtitle/trailing.
  final Widget? child;

  /// Optional reorder handle widget (e.g. [NixReorderHandle]).
  final Widget? reorderHandle;

  /// Custom equalizer widget for playing state. Defaults to [NixMusicEqualizer].
  final Widget? customEqualizer;

  /// Whether to automatically show the equalizer indicator when [isPlaying] is true.
  final bool showEqualizerWhenPlaying;

  /// Whether to render a selection indicator when [isSelectable] is true.
  final bool showSelectionIndicator;

  @override
  State<NixListItem> createState() => _NixListItemState();
}

class _NixListItemState extends State<NixListItem>
    with TickerProviderStateMixin {
  double _swipeOffset = 0.0;
  bool _thresholdTriggered = false;
  bool _isDismissed = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late final AnimationController _collapseController;
  late Animation<double> _collapseAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _resetAnimation = const AlwaysStoppedAnimation(0.0);

    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant NixListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If widget was reused in the element tree, reset dismissed/collapsed state
    if (_isDismissed && !_collapseController.isAnimating) {
      _isDismissed = false;
      _collapseController.reset();
      _swipeOffset = 0.0;
      _thresholdTriggered = false;
    }
  }

  @override
  void dispose() {
    _resetController.dispose();
    _collapseController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled || _isDismissed) return;
    final scope = NixListScope.of(context);
    if (scope?.isReordering == true || scope?.isDragged == true) return;
    // Explicitly cancel any pending long-press reorder so horizontal swipe is isolated
    scope?.onCancelReorder?.call();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double itemWidth) {
    if (!widget.enabled || _isDismissed) return;
    final scope = NixListScope.of(context);
    if (scope?.isReordering == true || scope?.isDragged == true) return;
    scope?.onCancelReorder?.call();

    final dx = details.primaryDelta ?? 0.0;
    // Damped resistance if no action in that direction
    if (dx > 0 && widget.leftAction == null && _swipeOffset >= 0) return;
    if (dx < 0 && widget.rightAction == null && _swipeOffset <= 0) return;

    setState(() {
      _swipeOffset += dx;
      final currentAction = _swipeOffset > 0 ? widget.leftAction : widget.rightAction;
      if (currentAction != null) {
        final thresholdPx = itemWidth * currentAction.threshold;
        final crossed = _swipeOffset.abs() >= thresholdPx;
        if (crossed && !_thresholdTriggered) {
          _thresholdTriggered = true;
          if (currentAction.hapticFeedback) {
            HapticFeedback.selectionClick();
          }
        } else if (!crossed && _thresholdTriggered) {
          _thresholdTriggered = false;
        }
      }
    });

    scope?.onSwipeUpdate?.call(scope.index, _swipeOffset);
  }

  Future<void> _onHorizontalDragEnd(
    DragEndDetails details,
    double itemWidth,
  ) async {
    if (!widget.enabled || _isDismissed) return;

    final scope = NixListScope.of(context);
    scope?.onSwipeEnd?.call(scope.index);

    final action = _swipeOffset > 0 ? widget.leftAction : widget.rightAction;
    final thresholdPx = itemWidth * (action?.threshold ?? 0.35);

    if (action != null && _swipeOffset.abs() >= thresholdPx) {
      if (action.actionType == NixSwipeActionType.dismiss) {
        bool canDismiss = true;
        if (action.confirmDismiss != null) {
          canDismiss = await action.confirmDismiss!();
        }
        if (!mounted) return;

        if (canDismiss) {
          await _slideOutAndDismiss(itemWidth, action);
          return;
        }
      } else {
        // Trigger action without dismissing
        action.onTriggered();
      }
    }

    // Spring back to center
    _resetSpringBack();
  }

  Future<void> _slideOutAndDismiss(
    double itemWidth,
    NixSwipeAction action,
  ) async {
    setState(() => _isDismissed = true);
    final scope = NixListScope.of(context);
    scope?.onSwipeEnd?.call(scope.index);

    // Smoothly glide completely off-screen
    final targetOffset =
        _swipeOffset > 0 ? itemWidth * 1.15 : -itemWidth * 1.15;
    _resetAnimation = Tween<double>(
      begin: _swipeOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    ));
    await _resetController.forward(from: 0.0);
    if (!mounted) return;

    // Smoothly collapse height
    await _collapseController.forward(from: 0.0);
    if (!mounted) return;

    action.onTriggered();
  }

  void _resetSpringBack() {
    _thresholdTriggered = false;
    _resetAnimation = Tween<double>(
      begin: _swipeOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: const NixSpringCurve(),
    ));

    _resetController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _swipeOffset = 0.0;
        });
      }
    });
  }

  void _handleTap() {
    if (!widget.enabled) return;
    final scope = NixListScope.of(context);
    final canSelect = widget.isSelectable || (scope?.isSelectable ?? false);
    if (canSelect) {
      final nextState = !(widget.isSelected || (scope?.isSelected ?? false));
      widget.onSelectionChanged?.call(nextState);
      scope?.onItemSelect?.call(scope.index, nextState);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed && _collapseController.isCompleted) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;
    final scope = NixListScope.of(context);

    final isEffectivePlaying = widget.isPlaying || widget.isActive || (scope?.isPlaying ?? false);
    final isEffectiveSelected = widget.isSelected || (scope?.isSelected ?? false);
    final isEffectiveSelectable = widget.isSelectable || (scope?.isSelectable ?? false);

    // Compute dynamic segmented corner radius
    final computedRadius = widget.borderRadius ??
        (isEffectiveSelected
            ? (widget.selectedBorderRadius ??
                const BorderRadius.all(
                  Radius.circular(NixListPhysics.detachedItemRadius),
                ))
            : isEffectivePlaying
                ? (widget.activeBorderRadius ??
                    const BorderRadius.all(
                      Radius.circular(NixListPhysics.detachedItemRadius),
                    ))
                : NixListPhysics.computeSegmentedRadius(
                    index: scope?.index ?? 0,
                    totalCount: scope?.totalCount ?? 1,
                    isSelected: isEffectiveSelected,
                    isPlaying: isEffectivePlaying,
                    isDragged: scope?.isDragged ?? false,
                    prevDetached: scope?.prevDetached ?? false,
                    nextDetached: scope?.nextDetached ?? false,
                    squishTopReach: scope?.squishTopReach ?? 0.0,
                    squishBottomReach: scope?.squishBottomReach ?? 0.0,
                  ));

    // Dynamic background colors
    Color effectiveBgColor;
    if (isEffectiveSelected) {
      effectiveBgColor = widget.selectedBackgroundColor ??
          (nixTheme.primary ?? colors.primary).withValues(alpha: 0.14);
    } else if (isEffectivePlaying) {
      effectiveBgColor = widget.activeBackgroundColor ??
          (nixTheme.primary ?? colors.primary).withValues(alpha: 0.10);
    } else {
      effectiveBgColor = widget.backgroundColor ?? colors.surfaceContainerLow;
    }

    // Dynamic border
    BoxBorder? effectiveBorder;
    if (isEffectiveSelected) {
      effectiveBorder = widget.selectedBorder ??
          Border.all(
            color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.5),
            width: 1.5,
          );
    } else if (isEffectivePlaying) {
      effectiveBorder = widget.activeBorder ??
          Border.all(
            color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.35),
            width: 1.2,
          );
    } else {
      effectiveBorder = widget.border;
    }

    // Elevation & shadow
    final effectiveElevation = isEffectiveSelected
        ? (widget.selectedElevation ?? 0.0)
        : isEffectivePlaying
            ? (widget.activeElevation ?? 0.0)
            : (widget.elevation ?? 0.0);

    // Squish physics transforms from scope
    final dispY = scope?.displacementOffsetY ?? 0.0;
    final scaleX = scope?.scaleX ?? 1.0;
    final scaleY = scope?.scaleY ?? 1.0;
    final swipePullX = scope?.swipePullOffsetX ?? 0.0;
    final swipePullY = scope?.swipePullOffsetY ?? 0.0;
    final swipePullScaleY = scope?.swipePullScaleY ?? 1.0;

    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(_collapseAnimation),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth;
          final currentOffset =
              _resetController.isAnimating ? _resetAnimation.value : _swipeOffset;

          Widget content = widget.child ??
              Row(
                children: [
                  if (isEffectiveSelectable && widget.showSelectionIndicator) ...[
                    _buildSelectionIndicator(colors, isEffectiveSelected),
                    const SizedBox(width: 12),
                  ],
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null)
                          DefaultTextStyle(
                            style: (theme.textTheme.bodyLarge ??
                                    const TextStyle(fontSize: 16))
                                .copyWith(
                              fontWeight: isEffectivePlaying || isEffectiveSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isEffectivePlaying
                                  ? (nixTheme.primary ?? colors.primary)
                                  : (widget.enabled
                                      ? colors.onSurface
                                      : colors.onSurface.withValues(alpha: 0.4)),
                            ),
                            child: widget.title!,
                          ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: (theme.textTheme.bodyMedium ??
                                    const TextStyle(fontSize: 13))
                                .copyWith(
                              color: widget.enabled
                                  ? colors.onSurfaceVariant
                                  : colors.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                            ),
                            child: widget.subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isEffectivePlaying && widget.showEqualizerWhenPlaying) ...[
                    const SizedBox(width: 8),
                    widget.customEqualizer ??
                        NixMusicEqualizer(
                          isPlaying: true,
                          color: nixTheme.primary ?? colors.primary,
                        ),
                  ],
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                  if (widget.reorderHandle != null) ...[
                    const SizedBox(width: 4),
                    widget.reorderHandle!,
                  ],
                ],
              );

          // Card surface
          final cardSurface = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: widget.contentPadding ?? widget.padding,
            decoration: BoxDecoration(
              color: effectiveBgColor,
              borderRadius: computedRadius,
              border: effectiveBorder,
              boxShadow: effectiveElevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: effectiveElevation * 2,
                        offset: Offset(0, effectiveElevation),
                      ),
                    ]
                  : null,
            ),
            child: content,
          );

          // Wrap in gesture detector for tap, long press, and swipe actions
          Widget itemWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            onLongPress: widget.onLongPress,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (details) =>
                _onHorizontalDragUpdate(details, itemWidth),
            onHorizontalDragEnd: (details) =>
                _onHorizontalDragEnd(details, itemWidth),
            child: cardSurface,
          );

          // If swipe actions exist, stack behind
          if (widget.leftAction != null || widget.rightAction != null) {
            itemWidget = Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: computedRadius,
                    child: _buildSwipeBackground(
                      colors: colors,
                      offset: currentOffset,
                      itemWidth: itemWidth,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(currentOffset, 0),
                  child: itemWidget,
                ),
              ],
            );
          }

          // Apply Neighbour Squish Physics & Displacement Transforms
          final totalScaleX = scaleX;
          final totalScaleY = scaleY * swipePullScaleY;
          final totalTransX = swipePullX;
          final totalTransY = dispY + swipePullY;

          return Transform.translate(
            offset: Offset(totalTransX, totalTransY),
            child: Transform.scale(
              scaleX: totalScaleX,
              scaleY: totalScaleY,
              alignment: Alignment.center,
              child: itemWidget,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionIndicator(ColorScheme colors, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? colors.primary
              : colors.onSurfaceVariant.withValues(alpha: 0.4),
          width: 2.0,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: 14.0,
              color: colors.onPrimary,
            )
          : null,
    );
  }

  Widget _buildSwipeBackground({
    required ColorScheme colors,
    required double offset,
    required double itemWidth,
  }) {
    if (offset > 0 && widget.leftAction != null) {
      final action = widget.leftAction!;
      final progress = (offset / (itemWidth * action.threshold)).clamp(0.0, 1.5);
      if (action.builder != null) {
        return action.builder!(context, progress);
      }

      final bgColor = action.backgroundColor ??
          (action.actionType == NixSwipeActionType.dismiss
              ? colors.error
              : colors.primary);
      final fgColor = action.foregroundColor ??
          (action.actionType == NixSwipeActionType.dismiss
              ? colors.onError
              : colors.onPrimary);

      return Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.centerLeft,
        child: Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.7 + (progress.clamp(0.0, 1.0) * 0.3)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (action.icon != null)
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: 22.0),
                    child: action.icon!,
                  ),
                if (action.label != null) ...[
                  const SizedBox(width: 8),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    child: action.label!,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } else if (offset < 0 && widget.rightAction != null) {
      final action = widget.rightAction!;
      final progress =
          (offset.abs() / (itemWidth * action.threshold)).clamp(0.0, 1.5);
      if (action.builder != null) {
        return action.builder!(context, progress);
      }

      final bgColor = action.backgroundColor ??
          (action.actionType == NixSwipeActionType.dismiss
              ? colors.error
              : colors.secondary);
      final fgColor = action.foregroundColor ??
          (action.actionType == NixSwipeActionType.dismiss
              ? colors.onError
              : colors.onSecondary);

      return Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.centerRight,
        child: Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.7 + (progress.clamp(0.0, 1.0) * 0.3)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (action.label != null) ...[
                  DefaultTextStyle(
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    child: action.label!,
                  ),
                  const SizedBox(width: 8),
                ],
                if (action.icon != null)
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: 22.0),
                    child: action.icon!,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
