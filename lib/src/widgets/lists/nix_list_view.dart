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
  final Map<int, GlobalKey> _itemKeys = {};

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

  // Swipe reactive neighbor state
  int? _activeSwipingIndex;
  double _activeSwipeOffset = 0.0;

  // Internal selection state if not controlled externally
  late Set<int> _internalSelected;

  @override
  void initState() {
    super.initState();
    _internalSelected = widget.selectedIndices != null
        ? Set<int>.from(widget.selectedIndices!)
        : <int>{};

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
    // Clean up cached item keys whenever list count or items change to prevent stale measurements
    if (widget.effectiveItemCount != oldWidget.effectiveItemCount) {
      _itemKeys.clear();
      _activeSwipingIndex = null;
      _activeSwipeOffset = 0.0;
    }
  }

  @override
  void dispose() {
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

  Drag? _handleDragStart(Offset startPosition) {
    if (_pendingDragIndex == null ||
        _pendingDragIndex! < 0 ||
        _pendingDragIndex! >= widget.effectiveItemCount) {
      return null;
    }

    final index = _pendingDragIndex!;
    HapticFeedback.mediumImpact();

    // Measure exact initial top offset and height
    final initialTop = _getItemTop(index);
    final height = _getItemHeight(index);

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
    if (_draggedIndex == null) return;

    setState(() {
      _dragOffsetY += details.delta.dy;
      _dragOffsetX = (_dragOffsetX + details.delta.dx * 0.4).clamp(-28.0, 28.0);

      // Dynamically detect hover slot
      final currentDraggedCenter =
          _draggedInitialTop + (_draggedHeight / 2.0) + _dragOffsetY;

      int bestSlot = _draggedIndex!;
      double minDistance = double.infinity;

      for (int i = 0; i < widget.effectiveItemCount; i++) {
        final itemCenter = _getItemCenterY(i);
        final distance = (currentDraggedCenter - itemCenter).abs();
        if (distance < minDistance) {
          minDistance = distance;
          bestSlot = i;
        }
      }

      if (bestSlot != _hoverTargetIndex) {
        _hoverTargetIndex = bestSlot;
        HapticFeedback.selectionClick();
      }
    });
  }

  void _finishDrag(DragEndDetails details) {
    if (_draggedIndex == null) return;

    final from = _draggedIndex!;
    final to = _hoverTargetIndex ?? from;

    HapticFeedback.lightImpact();

    setState(() {
      _draggedIndex = null;
      _hoverTargetIndex = null;
      _pendingDragIndex = null;
      _dragOffsetY = 0.0;
      _dragOffsetX = 0.0;
      _itemKeys.clear();
    });

    if (from != to) {
      widget.onReorder?.call(from, to);
    }
  }

  void _cancelDrag() {
    if (_draggedIndex == null) return;
    setState(() {
      _draggedIndex = null;
      _hoverTargetIndex = null;
      _pendingDragIndex = null;
      _dragOffsetY = 0.0;
      _dragOffsetX = 0.0;
      _itemKeys.clear();
    });
  }

  void _cancelPendingReorder() {
    _pendingDragIndex = null;
    if (_draggedIndex == null) {
      _resetDelayedRecognizer();
    }
  }

  double _getItemTop(int index) {
    final ctx = _itemKeys[index]?.currentContext;
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

  double _getItemHeight(int index) {
    final ctx = _itemKeys[index]?.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        return box.size.height;
      }
    }
    return 56.0;
  }

  double _getItemCenterY(int index) {
    return _getItemTop(index) + (_getItemHeight(index) / 2.0);
  }

  void _handleSwipeUpdate(int index, double offset) {
    if (!widget.enableNeighbourSquish) return;
    setState(() {
      _activeSwipingIndex = index;
      _activeSwipeOffset = offset;
    });
  }

  void _handleSwipeEnd(int index) {
    if (!widget.enableNeighbourSquish) return;
    if (_activeSwipingIndex == index) {
      setState(() {
        _activeSwipingIndex = null;
        _activeSwipeOffset = 0.0;
      });
    }
  }

  bool _isDetached(int index) {
    if (index < 0 || index >= widget.effectiveItemCount) return false;
    final isSel = _internalSelected.contains(index);
    final isPlay = widget.playingIndex == index;
    final isDrag = _draggedIndex == index;
    return isSel || isPlay || isDrag;
  }

  Widget _getRawChild(BuildContext context, int index) {
    if (widget.children != null) {
      return widget.children![index];
    }
    return widget.itemBuilder!(context, index);
  }

  Widget _buildScopedChild(BuildContext context, int index) {
    final rawChild = _getRawChild(context, index);

    final isSelected = _internalSelected.contains(index);
    final isPlaying = widget.playingIndex == index;
    final isDragged = _draggedIndex == index;

    // Check neighbors detached state for dynamic corner radius sealing
    final prevDetached = _isDetached(index - 1);
    final nextDetached = _isDetached(index + 1);

    // Dynamic Swipe Pull on immediate neighbors
    double swipePullX = 0.0;
    double swipePullY = 0.0;
    double swipePullScaleY = 1.0;

    // Neighbour Squish Physics & Reach variables (active on SWIPE only)
    double squishTopReach = 0.0;
    double squishBottomReach = 0.0;
    double displacementOffsetY = 0.0;
    double scaleX = 1.0;
    double scaleY = 1.0;

    // Calculate slot shift during reorder (Reorder opens slots cleanly, no squishing)
    double slotShiftFraction = 0.0;
    if (_draggedIndex != null && _hoverTargetIndex != null && !isDragged) {
      final from = _draggedIndex!;
      final to = _hoverTargetIndex!;

      if (from < to && index > from && index <= to) {
        slotShiftFraction = -1.0;
      } else if (from > to && index < from && index >= to) {
        slotShiftFraction = 1.0;
      }
    }

    // Neighbour Squish Physics, Spring Displacement, Pull Offset & Reach (SWIPE ONLY)
    if (widget.enableNeighbourSquish &&
        _activeSwipingIndex != null &&
        _activeSwipeOffset != 0.0) {
      final swipingIdx = _activeSwipingIndex!;
      final offset = _activeSwipeOffset;

      if (index == swipingIdx - 1) {
        // Neighbor above the swiped card
        final reach = NixListPhysics.computeReachFactor(
          swipeOffset: offset,
          threshold: 110.0,
        );
        final squish = NixListPhysics.computeSquishScale(
          reachFactor: reach,
        );
        scaleX = squish.scaleX;
        scaleY = squish.scaleY;
        displacementOffsetY = NixListPhysics.computeDisplacementOffset(
          reachFactor: reach,
          isDraggedAbove: false,
          maxDisplacement: 6.0,
        );
        squishBottomReach = reach;

        final pull = NixListPhysics.computeSwipeNeighborPull(
          swipeOffset: offset,
          itemWidth: 300.0,
          isNeighborAbove: true,
        );
        swipePullX = pull.offsetX;
        swipePullY = pull.offsetY;
        swipePullScaleY = pull.scaleY;
      } else if (index == swipingIdx + 1) {
        // Neighbor below the swiped card
        final reach = NixListPhysics.computeReachFactor(
          swipeOffset: offset,
          threshold: 110.0,
        );
        final squish = NixListPhysics.computeSquishScale(
          reachFactor: reach,
        );
        scaleX = squish.scaleX;
        scaleY = squish.scaleY;
        displacementOffsetY = NixListPhysics.computeDisplacementOffset(
          reachFactor: reach,
          isDraggedAbove: true,
          maxDisplacement: 6.0,
        );
        squishTopReach = reach;

        final pull = NixListPhysics.computeSwipeNeighborPull(
          swipeOffset: offset,
          itemWidth: 300.0,
          isNeighborAbove: false,
        );
        swipePullX = pull.offsetX;
        swipePullY = pull.offsetY;
        swipePullScaleY = pull.scaleY;
      }
    }

    final key = _itemKeys.putIfAbsent(index, () => GlobalKey());
    final isSelectable = widget.selectionMode != NixSelectionMode.none;

    Widget scopedWidget = KeyedSubtree(
      key: key,
      child: NixListScope(
        index: index,
        totalCount: widget.effectiveItemCount,
        isSelected: isSelected,
        isSelectable: isSelectable,
        isPlaying: isPlaying,
        prevDetached: prevDetached,
        nextDetached: nextDetached,
        squishTopReach: squishTopReach,
        squishBottomReach: squishBottomReach,
        displacementOffsetY: displacementOffsetY,
        scaleX: scaleX,
        scaleY: scaleY,
        swipePullOffsetX: swipePullX,
        swipePullOffsetY: swipePullY,
        swipePullScaleY: swipePullScaleY,
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
      duration: const Duration(milliseconds: 240),
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

    return item;
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
