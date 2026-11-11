import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';
import 'nix_list_physics.dart';
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
    this.prevSameState = false,
    this.nextSameState = false,
    this.squishTopReach = 0.0,
    this.squishBottomReach = 0.0,
    this.displacementOffsetY = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.swipePullOffsetX = 0.0,
    this.swipePullOffsetY = 0.0,
    this.swipePullScaleY = 1.0,
    required this.isDragged,
    required this.isReordering,
    this.startItemDragReorder,
    this.onStartReorder,
    this.onStartDelayedReorder,
    required this.onCancelReorder,
    this.onSwipeUpdate,
    this.onSwipeEnd,
    this.onItemSelect,
    this.onActionOpenChanged,
    this.swipeMode = NixSwipeMode.dismiss,
    this.swipeDirection = NixSwipeDirection.both,
    this.buildDefaultDragHandles = false,
    this.canReorderHandle = false,
    required super.child,
  });

  final int index;
  final int totalCount;
  final bool isSelected;
  final bool isSelectable;
  final bool isPlaying;
  final bool prevDetached;
  final bool nextDetached;
  final bool prevSameState;
  final bool nextSameState;
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
  final void Function({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  })?
  startItemDragReorder;
  final void Function(int index, PointerDownEvent event)? onStartReorder;
  final void Function(int index, PointerDownEvent event)? onStartDelayedReorder;
  final VoidCallback? onCancelReorder;
  final void Function(int index, double offset)? onSwipeUpdate;
  final void Function(int index)? onSwipeEnd;
  final void Function(int index, bool selected)? onItemSelect;
  final void Function(int index, bool isOpen)? onActionOpenChanged;
  final NixSwipeMode swipeMode;
  final NixSwipeDirection swipeDirection;
  final bool buildDefaultDragHandles;
  final bool canReorderHandle;

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
        prevSameState != oldWidget.prevSameState ||
        nextSameState != oldWidget.nextSameState ||
        squishTopReach != oldWidget.squishTopReach ||
        squishBottomReach != oldWidget.squishBottomReach ||
        displacementOffsetY != oldWidget.displacementOffsetY ||
        scaleX != oldWidget.scaleX ||
        scaleY != oldWidget.scaleY ||
        swipePullOffsetX != oldWidget.swipePullOffsetX ||
        swipePullOffsetY != oldWidget.swipePullOffsetY ||
        swipePullScaleY != oldWidget.swipePullScaleY ||
        isDragged != oldWidget.isDragged ||
        isReordering != oldWidget.isReordering ||
        swipeMode != oldWidget.swipeMode ||
        swipeDirection != oldWidget.swipeDirection ||
        buildDefaultDragHandles != oldWidget.buildDefaultDragHandles ||
        canReorderHandle != oldWidget.canReorderHandle ||
        onActionOpenChanged != oldWidget.onActionOpenChanged;
  }
}

/// Internal communication between [NixListItem] and its child [NixReorderDragListener]s.
class _NixItemInternalScope extends InheritedWidget {
  const _NixItemInternalScope({
    required this.onHandlePointerDown,
    required this.onHandlePointerUp,
    required super.child,
  });

  final VoidCallback onHandlePointerDown;
  final VoidCallback onHandlePointerUp;

  static _NixItemInternalScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NixItemInternalScope>();
  }

  @override
  bool updateShouldNotify(_NixItemInternalScope oldWidget) => false;
}

/// An immediate drag listener widget modeled after Flutter's native [ReorderableDragStartListener].
///
/// Wrap any custom icon or widget with this to allow immediate drag-to-reorder on pointer down.
class NixReorderDragListener extends StatelessWidget {
  /// Creates a [NixReorderDragListener].
  const NixReorderDragListener({
    super.key,
    required this.child,
    this.index,
    this.enabled = true,
  });

  /// The widget for which dragging should initiate on pointer down.
  final Widget child;

  /// The index of the associated item in the list. If null, resolves from the enclosing [NixListScope].
  final int? index;

  /// Whether drag reordering is enabled.
  final bool enabled;

  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final scope = NixListScope.of(context);
    final targetIndex = index ?? scope?.index;
    if (targetIndex == null) return;
    final gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final recognizer = createRecognizer()..gestureSettings = gestureSettings;
    if (scope?.startItemDragReorder != null) {
      scope!.startItemDragReorder!(
        index: targetIndex,
        event: event,
        recognizer: recognizer,
      );
    } else {
      scope?.onStartReorder?.call(targetIndex, event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final internalScope = _NixItemInternalScope.of(context);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (this is! NixReorderDelayedDragListener) {
          internalScope?.onHandlePointerDown();
        }
        if (enabled) {
          _startDragging(context, event);
        }
      },
      onPointerUp: (_) {
        if (this is! NixReorderDelayedDragListener) {
          internalScope?.onHandlePointerUp();
        }
      },
      onPointerCancel: (_) {
        if (this is! NixReorderDelayedDragListener) {
          internalScope?.onHandlePointerUp();
        }
      },
      child: child,
    );
  }
}

/// A delayed drag listener widget modeled after Flutter's native [ReorderableDelayedDragStartListener].
///
/// Wrap any custom widget with this to allow drag-to-reorder after a long-press.
class NixReorderDelayedDragListener extends NixReorderDragListener {
  /// Creates a [NixReorderDelayedDragListener].
  const NixReorderDelayedDragListener({
    super.key,
    required super.child,
    super.index,
    super.enabled,
    this.delay = const Duration(milliseconds: 200),
  });

  /// The duration of the long press required to start the drag.
  final Duration delay;

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(delay: delay, debugOwner: this);
  }
}

/// An ergonomic reorder handle widget for [NixListItem].
///
/// Place this in [NixListItem.trailing] or [NixListItem.leading] to allow
/// immediate drag-to-reorder on pointer down. Developers can supply any custom
/// icon (e.g. `Icons.drag_indicator`, `Icons.reorder`, etc.) or arbitrary widget via [child].
class NixReorderHandle extends StatelessWidget {
  /// Creates a [NixReorderHandle].
  ///
  /// Developers can customize the appearance by providing [icon] or a full [child] widget.
  const NixReorderHandle({
    super.key,
    this.icon,
    this.child,
    this.index,
    this.enabled = true,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Optional custom icon widget. Defaults to [Icons.drag_handle_rounded]
  /// if both [icon] and [child] are null.
  final Widget? icon;

  /// Optional custom child widget that completely overrides the handle representation.
  final Widget? child;

  /// Optional item index. If null, automatically resolves from the enclosing [NixListScope].
  final int? index;

  /// Whether this handle is active.
  final bool enabled;

  /// Touch padding around the handle.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget handleContent =
        child ??
        IconTheme(
          data: IconThemeData(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 20.0,
          ),
          child: icon ?? const Icon(Icons.drag_handle_rounded),
        );

    return NixReorderDragListener(
      index: index,
      enabled: enabled,
      child: Padding(padding: padding, child: handleContent),
    );
  }
}

/// A premium, interactive list item designed for [NixListView].
///
/// Features:
/// - **Dynamic Segmented Corner Radii**: Seamlessly fits into 16px container
///   with 12px outer corners, 6px inner/neighbor corners, and dynamically morphs
///   into an isolated 14px card when selected, active, playing, or swiped.
/// - **Swipe Mode & Direction**: Supports full swipe-to-dismiss (Gmail style)
///   as well as action buttons reveal mode (Primary: Share, Archive; Secondary: Collaborator, Edit).
/// - **Direction Filtering**: Restrict swipe to Both, RightOnly, LeftOnly, or Disabled.
/// - **Independent Left/Right Dismiss**: Supports different actions, colors,
///   icons, and thresholds for left and right swipes.
/// - **Multi-Select & Active/Playing States**: Supports batch selection mode
///   and active track states with dynamic segmented corner morphing.
class NixListItem extends StatefulWidget {
  /// Creates a standard [NixListItem].
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
    this.canReorder = true,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.confirmSwipeRight,
    this.confirmSwipeLeft,
    this.leftAction,
    this.rightAction,
    this.primaryActions,
    this.secondaryActions,
    this.swipeMode,
    this.swipeDirection,
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
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.child,
    this.reorderHandle,
    this.customEqualizer,
    this.showEqualizerWhenPlaying = true,
    this.showSelectionIndicator = true,
  });

  /// Creates a [NixListItem] styled with Gmail's signature swipe presets:
  /// - Green archive background on swipe right (start-to-end) with centered archive icon.
  /// - Red delete background on swipe left (end-to-start) with centered delete icon.
  /// - Full swipe-to-dismiss mode sliding all the way through and collapsing.
  factory NixListItem.gmailStyle({
    Key? key,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    bool isSelected = false,
    bool isSelectable = false,
    ValueChanged<bool>? onSelectionChanged,
    bool isPlaying = false,
    bool isActive = false,
    bool canReorder = true,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeLeft,
    VoidCallback? onArchive,
    VoidCallback? onDelete,
    Future<bool> Function()? confirmSwipeRight,
    Future<bool> Function()? confirmSwipeLeft,
    Future<bool> Function()? confirmArchive,
    Future<bool> Function()? confirmDelete,
    Widget? swipeRightIcon,
    Widget? swipeLeftIcon,
    Widget? swipeRightLabel,
    Widget? swipeLeftLabel,
    Color? swipeRightColor,
    Color? swipeLeftColor,
    Color? swipeRightForegroundColor,
    Color? swipeLeftForegroundColor,
    NixSwipeDirection? swipeDirection,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? activeBackgroundColor,
    BorderRadius? borderRadius,
    BorderRadius? selectedBorderRadius,
    BorderRadius? activeBorderRadius,
    BoxBorder? border,
    BoxBorder? selectedBorder,
    BoxBorder? activeBorder,
    double? elevation,
    double? selectedElevation,
    double? activeElevation,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    EdgeInsetsGeometry? contentPadding,
    Color? splashColor,
    Color? highlightColor,
    Color? hoverColor,
    Widget? child,
    Widget? reorderHandle,
    Widget? customEqualizer,
    bool showEqualizerWhenPlaying = true,
    bool showSelectionIndicator = true,
  }) {
    final effectiveSwipeRight = onSwipeRight ?? onArchive;
    final effectiveSwipeLeft = onSwipeLeft ?? onDelete;
    final effectiveConfirmRight = confirmSwipeRight ?? confirmArchive;
    final effectiveConfirmLeft = confirmSwipeLeft ?? confirmDelete;

    return NixListItem(
      key: key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      isSelected: isSelected,
      isSelectable: isSelectable,
      onSelectionChanged: onSelectionChanged,
      isPlaying: isPlaying,
      isActive: isActive,
      canReorder: canReorder,
      swipeMode: NixSwipeMode.dismiss,
      swipeDirection: swipeDirection,
      leftAction: NixSwipeAction.gmailArchive(
        onTriggered: effectiveSwipeRight,
        confirmDismiss: effectiveConfirmRight,
        icon: swipeRightIcon,
        label: swipeRightLabel,
        backgroundColor: swipeRightColor,
        foregroundColor: swipeRightForegroundColor,
      ),
      rightAction: NixSwipeAction.gmailDelete(
        onTriggered: effectiveSwipeLeft,
        confirmDismiss: effectiveConfirmLeft,
        icon: swipeLeftIcon,
        label: swipeLeftLabel,
        backgroundColor: swipeLeftColor,
        foregroundColor: swipeLeftForegroundColor,
      ),
      backgroundColor: backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor,
      activeBackgroundColor: activeBackgroundColor,
      borderRadius: borderRadius,
      selectedBorderRadius: selectedBorderRadius,
      activeBorderRadius: activeBorderRadius,
      border: border,
      selectedBorder: selectedBorder,
      activeBorder: activeBorder,
      elevation: elevation,
      selectedElevation: selectedElevation,
      activeElevation: activeElevation,
      padding: padding,
      contentPadding: contentPadding,
      splashColor: splashColor,
      highlightColor: highlightColor,
      hoverColor: hoverColor,
      reorderHandle: reorderHandle,
      customEqualizer: customEqualizer,
      showEqualizerWhenPlaying: showEqualizerWhenPlaying,
      showSelectionIndicator: showSelectionIndicator,
      child: child,
    );
  }

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

  /// Whether this item can be reordered in a reorderable [NixListView].
  /// Defaults to true. If false, reordering is completely disabled for this item.
  final bool canReorder;

  /// Callback invoked on swipe right (start-to-end swipe).
  ///
  /// Convenience alternative to providing [leftAction].
  final VoidCallback? onSwipeRight;

  /// Callback invoked on swipe left (end-to-start swipe).
  ///
  /// Convenience alternative to providing [rightAction].
  final VoidCallback? onSwipeLeft;

  /// Optional confirmation callback for [onSwipeRight].
  final Future<bool> Function()? confirmSwipeRight;

  /// Optional confirmation callback for [onSwipeLeft].
  final Future<bool> Function()? confirmSwipeLeft;

  /// Independent action triggered by swiping right (from left edge).
  ///
  /// Convenience property alias for a single [primaryActions] item.
  final NixSwipeAction? leftAction;

  /// Independent action triggered by swiping left (from right edge).
  ///
  /// Convenience property alias for a single [secondaryActions] item.
  final NixSwipeAction? rightAction;

  /// List of swipe actions revealed when swiping right (start-to-end).
  ///
  /// Commonly used for Primary Actions such as Share or Archive.
  final List<NixSwipeAction>? primaryActions;

  /// List of swipe actions revealed when swiping left (end-to-start).
  ///
  /// Commonly used for Secondary Actions such as Collaborator or Edit.
  final List<NixSwipeAction>? secondaryActions;

  /// The swipe interaction mode (full dismiss or action buttons reveal).
  ///
  /// If null, falls back to [NixListScope.swipeMode] or [NixSwipeMode.dismiss].
  final NixSwipeMode? swipeMode;

  /// Permitted swipe directions.
  ///
  /// If null, falls back to [NixListScope.swipeDirection] or [NixSwipeDirection.both].
  final NixSwipeDirection? swipeDirection;

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

  /// Splash color for Flutter's native ink ripple effect on tap.
  final Color? splashColor;

  /// Highlight color for Flutter's native ink reaction while pressed or long-pressed.
  final Color? highlightColor;

  /// Hover color when pointer hovers over the item.
  final Color? hoverColor;

  /// Custom full-width child. If provided, replaces standard leading/title/subtitle/trailing.
  final Widget? child;

  /// Optional reorder handle widget (e.g. [NixReorderHandle]).
  final Widget? reorderHandle;

  /// Optional custom widget displayed when item is playing.
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
  bool _hasVibratedForSwipe = false;
  bool _isDismissed = false;
  bool _isOpen = false;
  bool _isActionSwiping = false;
  bool _isReorderHandleTouched = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late final AnimationController _collapseController;
  late Animation<double> _collapseAnimation;

  List<NixSwipeAction> get _effectivePrimaryActions {
    if (widget.primaryActions != null && widget.primaryActions!.isNotEmpty) {
      return widget.primaryActions!;
    }
    if (widget.leftAction != null) {
      return [widget.leftAction!];
    }
    if (widget.onSwipeRight != null) {
      return [
        NixSwipeAction(
          onTriggered: widget.onSwipeRight!,
          confirmDismiss: widget.confirmSwipeRight,
          actionType: NixSwipeActionType.dismiss,
          emailStyle: true,
          centeredIcon: true,
        ),
      ];
    }
    return const [];
  }

  List<NixSwipeAction> get _effectiveSecondaryActions {
    if (widget.secondaryActions != null &&
        widget.secondaryActions!.isNotEmpty) {
      return widget.secondaryActions!;
    }
    if (widget.rightAction != null) {
      return [widget.rightAction!];
    }
    if (widget.onSwipeLeft != null) {
      return [
        NixSwipeAction(
          onTriggered: widget.onSwipeLeft!,
          confirmDismiss: widget.confirmSwipeLeft,
          actionType: NixSwipeActionType.dismiss,
          emailStyle: true,
          centeredIcon: true,
        ),
      ];
    }
    return const [];
  }

  double _getButtonsWidth(int count, double itemWidth) {
    if (count == 0) return 0.0;
    const double perButton = 76.0;
    return math.min(itemWidth * 0.75, perButton * count);
  }

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _resetAnimation = const AlwaysStoppedAnimation(0.0);

    _resetController.addListener(() {
      if (mounted) {
        setState(() {
          _swipeOffset = _resetAnimation.value;
        });
      }
      if (_resetController.isAnimating && !_isDismissed) {
        final scope = NixListScope.of(context);
        scope?.onSwipeUpdate?.call(scope.index, _resetAnimation.value);
      }
    });

    _resetController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final scope = NixListScope.of(context);
        final mode =
            widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
        if (!_isDismissed && mode == NixSwipeMode.actions) {
          final nowOpen = _swipeOffset.abs() > 1.0;
          if (mounted) {
            setState(() {
              _isOpen = nowOpen;
              if (!nowOpen) _isActionSwiping = false;
            });
          }
          scope?.onActionOpenChanged?.call(scope.index, nowOpen);
        } else {
          if (mounted) {
            setState(() {
              _isOpen = false;
              _isActionSwiping = false;
            });
          }
          scope?.onActionOpenChanged?.call(scope.index, false);
        }
        scope?.onSwipeEnd?.call(scope.index);
      }
    });

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
      _isOpen = false;
      _isActionSwiping = false;
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
    if (_isReorderHandleTouched) return;
    final scope = NixListScope.of(context);
    if (scope?.isReordering == true || scope?.isDragged == true) return;

    final isEffectiveSelected =
        widget.isSelected || (scope?.isSelected ?? false);
    final isEffectiveSelectable =
        widget.isSelectable || (scope?.isSelectable ?? false);
    // In default select cannot swipe, only in play or normal unselected!
    if (isEffectiveSelected || isEffectiveSelectable) return;

    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    if (mode == NixSwipeMode.actions) {
      _isActionSwiping = true;
    }

    _thresholdTriggered = false;
    _hasVibratedForSwipe = false;

    // Explicitly cancel any pending long-press reorder so horizontal swipe is isolated
    scope?.onCancelReorder?.call();
    if (_resetController.isAnimating) {
      _resetController.stop();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double itemWidth) {
    if (!widget.enabled || _isDismissed) return;
    if (_isReorderHandleTouched) return;
    final scope = NixListScope.of(context);
    if (scope?.isReordering == true || scope?.isDragged == true) return;

    final isEffectiveSelected =
        widget.isSelected || (scope?.isSelected ?? false);
    final isEffectiveSelectable =
        widget.isSelectable || (scope?.isSelectable ?? false);
    // In default select cannot swipe, only in play or normal unselected!
    if (isEffectiveSelected || isEffectiveSelectable) return;

    scope?.onCancelReorder?.call();

    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    if (mode == NixSwipeMode.actions) {
      _isActionSwiping = true;
    }

    final direction =
        widget.swipeDirection ??
        scope?.swipeDirection ??
        NixSwipeDirection.both;
    if (direction == NixSwipeDirection.disabled) return;

    final dx = details.primaryDelta ?? 0.0;
    final primaryActions = _effectivePrimaryActions;
    final secondaryActions = _effectiveSecondaryActions;

    // Check direction constraints on starting new movement from center
    if (direction == NixSwipeDirection.rightOnly &&
        _swipeOffset <= 0 &&
        dx < 0) {
      return;
    }
    if (direction == NixSwipeDirection.leftOnly &&
        _swipeOffset >= 0 &&
        dx > 0) {
      return;
    }

    // Check action availability
    if (_swipeOffset <= 0 && dx > 0 && primaryActions.isEmpty) return;
    if (_swipeOffset >= 0 && dx < 0 && secondaryActions.isEmpty) return;

    double newOffset = _swipeOffset + dx;

    // Enforce directional barriers
    if (direction == NixSwipeDirection.rightOnly && newOffset < 0) {
      newOffset = 0.0;
    } else if (direction == NixSwipeDirection.leftOnly && newOffset > 0) {
      newOffset = 0.0;
    }

    if (newOffset > 0 && primaryActions.isEmpty) newOffset = 0.0;
    if (newOffset < 0 && secondaryActions.isEmpty) newOffset = 0.0;

    if (mode == NixSwipeMode.actions) {
      final double maxOpenWidth = newOffset > 0
          ? _getButtonsWidth(primaryActions.length, itemWidth)
          : _getButtonsWidth(secondaryActions.length, itemWidth);

      // Damp drag past max reveal width
      if (newOffset > maxOpenWidth) {
        final over = newOffset - maxOpenWidth;
        newOffset = maxOpenWidth + (over * 0.25);
      } else if (newOffset < -maxOpenWidth) {
        final over = -maxOpenWidth - newOffset;
        newOffset = -maxOpenWidth - (over * 0.25);
      }
    } else {
      // In dismiss mode, slide freely all the way through across the screen!
      newOffset = newOffset.clamp(-itemWidth * 1.35, itemWidth * 1.35);

      final activeAction = newOffset > 0
          ? (primaryActions.isNotEmpty ? primaryActions.first : null)
          : (secondaryActions.isNotEmpty ? secondaryActions.first : null);

      if (activeAction != null) {
        final thresholdPx = itemWidth * activeAction.threshold;
        final crossed = newOffset.abs() >= thresholdPx;
        if (crossed && !_thresholdTriggered) {
          _thresholdTriggered = true;
          if (!_hasVibratedForSwipe) {
            _hasVibratedForSwipe = true;
            if (activeAction.hapticFeedback) {
              HapticFeedback.mediumImpact();
            }
          }
        } else if (!crossed && _thresholdTriggered) {
          _thresholdTriggered = false;
          _hasVibratedForSwipe = false;
          if (activeAction.hapticFeedback) {
            HapticFeedback.selectionClick();
          }
        }
      }
    }

    setState(() {
      _swipeOffset = newOffset;
    });

    scope?.onSwipeUpdate?.call(scope.index, _swipeOffset);
  }

  Future<void> _onHorizontalDragEnd(
    DragEndDetails details,
    double itemWidth,
  ) async {
    if (!widget.enabled || _isDismissed) return;
    if (_isReorderHandleTouched) return;
    final scope = NixListScope.of(context);
    final isEffectiveSelected =
        widget.isSelected || (scope?.isSelected ?? false);
    final isEffectiveSelectable =
        widget.isSelectable || (scope?.isSelectable ?? false);
    // In default select cannot swipe, only in play or normal unselected!
    if (isEffectiveSelected || isEffectiveSelectable) return;

    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    final velocity = details.primaryVelocity ?? 0.0;
    final primaryActions = _effectivePrimaryActions;
    final secondaryActions = _effectiveSecondaryActions;

    if (mode == NixSwipeMode.actions) {
      if (_swipeOffset > 0 && primaryActions.isNotEmpty) {
        final openWidth = _getButtonsWidth(primaryActions.length, itemWidth);
        final shouldOpen = velocity > 200 || _swipeOffset >= openWidth * 0.45;
        if (shouldOpen) {
          _animateTo(openWidth);
        } else {
          _animateTo(0.0);
        }
      } else if (_swipeOffset < 0 && secondaryActions.isNotEmpty) {
        final openWidth = _getButtonsWidth(secondaryActions.length, itemWidth);
        final shouldOpen =
            velocity < -200 || _swipeOffset.abs() >= openWidth * 0.45;
        if (shouldOpen) {
          _animateTo(-openWidth);
        } else {
          _animateTo(0.0);
        }
      } else {
        _animateTo(0.0);
      }
      return;
    }

    // Dismiss mode
    final activeAction = _swipeOffset > 0
        ? (primaryActions.isNotEmpty ? primaryActions.first : null)
        : (secondaryActions.isNotEmpty ? secondaryActions.first : null);

    if (activeAction != null) {
      final thresholdPx = itemWidth * activeAction.threshold;
      final isFling =
          (_swipeOffset > 0 && velocity > 400) ||
          (_swipeOffset < 0 && velocity < -400);
      final isCrossed = _swipeOffset.abs() >= thresholdPx;

      if (isCrossed || isFling) {
        // Fast swipe / fling catch: vibrate if not already vibrated during drag update
        if (!_hasVibratedForSwipe) {
          _thresholdTriggered = true;
          _hasVibratedForSwipe = true;
          if (activeAction.hapticFeedback) {
            HapticFeedback.mediumImpact();
          }
        }

        if (activeAction.actionType == NixSwipeActionType.dismiss) {
          bool canDismiss = true;
          if (activeAction.confirmDismiss != null) {
            canDismiss = await activeAction.confirmDismiss!();
          }
          if (!mounted) return;

          if (canDismiss) {
            await _slideOutAndDismiss(itemWidth, activeAction);
            return;
          }
        } else {
          // Trigger action without dismissing
          activeAction.onTriggered();
        }
      }
    }

    // Spring back to center
    _resetSpringBack();
  }

  void _animateTo(double target) {
    _thresholdTriggered = false;
    _hasVibratedForSwipe = false;
    if (_resetController.isAnimating) {
      _resetController.stop();
    }
    _resetAnimation = Tween<double>(begin: _swipeOffset, end: target).animate(
      CurvedAnimation(parent: _resetController, curve: const NixSpringCurve()),
    );

    final scope = NixListScope.of(context);
    final willBeOpen = target.abs() > 1.0;
    if (_isOpen != willBeOpen) {
      setState(() {
        _isOpen = willBeOpen;
        if (!willBeOpen) _isActionSwiping = false;
      });
      scope?.onActionOpenChanged?.call(scope.index, willBeOpen);
    }

    _resetController.forward(from: 0.0);
  }

  Future<void> _slideOutAndDismiss(
    double itemWidth,
    NixSwipeAction action,
  ) async {
    setState(() {
      _isDismissed = true;
      _isOpen = false;
      _isActionSwiping = false;
      _thresholdTriggered = false;
      _hasVibratedForSwipe = false;
    });
    final scope = NixListScope.of(context);
    scope?.onActionOpenChanged?.call(scope.index, false);
    scope?.onSwipeEnd?.call(scope.index);

    if (_resetController.isAnimating) {
      _resetController.stop();
    }

    // Smoothly glide completely off-screen
    final targetOffset = _swipeOffset > 0
        ? itemWidth * 1.30
        : -itemWidth * 1.30;
    _resetAnimation = Tween<double>(begin: _swipeOffset, end: targetOffset)
        .animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
        );
    await _resetController.forward(from: 0.0);
    if (!mounted) return;

    // Smoothly collapse height
    await _collapseController.forward(from: 0.0);
    if (!mounted) return;

    final afterScope = NixListScope.of(context);
    afterScope?.onActionOpenChanged?.call(afterScope.index, false);
    afterScope?.onSwipeEnd?.call(afterScope.index);

    action.onTriggered();
  }

  void _resetSpringBack() {
    _thresholdTriggered = false;
    _hasVibratedForSwipe = false;
    _animateTo(0.0);
  }

  void _handleTap() {
    if (!widget.enabled || _isReorderHandleTouched) return;
    final scope = NixListScope.of(context);
    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    final currentOffset = _resetController.isAnimating
        ? _resetAnimation.value
        : _swipeOffset;
    final isActionTriggered = mode == NixSwipeMode.actions &&
        (_isOpen ||
         _isActionSwiping ||
         currentOffset.abs() > 1.0 ||
         _swipeOffset.abs() > 1.0);

    if (_isOpen || _swipeOffset.abs() > 1.0 || isActionTriggered) {
      // Tap closes revealed actions
      _animateTo(0.0);
      return;
    }
    final canSelect = widget.isSelectable || (scope?.isSelectable ?? false);
    if (canSelect && !isActionTriggered) {
      final nextState = !(widget.isSelected || (scope?.isSelected ?? false));
      widget.onSelectionChanged?.call(nextState);
      scope?.onItemSelect?.call(scope.index, nextState);
      return;
    }
    if (!isActionTriggered) {
      widget.onTap?.call();
    }
  }

  Widget _buildReorderHandle(Widget handle, bool isActionTriggered) {
    if (isActionTriggered) {
      return IgnorePointer(child: handle);
    }
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _isReorderHandleTouched = true,
      onPointerUp: (_) => _isReorderHandleTouched = false,
      onPointerCancel: (_) => _isReorderHandleTouched = false,
      child: handle,
    );
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

    final currentOffset = _resetController.isAnimating
        ? _resetAnimation.value
        : _swipeOffset;
    final isCurrentlySwiping = currentOffset.abs() > 1.5;

    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    final isActionSwipeTriggered = mode == NixSwipeMode.actions &&
        (_isOpen ||
            _isActionSwiping ||
            currentOffset.abs() > 1.0 ||
            _swipeOffset.abs() > 1.0);

    final isEffectivePlaying = !isActionSwipeTriggered &&
        (widget.isPlaying || widget.isActive || (scope?.isPlaying ?? false));
    final isEffectiveSelected = !isActionSwipeTriggered &&
        (widget.isSelected || (scope?.isSelected ?? false));
    final isEffectiveSelectable = !isActionSwipeTriggered &&
        (widget.isSelectable || (scope?.isSelectable ?? false));

    final isDragged = (scope?.isDragged ?? false);

    // Compute dynamic segmented corner radius
    final BorderRadius computedRadius;
    if (widget.borderRadius != null) {
      computedRadius = widget.borderRadius!;
    } else if (isEffectiveSelected && widget.selectedBorderRadius != null) {
      computedRadius = widget.selectedBorderRadius!;
    } else if (isEffectivePlaying && widget.activeBorderRadius != null) {
      computedRadius = widget.activeBorderRadius!;
    } else if (isDragged || isCurrentlySwiping) {
      computedRadius = const BorderRadius.all(
        Radius.circular(NixListPhysics.outerItemRadius),
      );
    } else {
      computedRadius = NixListPhysics.computeSegmentedRadius(
        index: scope?.index ?? 0,
        totalCount: scope?.totalCount ?? 1,
        isSelected: isEffectiveSelected,
        isPlaying: isEffectivePlaying,
        isDragged: false,
        prevDetached: scope?.prevDetached ?? false,
        nextDetached: scope?.nextDetached ?? false,
        prevSameState: scope?.prevSameState ?? false,
        nextSameState: scope?.nextSameState ?? false,
      );
    }

    // Dynamic background colors (solid & opaque to prevent see-through during swipe/reorder)
    final baseColor = widget.backgroundColor ?? colors.surfaceContainerLow;
    Color effectiveBgColor;
    if (isEffectiveSelected || isEffectivePlaying) {
      final selectedTint = widget.selectedBackgroundColor ??
          widget.activeBackgroundColor ??
          (nixTheme.primary ?? colors.primary).withValues(alpha: 0.16);
      effectiveBgColor = selectedTint.a >= 1.0
          ? selectedTint
          : Color.alphaBlend(selectedTint, baseColor);
    } else {
      effectiveBgColor = baseColor;
    }

    if (effectiveBgColor.a < 1.0) {
      effectiveBgColor = Color.alphaBlend(effectiveBgColor, colors.surface);
    }
    if (effectiveBgColor.a < 1.0) {
      effectiveBgColor = effectiveBgColor.withValues(alpha: 1.0);
    }

    // Dynamic border (no border by default for select/play unless explicitly specified)
    BoxBorder? effectiveBorder;
    if (isEffectiveSelected) {
      effectiveBorder = widget.selectedBorder ?? widget.border;
    } else if (isEffectivePlaying) {
      effectiveBorder = widget.activeBorder ?? widget.border;
    } else {
      effectiveBorder = widget.border;
    }

    // Elevation & shadow (flat 0.0 by default for both select and play)
    final effectiveElevation = isEffectiveSelected
        ? (widget.selectedElevation ?? 0.0)
        : isEffectivePlaying
        ? (widget.activeElevation ?? 0.0)
        : (widget.elevation ?? 0.0);

    final List<BoxShadow>? effectiveShadow = isCurrentlySwiping
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6.0,
              spreadRadius: 0.0,
              offset: Offset(currentOffset > 0 ? -1.0 : 1.0, 2.0),
            ),
          ]
        : (effectiveElevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: effectiveElevation * 2.5,
                  offset: Offset(0, effectiveElevation),
                ),
              ]
            : null);

    return SizeTransition(
      sizeFactor: Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(_collapseAnimation),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth;
          final itemCanReorder = !isActionSwipeTriggered && widget.canReorder;
          final canReorderHandle =
              (scope?.canReorderHandle ?? false) && itemCanReorder;
          Widget? effectiveReorderHandle = widget.reorderHandle;
          if (effectiveReorderHandle == null &&
              (scope?.buildDefaultDragHandles ?? false) &&
              canReorderHandle) {
            effectiveReorderHandle = const NixReorderHandle();
          } else if (effectiveReorderHandle != null &&
              (!itemCanReorder || isActionSwipeTriggered)) {
            effectiveReorderHandle = IgnorePointer(
              child: effectiveReorderHandle,
            );
          }

          Widget content =
              widget.child ??
              Row(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: (isEffectiveSelectable &&
                            widget.showSelectionIndicator)
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSelectionIndicator(
                                colors,
                                isEffectiveSelected,
                              ),
                              const SizedBox(width: 12),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
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
                            style:
                                (theme.textTheme.bodyLarge ??
                                        const TextStyle(fontSize: 16))
                                    .copyWith(
                                      fontWeight:
                                          isEffectivePlaying ||
                                              isEffectiveSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isEffectivePlaying
                                          ? (nixTheme.primary ?? colors.primary)
                                          : (widget.enabled
                                                ? colors.onSurface
                                                : colors.onSurface.withValues(
                                                    alpha: 0.4,
                                                  )),
                                    ),
                            child: widget.title!,
                          ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style:
                                (theme.textTheme.bodyMedium ??
                                        const TextStyle(fontSize: 13))
                                    .copyWith(
                                      color: widget.enabled
                                          ? colors.onSurfaceVariant
                                          : colors.onSurfaceVariant.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                            child: widget.subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isEffectivePlaying &&
                      widget.showEqualizerWhenPlaying &&
                      widget.customEqualizer != null) ...[
                    const SizedBox(width: 8),
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: widget.customEqualizer!,
                    ),
                  ],
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                  if (effectiveReorderHandle != null) ...[
                    const SizedBox(width: 4),
                    _buildReorderHandle(
                      effectiveReorderHandle,
                      isActionSwipeTriggered,
                    ),
                  ],
                ],
              );

          final canTap = widget.enabled &&
              (widget.onTap != null ||
                  isEffectiveSelectable ||
                  _isOpen ||
                  isActionSwipeTriggered ||
                  _swipeOffset.abs() > 1.0);
          final canLongPress = widget.enabled && widget.onLongPress != null;

          // Card surface with Flutter's native Material ink splash
          final cardSurface = AnimatedContainer(
            duration: (scope?.isReordering ?? false)
                ? Duration.zero
                : const Duration(milliseconds: 200),
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
                splashColor: widget.splashColor,
                highlightColor: widget.highlightColor,
                hoverColor: widget.hoverColor,
                onTap: canTap ? _handleTap : null,
                onLongPress: canLongPress ? widget.onLongPress : null,
                child: Padding(
                  padding: widget.contentPadding ?? widget.padding,
                  child: _NixItemInternalScope(
                    onHandlePointerDown: () => _isReorderHandleTouched = true,
                    onHandlePointerUp: () => _isReorderHandleTouched = false,
                    child: content,
                  ),
                ),
              ),
            ),
          );

          // Wrap in gesture detector for horizontal swipe actions (full width, no horizontal gaps)
          Widget itemWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (details) =>
                _onHorizontalDragUpdate(details, itemWidth),
            onHorizontalDragEnd: (details) =>
                _onHorizontalDragEnd(details, itemWidth),
            child: cardSurface,
          );

          final hasSwipeActions =
              _effectivePrimaryActions.isNotEmpty ||
              _effectiveSecondaryActions.isNotEmpty;

          // If swipe actions exist, stack behind
          if (hasSwipeActions) {
            itemWidget = Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _buildSwipeBackground(
                    colors: colors,
                    offset: currentOffset,
                    itemWidth: itemWidth,
                    scope: scope,
                  ),
                ),
                Transform.translate(
                  offset: Offset(currentOffset, 0),
                  child: itemWidget,
                ),
              ],
            );
          }

          return itemWidget;
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
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            Icons.check_rounded,
            size: 14.0,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required ColorScheme colors,
    required double offset,
    required double itemWidth,
    required NixListScope? scope,
  }) {
    final mode = widget.swipeMode ?? scope?.swipeMode ?? NixSwipeMode.dismiss;
    final primaryActions = _effectivePrimaryActions;
    final secondaryActions = _effectiveSecondaryActions;

    if (offset > 0 && primaryActions.isNotEmpty) {
      if (mode == NixSwipeMode.actions) {
        return _buildActionButtonsRow(
          actions: primaryActions,
          isStart: true,
          itemWidth: itemWidth,
        );
      }

      // Dismiss mode - primary action background
      final action = primaryActions.first;
      return _buildDismissActionBackground(
        action: action,
        offset: offset,
        itemWidth: itemWidth,
        isRightSwipe: true,
        colors: colors,
      );
    } else if (offset < 0 && secondaryActions.isNotEmpty) {
      if (mode == NixSwipeMode.actions) {
        return _buildActionButtonsRow(
          actions: secondaryActions,
          isStart: false,
          itemWidth: itemWidth,
        );
      }

      // Dismiss mode - secondary action background
      final action = secondaryActions.first;
      return _buildDismissActionBackground(
        action: action,
        offset: offset,
        itemWidth: itemWidth,
        isRightSwipe: false,
        colors: colors,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtonsRow({
    required List<NixSwipeAction> actions,
    required bool isStart,
    required double itemWidth,
  }) {
    final totalWidth = _getButtonsWidth(actions.length, itemWidth);
    final buttonWidth = totalWidth / actions.length;

    return Align(
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(NixListPhysics.detachedItemRadius),
        ),
        child: SizedBox(
          width: totalWidth,
          height: double.infinity,
          child: Row(
            children: actions.map((action) {
              final bgColor =
                  action.backgroundColor ??
                  (action.actionType == NixSwipeActionType.dismiss
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary);
              final fgColor =
                  action.foregroundColor ??
                  (action.actionType == NixSwipeActionType.dismiss
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.onPrimary);

              return SizedBox(
                width: buttonWidth,
                height: double.infinity,
                child: Material(
                  color: bgColor,
                  child: InkWell(
                    onTap: () async {
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
                      }
                      action.onTriggered();
                      _animateTo(0.0);
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (action.icon != null)
                                IconTheme(
                                  data: IconThemeData(
                                    color: fgColor,
                                    size: 20.0,
                                  ),
                                  child: action.icon!,
                                ),
                              if (action.label != null) ...[
                                const SizedBox(height: 2),
                                DefaultTextStyle(
                                  style: TextStyle(
                                    color: fgColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.0,
                                    letterSpacing: 0.1,
                                  ),
                                  child: action.label!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissActionBackground({
    required NixSwipeAction action,
    required double offset,
    required double itemWidth,
    required bool isRightSwipe,
    required ColorScheme colors,
  }) {
    final progress = (offset.abs() / (itemWidth * action.threshold)).clamp(
      0.0,
      2.0,
    );
    if (action.builder != null) {
      return action.builder!(context, progress);
    }

    final bgColor =
        action.backgroundColor ??
        (action.actionType == NixSwipeActionType.dismiss
            ? (isRightSwipe ? const Color(0xFF2E7D32) : colors.error)
            : (isRightSwipe ? colors.primary : colors.secondary));
    final fgColor =
        action.foregroundColor ??
        (action.actionType == NixSwipeActionType.dismiss
            ? Colors.white
            : (isRightSwipe ? colors.onPrimary : colors.onSecondary));

    final slideProgress = progress.clamp(0.0, 1.0);

    if (action.emailStyle || action.centeredIcon) {
      // Email / Gmail style: Material 3 Expressive fully rounded pill adapting width directly to swipe
      return LayoutBuilder(
        builder: (context, constraints) {
          final revealDistance = offset.abs();
          if (revealDistance <= 0.0) {
            return const SizedBox.shrink();
          }

          final availableHeight =
              constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : 56.0;
          final availableWidth =
              constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : itemWidth;

          // Fully rounded pill radius (stadium / pill capsule)
          final fullyRoundedRadius = BorderRadius.circular(
            availableHeight / 2.0,
          );

          // Does NOT overlap the list item. The swipe background expands beside the sliding card.
          final pillWidth = math.min(availableWidth, revealDistance);

          final activeBgColor = bgColor;

          final alignment = isRightSwipe
              ? Alignment.centerLeft
              : Alignment.centerRight;

          final badgeSize = math.min(40.0, availableHeight - 12.0);
          final labelOpacity = ((revealDistance - 80.0) / 30.0).clamp(0.0, 1.0);

          Widget? labelWidget;
          if (action.label != null && labelOpacity > 0.0) {
            labelWidget = Opacity(
              opacity: labelOpacity,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                child: action.label!,
              ),
            );
          }

          // Animated Material 3 Expressive icon presentation with smooth entry scaling, rotation, and threshold pop
          final double revealFactor = (revealDistance / 50.0).clamp(0.0, 1.0);
          final double entryScale = Curves.easeOutCubic.transform(revealFactor);
          final double targetScale = _thresholdTriggered ? 1.25 : entryScale;
          final double iconOpacity = (revealDistance / 28.0).clamp(0.0, 1.0);
          final double targetRotation = _thresholdTriggered
              ? (isRightSwipe ? 0.04 : -0.04)
              : 0.0;

          final Widget centeredContent = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (action.icon != null)
                AnimatedRotation(
                  turns: targetRotation,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: AnimatedScale(
                    scale: targetScale,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: _thresholdTriggered ? 0.32 : 0.22,
                          ),
                        ),
                        child: Center(
                          child: IconTheme(
                            data: IconThemeData(
                              color: fgColor,
                              size: (badgeSize * 0.58).clamp(18.0, 24.0),
                            ),
                            child: action.icon!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (labelWidget != null) ...[
                const SizedBox(width: 8.0),
                Flexible(child: labelWidget),
              ],
            ],
          );

          return Align(
            alignment: alignment,
            child: Container(
              width: pillWidth,
              height: availableHeight,
              decoration: BoxDecoration(
                color: activeBgColor,
                borderRadius: fullyRoundedRadius,
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: availableWidth,
                    maxHeight: availableHeight,
                    child: Center(child: centeredContent),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Standard edge-aligned icon with slide-in animation
    final slideX = isRightSwipe
        ? (1.0 - Curves.easeOutCubic.transform(slideProgress)) * -22.0
        : (1.0 - Curves.easeOutCubic.transform(slideProgress)) * 22.0;
    final opacity = Curves.easeOut.transform(slideProgress);

    return Align(
      alignment: isRightSwipe ? Alignment.centerLeft : Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: offset.abs(),
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        alignment: isRightSwipe ? Alignment.centerLeft : Alignment.centerRight,
        clipBehavior: Clip.antiAlias,
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(slideX, 0),
            child: OverflowBox(
              maxWidth: itemWidth,
              alignment: isRightSwipe
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRightSwipe) ...[
                    if (action.icon != null)
                      AnimatedScale(
                        scale: _thresholdTriggered ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: IconTheme(
                          data: IconThemeData(color: fgColor, size: 24.0),
                          child: action.icon!,
                        ),
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
                  ] else ...[
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
                      AnimatedScale(
                        scale: _thresholdTriggered ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: IconTheme(
                          data: IconThemeData(color: fgColor, size: 24.0),
                          child: action.icon!,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
