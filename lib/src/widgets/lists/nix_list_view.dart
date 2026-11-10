import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';
import 'nix_list_item.dart';
import 'nix_list_physics.dart';

/// Selection mode for [NixListView].
enum NixSelectionMode {
  /// Selection is disabled.
  none,

  /// At most one item can be selected at a time.
  single,

  /// Multiple items can be selected concurrently.
  multi,
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
    this.enableContainer = true,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.itemSpacing = 2.0,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
  })  : itemCount = null,
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
    this.enableContainer = true,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.itemSpacing = 2.0,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
  })  : children = null,
        separatorBuilder = null;

  /// Creates a separated [NixListView] using an [itemBuilder] and [separatorBuilder].
  const NixListView.separated({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    required Widget Function(BuildContext context, int index) this.separatorBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding = const EdgeInsets.all(16.0),
    this.shrinkWrap = false,
    this.onReorder,
    this.reorderable = false,
    this.canReorderOnLongPress = true,
    this.enableContainer = true,
    this.containerColor,
    this.containerBorderRadius = const BorderRadius.all(
      Radius.circular(NixListPhysics.containerRadius),
    ),
    this.containerBorder,
    this.containerPadding = const EdgeInsets.all(4.0),
    this.itemSpacing = 2.0,
    this.enableNeighbourSquish = true,
    this.selectionMode = NixSelectionMode.none,
    this.selectedIndices,
    this.onSelectionChanged,
    this.playingIndex,
    this.emptyPlaceholder,
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

  /// Spacing between adjacent list items. Defaults to 2px.
  final double itemSpacing;

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
  bool _justReordered = false;

  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;
  Animation<double>? _settleXAnimation;

  // Reorder Gestures
  late final ImmediateMultiDragGestureRecognizer _immediateRecognizer;
  DelayedMultiDragGestureRecognizer? _delayedRecognizer;

  // Active Drag State
  int? _pendingDragIndex;
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

  @override
  void initState() {
    super.initState();
    _internalSelected = widget.selectedIndices != null
        ? Set<int>.from(widget.selectedIndices!)
        : <int>{};

    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
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

    _immediateRecognizer = ImmediateMultiDragGestureRecognizer()
      ..onStart = _handleDragStart;

    _resetDelayedRecognizer();
  }

  void _resetDelayedRecognizer() {
    _delayedRecognizer?.dispose();
    _delayedRecognizer = DelayedMultiDragGestureRecognizer(
      delay: const Duration(milliseconds: 220),
    )..onStart = _handleDragStart;
  }

  @override
  void didUpdateWidget(covariant NixListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndices != null) {
      _internalSelected = Set<int>.from(widget.selectedIndices!);
    }
    if (widget.effectiveItemCount != oldWidget.effectiveItemCount) {
      _activeSwipingIndex = null;
    }
  }

  @override
  void dispose() {
    _settleController.dispose();
    _immediateRecognizer.dispose();
    _delayedRecognizer?.dispose();
    super.dispose();
  }

  void _handleItemSelect(int index, bool selected) {
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

  void _startPointerDrag(
    int index,
    PointerDownEvent event, {
    required bool isImmediate,
  }) {
    if (!widget.reorderable || widget.onReorder == null) return;
    _pendingDragIndex = index;
    if (isImmediate) {
      _immediateRecognizer.addPointer(event);
    } else {
      _delayedRecognizer?.addPointer(event);
    }
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
    return index * (defaultHeight + widget.itemSpacing);
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

  Drag? _handleDragStart(Offset startPosition) {
    if (_pendingDragIndex == null ||
        _pendingDragIndex! < 0 ||
        _pendingDragIndex! >= widget.effectiveItemCount ||
        _settleController.isAnimating) {
      return null;
    }

    final index = _pendingDragIndex!;
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
    final newOffsetX =
        (_dragOffsetX + details.delta.dx * 0.4).clamp(-28.0, 28.0);

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

    _settleAnimation = Tween<double>(
      begin: _dragOffsetY,
      end: targetOffsetY,
    ).animate(CurvedAnimation(
      parent: _settleController,
      curve: Curves.easeOutCubic,
    ));

    _settleXAnimation = Tween<double>(
      begin: _dragOffsetX,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _settleController,
      curve: Curves.easeOutCubic,
    ));

    _settleController.forward(from: 0.0).then((_) {
      if (!mounted) return;

      HapticFeedback.lightImpact();

      if (from != to) {
        _justReordered = true;
        widget.onReorder?.call(from, to);
      }

      setState(() {
        _draggedIndex = null;
        _hoverTargetIndex = null;
        _pendingDragIndex = null;
        _dragOffsetY = 0.0;
        _dragOffsetX = 0.0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _justReordered = false;
          });
        }
      });
    });
  }

  void _cancelDrag() {
    if (_draggedIndex == null) return;
    _settleToSlot(_draggedIndex!, _draggedIndex!);
  }

  void _cancelPendingReorder() {
    _pendingDragIndex = null;
    if (_draggedIndex == null) {
      _resetDelayedRecognizer();
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
    if (_activeSwipingIndex == index) {
      setState(() {
        _activeSwipingIndex = null;
      });
    }
  }

  bool _isDetached(int index) {
    if (index < 0 || index >= widget.effectiveItemCount) return false;
    final isSel = _internalSelected.contains(index);
    final isPlay = widget.playingIndex == index;
    final isDrag = _draggedIndex == index;
    final isSwipe = _activeSwipingIndex == index;
    return isSel || isPlay || isDrag || isSwipe;
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
    final measurementKey =
        _measurementKeys.putIfAbsent(itemKey, () => GlobalKey());

    final isSelected = _internalSelected.contains(index);
    final isPlaying = widget.playingIndex == index;
    final isDragged = _draggedIndex == index;

    // Check neighbors detached state for dynamic corner radius morphing & sealing
    final prevDetached = _isDetached(index - 1);
    final nextDetached = _isDetached(index + 1);

    // Calculate slot shift during reorder (Reorder opens slots cleanly)
    double slotShiftFraction = 0.0;
    if (_draggedIndex != null && _hoverTargetIndex != null && !isDragged) {
      final from = _draggedIndex!;
      final to = _hoverTargetIndex!;

      final double currentItemHeight =
          (_restingSlotHeights.isNotEmpty && index < _restingSlotHeights.length)
              ? _restingSlotHeights[index]
              : _measureItemHeight(index);

      final double step = (_draggedHeight + widget.itemSpacing);
      final double fractionStep =
          currentItemHeight > 0 ? (step / currentItemHeight) : 1.0;

      if (from < to && index > from && index <= to) {
        slotShiftFraction = -fractionStep;
      } else if (from > to && index < from && index >= to) {
        slotShiftFraction = fractionStep;
      }
    }

    final isSelectable = widget.selectionMode != NixSelectionMode.none;

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
        isDragged: isDragged,
        isReordering: _draggedIndex != null,
        onStartReorder: (idx, event) =>
            _startPointerDrag(idx, event, isImmediate: true),
        onCancelReorder: _cancelPendingReorder,
        onSwipeUpdate: _handleSwipeUpdate,
        onSwipeEnd: _handleSwipeEnd,
        onItemSelect: _handleItemSelect,
        child: isDragged
            // When dragged, maintain footprint without instantiating duplicate child element tree
            ? SizedBox(
                width: double.infinity,
                height: _draggedHeight,
              )
            : rawChild,
      ),
    );

    // If reordering via long-press is enabled
    if (widget.reorderable && widget.canReorderOnLongPress) {
      scopedWidget = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) =>
            _startPointerDrag(index, event, isImmediate: false),
        child: scopedWidget,
      );
    }

    // Wrap in animated slide for smooth slot opening
    Widget item = AnimatedSlide(
      offset: Offset(0, slotShiftFraction),
      duration: _justReordered
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: scopedWidget,
    );

    // Wrap with padding spacing between items
    if (widget.itemSpacing > 0 && index < widget.effectiveItemCount - 1) {
      item = Padding(
        padding: EdgeInsets.only(bottom: widget.itemSpacing),
        child: item,
      );
    }

    // Outer KeyedSubtree preserves item state and element identity across reorders
    return KeyedSubtree(
      key: itemKey,
      child: item,
    );
  }

  Widget _buildFloatingDraggedCard(BuildContext context) {
    if (_draggedIndex == null) return const SizedBox.shrink();

    final rawChild = _getRawChild(context, _draggedIndex!);
    final containerPad = widget.containerPadding.horizontal / 2.0;

    return Positioned(
      top: _draggedInitialTop + _dragOffsetY,
      left: containerPad,
      right: containerPad,
      child: IgnorePointer(
        child: Transform.scale(
          scale: 1.04,
          child: Transform.translate(
            offset: Offset(_dragOffsetX, 0.0),
            child: Material(
              type: MaterialType.transparency,
              elevation: 12.0,
              shadowColor: Colors.black45,
              borderRadius: BorderRadius.circular(
                NixListPhysics.detachedItemRadius,
              ),
              child: NixListScope(
                index: _draggedIndex!,
                totalCount: widget.effectiveItemCount,
                isSelected: _internalSelected.contains(_draggedIndex!),
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
                onStartReorder: null,
                onCancelReorder: null,
                onSwipeUpdate: null,
                onSwipeEnd: null,
                onItemSelect: null,
                child: rawChild,
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

    Widget listView = ListView.builder(
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

    // Wrap in Stack to render floating dragged card on top layer
    Widget listContent = Stack(
      key: _listContainerKey,
      clipBehavior: Clip.none,
      children: [
        listView,
        if (_draggedIndex != null) _buildFloatingDraggedCard(context),
      ],
    );

    // Outer segmented container
    if (widget.enableContainer) {
      final effectiveContainerColor = widget.containerColor ??
          (nixTheme.surfaceContainer ?? colors.surfaceContainer);

      listContent = Container(
        padding: widget.containerPadding,
        decoration: BoxDecoration(
          color: effectiveContainerColor,
          borderRadius: widget.containerBorderRadius,
          border: widget.containerBorder,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(
              math.max(0.0, widget.containerBorderRadius.topLeft.x - 2.0),
            ),
          ),
          child: listContent,
        ),
      );
    }

    // Apply outer list padding
    if (widget.padding != EdgeInsets.zero) {
      listContent = Padding(
        padding: widget.padding,
        child: listContent,
      );
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
