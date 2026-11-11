import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';
import 'nix_list_item.dart';
import 'nix_list_physics.dart';
import 'nix_swipe_action.dart';

/// Selection mode for [NixListView].
enum NixSelectionMode {
  /// Selection is disabled.
  none,

  /// At most one item can be selected at a time.
  single,

  /// Multiple items can be selected concurrently.
  multi,
}

/// Defines how reorder drag gestures can be initiated in a [NixListView].
enum NixReorderTrigger {
  /// Reordering is completely disabled for the entire list.
  disabled,

  /// Reordering can only be initiated via a developer's reorder handle or icon ([NixReorderHandle]).
  handleOnly,

  /// Reordering can be initiated by long-pressing anywhere on the whole list item.
  wholeItem,

  /// Reordering can be initiated either via [NixReorderHandle] or by long-pressing the whole list item.
  both,
}

/// A premium, pill-inspired segmented list view designed for the Nix Design System.
///
/// Features:
/// - **Segmented Corner Radii**: Encapsulates items within a 16px container
///   with 12px outer corners, 6px inner/neighbor corners, and dynamic sealing.
/// - **Neighbour Squish Physics**: Interactive horizontal swipe gestures causing
///   adjacent neighbor cards to organically squish, compress, reach, and displace.
/// - **Independent Left/Right Dismiss**: Supports different swipe gestures and actions.
/// - **Smooth Reorder Support**: Fluid drag-and-drop reordering with smooth
///   slot opening, elevated floating layer, and decoupled clean slot movement.
/// - **Selection & Active/Playing States**: Built-in support for single/multi
///   selection and media playback active states.
class NixListView extends StatefulWidget {
  /// Creates a standard [NixListView] with explicit [children].
  const NixListView({
    super.key,
    required List<Widget> this.children,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding = const EdgeInsets.all(16.0),
    this.shrinkWrap = false,
    this.onReorder,
    this.reorderable = false,
    this.canReorderOnLongPress = true,
    this.reorderTrigger = NixReorderTrigger.both,
    this.buildDefaultDragHandles = true,
    this.enableContainer = true,
    this.enableInnerClipping = true,
    this.innerClipBorderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.gap,
    this.itemSpacing = NixListPhysics.itemGap,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
    this.swipeMode = NixSwipeMode.dismiss,
    this.swipeDirection = NixSwipeDirection.both,
    this.dropTargetColor,
    this.dropTargetBorder,
    this.dropTargetBorderRadius,
  }) : itemCount = null,
       itemBuilder = null,
       separatorBuilder = null;

  /// Creates a lazily-built [NixListView] using an [itemBuilder].
  const NixListView.builder({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding = const EdgeInsets.all(16.0),
    this.shrinkWrap = false,
    this.onReorder,
    this.reorderable = false,
    this.canReorderOnLongPress = true,
    this.reorderTrigger = NixReorderTrigger.both,
    this.buildDefaultDragHandles = true,
    this.enableContainer = true,
    this.enableInnerClipping = true,
    this.innerClipBorderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.gap,
    this.itemSpacing = NixListPhysics.itemGap,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
    this.swipeMode = NixSwipeMode.dismiss,
    this.swipeDirection = NixSwipeDirection.both,
    this.dropTargetColor,
    this.dropTargetBorder,
    this.dropTargetBorderRadius,
  }) : children = null,
       separatorBuilder = null;

  /// Creates a separated [NixListView] using an [itemBuilder] and [separatorBuilder].
  const NixListView.separated({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    required Widget Function(BuildContext context, int index)
    this.separatorBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding = const EdgeInsets.all(16.0),
    this.shrinkWrap = false,
    this.onReorder,
    this.reorderable = false,
    this.canReorderOnLongPress = true,
    this.reorderTrigger = NixReorderTrigger.both,
    this.buildDefaultDragHandles = true,
    this.enableContainer = true,
    this.enableInnerClipping = true,
    this.innerClipBorderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.gap,
    this.itemSpacing = NixListPhysics.itemGap,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
    this.swipeMode = NixSwipeMode.dismiss,
    this.swipeDirection = NixSwipeDirection.both,
    this.dropTargetColor,
    this.dropTargetBorder,
    this.dropTargetBorderRadius,
  }) : children = null;

  /// Explicit list of children.
  final List<Widget>? children;

  /// Explicit number of items when using builders.
  final int? itemCount;

  /// Effective number of items in the list.
  int get effectiveItemCount => children?.length ?? itemCount ?? 0;

  /// Builder for indexed items.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Optional separator builder.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Scroll axis direction.
  final Axis scrollDirection;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Padding around the list or container.
  final EdgeInsetsGeometry padding;

  /// Whether the scroll view wraps its content tightly.
  final bool shrinkWrap;

  /// Callback executed when an item is reordered.
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Whether items can be dragged to reorder.
  final bool reorderable;

  /// Whether long-pressing an item starts reordering.
  final bool canReorderOnLongPress;

  /// Determines how items can be dragged to reorder:
  /// - [NixReorderTrigger.both]: Can drag using [NixReorderHandle] or long-pressing the whole item.
  /// - [NixReorderTrigger.handleOnly]: Can ONLY drag using a [NixReorderHandle].
  /// - [NixReorderTrigger.wholeItem]: Can drag by long-pressing anywhere on the whole list item.
  final NixReorderTrigger reorderTrigger;

  /// Whether to automatically render default drag handles ([NixReorderHandle])
  /// for list items when [reorderable] is true and [reorderTrigger] allows handles.
  ///
  /// Modeled after Flutter's native [ReorderableListView.buildDefaultDragHandles].
  /// Defaults to true. Set to false if you supply your own [NixReorderHandle]
  /// or [NixReorderDragListener] inside item content.
  final bool buildDefaultDragHandles;

  /// Whether to wrap items in the segmented surface container.
  final bool enableContainer;

  /// Custom background color for the segmented container.
  /// Defaults to [ColorScheme.surfaceContainer].
  final Color? containerColor;

  /// Corner radius of the outer container. Defaults to 16px.
  final BorderRadius containerBorderRadius;

  /// Optional border around the outer container.
  final BoxBorder? containerBorder;

  /// Inner padding inside the container surrounding the items. Defaults to 4px.
  final EdgeInsetsGeometry containerPadding;

  /// Whether to clip the inner list to the container's rounded corner bounds.
  ///
  /// Defaults to `true`. When set to `false`, inner [ClipRRect] clipping is disabled,
  /// allowing child shadows, custom elevations, or borders to render without being clipped.
  final bool enableInnerClipping;

  /// Optional custom border radius for inner clipping.
  ///
  /// If null and [enableInnerClipping] is true, automatically derives from
  /// [containerBorderRadius] reduced by the container padding inset.
  final BorderRadius? innerClipBorderRadius;

  /// The clip behavior applied when [enableInnerClipping] is true.
  ///
  /// Defaults to [Clip.antiAlias]. Setting this to [Clip.none] or setting
  /// [enableInnerClipping] to `false` disables inner clipping.
  final Clip clipBehavior;

  /// Optional spacing/gap between adjacent list items. Defaults to 2px ([NixListPhysics.itemGap]).
  ///
  /// Can be specified via [gap] or [itemSpacing].
  final double? gap;

  /// Spacing between adjacent list items. Defaults to 2px ([NixListPhysics.itemGap]).
  final double itemSpacing;

  /// Effective spacing/gap between adjacent list items.
  double get effectiveItemSpacing => gap ?? itemSpacing;

  /// Whether adjacent items dynamically squish and displace during drag/swipe gestures.
  final bool enableNeighbourSquish;

  /// Multi-select or single-select mode.
  final NixSelectionMode selectionMode;

  /// The currently selected indices.
  final Set<int>? selectedIndices;

  /// Callback when the selected indices change.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Index of the item that is actively playing / active.
  final int? playingIndex;

  /// Optional placeholder displayed when [itemCount] is 0.
  final Widget? emptyPlaceholder;

  /// Default swipe mode for descendant [NixListItem]s (dismiss or action buttons).
  final NixSwipeMode swipeMode;

  /// Permitted swipe directions for descendant [NixListItem]s.
  final NixSwipeDirection swipeDirection;

  /// Background color of the drop target slot while an item is being dragged.
  /// If null, defaults to primary color with 0.14 opacity.
  final Color? dropTargetColor;

  /// Border of the drop target slot while an item is being dragged.
  /// If null, defaults to a subtle primary border.
  final BoxBorder? dropTargetBorder;

  /// Corner radius of the drop target slot while an item is being dragged.
  /// If null, automatically computes the segmented radius of its current target place.
  final BorderRadius? dropTargetBorderRadius;

  @override
  State<NixListView> createState() => _NixListViewState();
}

class _NixListViewState extends State<NixListView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _listContainerKey = GlobalKey();
  final Map<Key, GlobalKey> _measurementKeys = {};
  final List<double> _restingSlotTops = [];
  final List<double> _restingSlotHeights = [];
  final List<double> _restingSlotCenters = [];

  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;
  Animation<double>? _settleXAnimation;

  // Reorder Gestures (Flutter-native architecture)
  MultiDragGestureRecognizer? _recognizer;
  int? _recognizerPointer;

  // Active Drag State
  int? _draggedIndex;
  int? _hoverTargetIndex;
  double _dragOffsetY = 0.0;
  double _dragOffsetX = 0.0;
  double _draggedInitialTop = 0.0;
  double _draggedHeight = 56.0;

  // Active swiping item index for dynamic neighbor corner sealing
  int? _activeSwipingIndex;

  // Internal selection state if not controlled externally
  late Set<int> _internalSelected;
  final Set<int> _actionOpenIndices = <int>{};
  bool _justReordered = false;

  @override
  void initState() {
    super.initState();
    _internalSelected = widget.selectedIndices != null
        ? Set<int>.from(widget.selectedIndices!)
        : <int>{};

    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _settleController.addListener(() {
      if (_settleController.isAnimating && _settleAnimation != null) {
        setState(() {
          _dragOffsetY = _settleAnimation!.value;
          if (_settleXAnimation != null) {
            _dragOffsetX = _settleXAnimation!.value;
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant NixListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectionMode == NixSelectionMode.none) {
      _internalSelected.clear();
    } else if (widget.selectedIndices != null) {
      _internalSelected = Set<int>.from(widget.selectedIndices!);
    }
    if (widget.effectiveItemCount != oldWidget.effectiveItemCount) {
      _activeSwipingIndex = null;
      _actionOpenIndices.clear();
    } else {
      _actionOpenIndices.removeWhere((i) => i >= widget.effectiveItemCount);
    }
  }

  @override
  void dispose() {
    _settleController.dispose();
    _recognizer?.dispose();
    _recognizer = null;
    _recognizerPointer = null;
    super.dispose();
  }

  void _handleItemSelect(int index, bool selected) {
    if (_activeSwipingIndex == index || _actionOpenIndices.contains(index)) {
      return;
    }
    setState(() {
      if (widget.selectionMode == NixSelectionMode.single) {
        _internalSelected.clear();
        if (selected) {
          _internalSelected.add(index);
        }
      } else if (widget.selectionMode == NixSelectionMode.multi) {
        if (selected) {
          _internalSelected.add(index);
        } else {
          _internalSelected.remove(index);
        }
      }
    });

    widget.onSelectionChanged?.call(Set<int>.from(_internalSelected));
  }

  void _startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    if (!widget.reorderable || widget.onReorder == null) return;
    if (widget.reorderTrigger == NixReorderTrigger.disabled) return;
    if (widget.selectionMode != NixSelectionMode.none) return;
    if (index < 0 || index >= widget.effectiveItemCount) return;
    _actionOpenIndices.removeWhere((i) => i >= widget.effectiveItemCount);
    if (_activeSwipingIndex != null || _actionOpenIndices.isNotEmpty) return;
    final rawChild = _getRawChild(context, index);
    if (rawChild is NixListItem && !rawChild.canReorder) return;

    if (_draggedIndex != null) {
      _cancelDrag();
    } else if (_recognizer != null && _recognizerPointer != event.pointer) {
      _recognizer!.dispose();
      _recognizer = null;
      _recognizerPointer = null;
    }

    recognizer.onStart = (position) => _handleDragStart(index, position);
    recognizer.addPointer(event);
    _recognizer = recognizer;
    _recognizerPointer = event.pointer;
  }

  void _startPointerDrag(
    int index,
    PointerDownEvent event, {
    required bool isImmediate,
  }) {
    final settings = MediaQuery.maybeGestureSettingsOf(context);
    _startItemDragReorder(
      index: index,
      event: event,
      recognizer: isImmediate
          ? (ImmediateMultiDragGestureRecognizer(debugOwner: this)
              ..gestureSettings = settings)
          : (DelayedMultiDragGestureRecognizer(
              delay: const Duration(milliseconds: 200),
              debugOwner: this,
            )..gestureSettings = settings),
    );
  }

  Key _getItemKey(int index) {
    final rawChild = _getRawChild(context, index);
    return rawChild.key ?? ValueKey('nix_item_$index');
  }

  double _measureItemTop(int index) {
    final itemKey = _getItemKey(index);
    final ctx = _measurementKeys[itemKey]?.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      final containerBox =
          _listContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && containerBox != null) {
        return box.localToGlobal(Offset.zero, ancestor: containerBox).dy;
      }
    }
    const defaultHeight = 60.0;
    return index * (defaultHeight + widget.effectiveItemSpacing);
  }

  double _measureItemHeight(int index) {
    final itemKey = _getItemKey(index);
    final ctx = _measurementKeys[itemKey]?.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        return box.size.height;
      }
    }
    return 56.0;
  }

  Drag? _handleDragStart(int index, Offset startPosition) {
    if (index < 0 ||
        index >= widget.effectiveItemCount ||
        _settleController.isAnimating ||
        widget.selectionMode != NixSelectionMode.none ||
        !widget.reorderable ||
        widget.onReorder == null ||
        widget.reorderTrigger == NixReorderTrigger.disabled) {
      return null;
    }
    final rawChild = _getRawChild(context, index);
    if (rawChild is NixListItem && !rawChild.canReorder) {
      return null;
    }

    HapticFeedback.mediumImpact();

    // Cache the exact resting tops, heights, and centers of all items BEFORE anything moves
    _restingSlotTops.clear();
    _restingSlotHeights.clear();
    _restingSlotCenters.clear();

    for (int i = 0; i < widget.effectiveItemCount; i++) {
      final top = _measureItemTop(i);
      final height = _measureItemHeight(i);
      _restingSlotTops.add(top);
      _restingSlotHeights.add(height);
      _restingSlotCenters.add(top + (height / 2.0));
    }

    final initialTop = _restingSlotTops[index];
    final height = _restingSlotHeights[index];

    setState(() {
      _draggedIndex = index;
      _hoverTargetIndex = index;
      _dragOffsetY = 0.0;
      _dragOffsetX = 0.0;
      _draggedInitialTop = initialTop;
      _draggedHeight = height;
    });

    return _NixReorderDragSession(
      onUpdate: (details) => _updateDrag(details),
      onEnd: (details) => _finishDrag(details),
      onCancel: () => _cancelDrag(),
    );
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_draggedIndex == null || _settleController.isAnimating) return;

    final newOffsetY = _dragOffsetY + details.delta.dy;
    final newOffsetX = (_dragOffsetX + details.delta.dx * 0.4).clamp(
      -28.0,
      28.0,
    );

    // Current center of the floating dragged card
    final currentDraggedCenter =
        _draggedInitialTop + (_draggedHeight / 2.0) + newOffsetY;

    // Compare against the STATIC, FIXED resting slot centers
    int bestSlot = _draggedIndex!;
    double minDistance = double.infinity;

    for (int i = 0; i < _restingSlotCenters.length; i++) {
      final distance = (currentDraggedCenter - _restingSlotCenters[i]).abs();
      if (distance < minDistance) {
        minDistance = distance;
        bestSlot = i;
      }
    }

    if (bestSlot != _hoverTargetIndex) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _dragOffsetY = newOffsetY;
      _dragOffsetX = newOffsetX;
      _hoverTargetIndex = bestSlot;
    });
  }

  void _finishDrag(DragEndDetails details) {
    _recognizer?.dispose();
    _recognizer = null;
    _recognizerPointer = null;

    if (_draggedIndex == null || _settleController.isAnimating) return;

    final from = _draggedIndex!;
    final to = _hoverTargetIndex ?? from;

    _settleToSlot(from, to);
  }

  void _settleToSlot(int from, int to) {
    double targetTop = _draggedInitialTop;
    if (_restingSlotTops.isNotEmpty &&
        to >= 0 &&
        to < _restingSlotTops.length) {
      targetTop = _restingSlotTops[to];
    }
    final targetOffsetY = targetTop - _draggedInitialTop;

    _settleAnimation = Tween<double>(begin: _dragOffsetY, end: targetOffsetY)
        .animate(
          CurvedAnimation(
            parent: _settleController,
            curve: Curves.easeOutCubic,
          ),
        );

    _settleXAnimation = Tween<double>(begin: _dragOffsetX, end: 0.0).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOutCubic),
    );

    _settleController.forward(from: 0.0).then((_) {
      if (!mounted) return;

      HapticFeedback.lightImpact();

      if (from != to) {
        _justReordered = true;
        widget.onReorder?.call(from, to);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _justReordered = false;
            });
          }
        });
      }

      setState(() {
        _draggedIndex = null;
        _hoverTargetIndex = null;
        _dragOffsetY = 0.0;
        _dragOffsetX = 0.0;
      });
    });
  }

  void _cancelDrag() {
    _recognizer?.dispose();
    _recognizer = null;
    _recognizerPointer = null;

    if (_draggedIndex == null) return;
    _settleToSlot(_draggedIndex!, _draggedIndex!);
  }

  void _cancelPendingReorder() {
    if (_draggedIndex == null) {
      _recognizer?.dispose();
      _recognizer = null;
      _recognizerPointer = null;
    }
  }

  void _handleSwipeUpdate(int index, double offset) {
    if (_activeSwipingIndex != index) {
      setState(() {
        _activeSwipingIndex = index;
      });
    }
  }

  void _handleSwipeEnd(int index) {
    setState(() {
      if (_activeSwipingIndex == index || _activeSwipingIndex != null) {
        _activeSwipingIndex = null;
      }
    });
  }

  void _handleActionOpenChanged(int index, bool isOpen) {
    if (isOpen) {
      if (!_actionOpenIndices.contains(index)) {
        setState(() {
          _actionOpenIndices.add(index);
        });
      }
    } else {
      if (_actionOpenIndices.contains(index)) {
        setState(() {
          _actionOpenIndices.remove(index);
        });
      }
    }
  }

  bool _isChildSelected(int index) {
    if (index < 0 || index >= widget.effectiveItemCount) return false;
    if (_activeSwipingIndex == index || _actionOpenIndices.contains(index)) {
      return false;
    }
    if (widget.selectionMode != NixSelectionMode.none &&
        _internalSelected.contains(index)) {
      return true;
    }
    final raw = _getRawChild(context, index);
    if (raw is NixListItem) {
      return raw.isSelected;
    }
    return false;
  }

  bool _isChildPlaying(int index) {
    if (index < 0 || index >= widget.effectiveItemCount) return false;
    if (_activeSwipingIndex == index || _actionOpenIndices.contains(index)) {
      return false;
    }
    if (widget.playingIndex == index) return true;
    final raw = _getRawChild(context, index);
    if (raw is NixListItem) {
      return raw.isPlaying || raw.isActive;
    }
    return false;
  }

  bool _isDetached(int index) {
    if (index < 0 || index >= widget.effectiveItemCount) return false;
    final isSel = _isChildSelected(index);
    final isPlay = _isChildPlaying(index);
    final isSwipe = _activeSwipingIndex == index;
    return isSel || isPlay || isSwipe;
  }

  Widget _getRawChild(BuildContext context, int index) {
    if (widget.children != null) {
      return widget.children![index];
    }
    return widget.itemBuilder!(context, index);
  }

  Widget _buildScopedChild(BuildContext context, int index) {
    final rawChild = _getRawChild(context, index);
    final itemKey = _getItemKey(index);
    final measurementKey = _measurementKeys.putIfAbsent(
      itemKey,
      () => GlobalKey(),
    );

    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final isSelected = _isChildSelected(index);
    final isPlaying = _isChildPlaying(index);
    final isDragged = _draggedIndex == index;

    // Target slot for drop target
    final targetSlot = _hoverTargetIndex ?? _draggedIndex;

    // Check neighbors detached state for dynamic corner radius morphing & sealing
    final prevDetached = _isDetached(index - 1);
    final nextDetached = _isDetached(index + 1);

    final isCurrentActive = isSelected || isPlaying;

    final prevSameState = isCurrentActive
        ? (_isChildSelected(index - 1) || _isChildPlaying(index - 1))
        : !_isDetached(index - 1);

    final nextSameState = isCurrentActive
        ? (_isChildSelected(index + 1) || _isChildPlaying(index + 1))
        : !_isDetached(index + 1);

    // Calculate slot shift during reorder (Reorder opens slots cleanly)
    double slotShiftFraction = 0.0;
    if (_draggedIndex != null && _hoverTargetIndex != null) {
      final from = _draggedIndex!;
      final to = _hoverTargetIndex!;

      final double currentItemHeight =
          (_restingSlotHeights.isNotEmpty && index < _restingSlotHeights.length)
          ? _restingSlotHeights[index]
          : _measureItemHeight(index);

      final double step = (_draggedHeight + widget.effectiveItemSpacing);
      final double fractionStep = currentItemHeight > 0
          ? (step / currentItemHeight)
          : 1.0;

      if (isDragged) {
        if (_restingSlotTops.length > to && _restingSlotTops.length > from) {
          final double targetPixelShift =
              _restingSlotTops[to] - _restingSlotTops[from];
          slotShiftFraction = currentItemHeight > 0
              ? (targetPixelShift / currentItemHeight)
              : (to - from).toDouble();
        } else {
          slotShiftFraction = (to - from) * fractionStep;
        }
      } else if (from < to && index > from && index <= to) {
        slotShiftFraction = -fractionStep;
      } else if (from > to && index < from && index >= to) {
        slotShiftFraction = fractionStep;
      }
    }

    final isSelectable = widget.selectionMode != NixSelectionMode.none;

    Widget childContent = rawChild;
    if (isDragged) {
      final effectiveDropTargetColor =
          widget.dropTargetColor ??
          (nixTheme.primary ?? colors.primary).withValues(alpha: 0.14);

      final effectiveDropTargetBorder = widget.dropTargetBorder;

      final effectiveDropTargetRadius =
          widget.dropTargetBorderRadius ??
          NixListPhysics.computeSegmentedRadius(
            index: targetSlot ?? index,
            totalCount: widget.effectiveItemCount,
          );

      childContent = AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: _draggedHeight > 0 ? _draggedHeight : 56.0,
        decoration: BoxDecoration(
          color: effectiveDropTargetColor,
          borderRadius: effectiveDropTargetRadius,
          border: effectiveDropTargetBorder,
        ),
      );
    }

    _actionOpenIndices.removeWhere((i) => i >= widget.effectiveItemCount);
    final bool isActionOpenForThisItem =
        _actionOpenIndices.contains(index) || _activeSwipingIndex == index;
    final isSelectMode = widget.selectionMode != NixSelectionMode.none;
    final effectiveTrigger = widget.reorderTrigger;
    final bool itemCanReorder =
        (rawChild is! NixListItem || rawChild.canReorder) &&
        !isActionOpenForThisItem;
    final isReorderDisabled =
        !widget.reorderable ||
        widget.onReorder == null ||
        isSelectMode ||
        effectiveTrigger == NixReorderTrigger.disabled ||
        !itemCanReorder ||
        _actionOpenIndices.isNotEmpty;

    final canReorderHandle =
        !isReorderDisabled &&
        (effectiveTrigger == NixReorderTrigger.handleOnly ||
            effectiveTrigger == NixReorderTrigger.both);
    final canReorderWholeItem =
        !isReorderDisabled &&
        widget.canReorderOnLongPress &&
        (effectiveTrigger == NixReorderTrigger.wholeItem ||
            effectiveTrigger == NixReorderTrigger.both);

    final shouldWrapDelayed =
        widget.reorderable &&
        widget.canReorderOnLongPress &&
        (widget.reorderTrigger == NixReorderTrigger.both ||
            widget.reorderTrigger == NixReorderTrigger.wholeItem);

    Widget itemContent = childContent;
    if (shouldWrapDelayed) {
      itemContent = NixReorderDelayedDragListener(
        index: index,
        enabled: canReorderWholeItem,
        child: itemContent,
      );
    }

    Widget scopedWidget = KeyedSubtree(
      key: measurementKey,
      child: NixListScope(
        index: index,
        totalCount: widget.effectiveItemCount,
        isSelected: isSelected,
        isSelectable: isSelectable,
        isPlaying: isPlaying,
        prevDetached: prevDetached,
        nextDetached: nextDetached,
        prevSameState: prevSameState,
        nextSameState: nextSameState,
        isDragged: isDragged,
        isReordering: _draggedIndex != null,
        startItemDragReorder: canReorderHandle || canReorderWholeItem
            ? _startItemDragReorder
            : null,
        onStartReorder: canReorderHandle
            ? (idx, event) => _startPointerDrag(idx, event, isImmediate: true)
            : null,
        onStartDelayedReorder: canReorderWholeItem
            ? (idx, event) => _startPointerDrag(idx, event, isImmediate: false)
            : null,
        onCancelReorder: _cancelPendingReorder,
        onSwipeUpdate: _handleSwipeUpdate,
        onSwipeEnd: _handleSwipeEnd,
        onItemSelect: _handleItemSelect,
        onActionOpenChanged: _handleActionOpenChanged,
        swipeMode: widget.swipeMode,
        swipeDirection: widget.swipeDirection,
        buildDefaultDragHandles: widget.buildDefaultDragHandles,
        canReorderHandle: canReorderHandle,
        child: itemContent,
      ),
    );

    // Smooth, polished animation during reorder drag; zero duration only on data commit frame
    Widget item = AnimatedSlide(
      offset: Offset(0, slotShiftFraction),
      duration: _justReordered
          ? Duration.zero
          : const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: scopedWidget,
    );

    // Wrap with padding spacing between items
    if (widget.effectiveItemSpacing > 0 && index < widget.effectiveItemCount - 1) {
      item = Padding(
        padding: EdgeInsets.only(bottom: widget.effectiveItemSpacing),
        child: item,
      );
    }

    // Outer KeyedSubtree preserves item state and element identity across reorders
    return KeyedSubtree(key: itemKey, child: item);
  }

  Widget _buildFloatingDraggedCard(BuildContext context) {
    if (_draggedIndex == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rawChild = _getRawChild(context, _draggedIndex!);
    final resolvedPadding = widget.containerPadding.resolve(
      Directionality.maybeOf(context),
    );
    final leftOffset = widget.enableContainer ? resolvedPadding.left : 0.0;
    final rightOffset = widget.enableContainer ? resolvedPadding.right : 0.0;

    return Positioned(
      top: _draggedInitialTop + _dragOffsetY,
      left: leftOffset,
      right: rightOffset,
      child: IgnorePointer(
        child: Transform.scale(
          scale: 1.02,
          child: Transform.translate(
            offset: Offset(_dragOffsetX, 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  NixListPhysics.detachedItemRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.0, 4.0),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.0, 1.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  NixListPhysics.detachedItemRadius,
                ),
                child: NixListScope(
                  index: _draggedIndex!,
                  totalCount: widget.effectiveItemCount,
                  isSelected:
                      widget.selectionMode != NixSelectionMode.none &&
                      _internalSelected.contains(_draggedIndex!),
                  isSelectable: widget.selectionMode != NixSelectionMode.none,
                  isPlaying: widget.playingIndex == _draggedIndex!,
                  prevDetached: true,
                  nextDetached: true,
                  squishTopReach: 0.0,
                  squishBottomReach: 0.0,
                  displacementOffsetY: 0.0,
                  scaleX: 1.0,
                  scaleY: 1.0,
                  swipePullOffsetX: 0.0,
                  swipePullOffsetY: 0.0,
                  swipePullScaleY: 1.0,
                  isDragged: true,
                  isReordering: true,
                  startItemDragReorder: null,
                  onStartReorder: null,
                  onStartDelayedReorder: null,
                  onCancelReorder: null,
                  onSwipeUpdate: null,
                  onSwipeEnd: null,
                  onItemSelect: null,
                  swipeMode: widget.swipeMode,
                  swipeDirection: widget.swipeDirection,
                  buildDefaultDragHandles: false,
                  canReorderHandle: false,
                  child: rawChild,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.effectiveItemCount == 0 && widget.emptyPlaceholder != null) {
      return widget.emptyPlaceholder!;
    }

    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bool isNonScrollable =
        widget.shrinkWrap && widget.physics is NeverScrollableScrollPhysics;

    Widget listView = isNonScrollable
        ? (widget.scrollDirection == Axis.vertical
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List<Widget>.generate(
                    widget.effectiveItemCount,
                    (index) => _buildScopedChild(context, index),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                    widget.effectiveItemCount,
                    (index) => _buildScopedChild(context, index),
                  ),
                ))
        : ListView.builder(
            controller: widget.controller,
            scrollDirection: widget.scrollDirection,
            physics: _draggedIndex != null
                ? const NeverScrollableScrollPhysics()
                : widget.physics,
            padding: EdgeInsets.zero,
            shrinkWrap: widget.shrinkWrap,
            itemCount: widget.effectiveItemCount,
            itemBuilder: _buildScopedChild,
          );

    // Outer segmented container
    Widget listContent = listView;
    if (widget.enableContainer) {
      final effectiveContainerColor =
          widget.containerColor ??
          (nixTheme.surfaceContainer ?? colors.surfaceContainer);

      final bool shouldClip =
          widget.enableInnerClipping && widget.clipBehavior != Clip.none;

      final effectiveInnerClipRadius = widget.innerClipBorderRadius ??
          BorderRadius.all(
            Radius.circular(
              math.max(0.0, widget.containerBorderRadius.topLeft.x - 2.5),
            ),
          );

      final Widget innerContent = shouldClip
          ? ClipRRect(
              clipBehavior: widget.clipBehavior,
              borderRadius: effectiveInnerClipRadius,
              child: listView,
            )
          : listView;

      listContent = Container(
        padding: widget.containerPadding,
        decoration: BoxDecoration(
          color: effectiveContainerColor,
          borderRadius: widget.containerBorderRadius,
          border: widget.containerBorder,
        ),
        child: innerContent,
      );
    }

    // Wrap in Stack to render floating dragged card on top layer OUTSIDE container's ClipRRect
    // so shadows, elevation and scale are never clipped!
    listContent = Stack(
      key: _listContainerKey,
      clipBehavior: Clip.none,
      children: [
        listContent,
        if (_draggedIndex != null) _buildFloatingDraggedCard(context),
      ],
    );

    // Apply outer list padding
    if (widget.padding != EdgeInsets.zero) {
      listContent = Padding(padding: widget.padding, child: listContent);
    }

    return listContent;
  }
}

/// Drag session handling updates and finishes for [NixListView] reordering.
class _NixReorderDragSession extends Drag {
  _NixReorderDragSession({
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
  });

  final void Function(DragUpdateDetails details) onUpdate;
  final void Function(DragEndDetails details) onEnd;
  final VoidCallback onCancel;

  @override
  void update(DragUpdateDetails details) {
    onUpdate(details);
  }

  @override
  void end(DragEndDetails details) {
    onEnd(details);
  }

  @override
  void cancel() {
    onCancel();
  }
}
