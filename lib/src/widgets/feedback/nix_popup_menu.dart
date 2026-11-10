import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';

/// Position placement strategy for [NixPopupMenu] relative to its target widget.
enum NixPopupPosition {
  /// Automatically places the menu below or above depending on available screen space.
  auto,

  /// Forces the menu to appear below the target widget.
  below,

  /// Forces the menu to appear above the target widget.
  above,
}

/// An individual menu item entry for [NixPopupMenu].
class NixPopupMenuItem<T> {
  /// Creates a standard [NixPopupMenuItem].
  const NixPopupMenuItem({
    required this.value,
    this.label,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.isDestructive = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.height = 42.0,
    this.customChild,
  });

  /// Creates a destructive/danger [NixPopupMenuItem] styled with error theme colors.
  const NixPopupMenuItem.destructive({
    required this.value,
    this.label,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.height = 42.0,
    this.customChild,
  }) : isDestructive = true;

  /// The value returned when this item is selected.
  final T value;

  /// The primary label widget (typically [Text]).
  final Widget? label;

  /// Leading icon or widget.
  final Widget? icon;

  /// Trailing accessory widget (e.g. keyboard shortcut or chevron).
  final Widget? trailing;

  /// Whether this item can be selected.
  final bool enabled;

  /// Whether this item performs a destructive action (styles in error/red).
  final bool isDestructive;

  /// Optional callback invoked when this item is selected.
  final VoidCallback? onTap;

  /// Internal padding for the item content.
  final EdgeInsetsGeometry padding;

  /// Minimum height for the item.
  final double height;

  /// Fully custom child widget overriding default label/icon/trailing layout.
  final Widget? customChild;
}

/// A pill-first custom popup menu that wraps any widget, featuring:
/// 1. Dual Gesture Support:
///    - Tap: Opens the menu; tapping any item selects it.
///    - Hold, Drag & Release: Press & hold to reveal the menu, drag across items to highlight,
///      and release finger over an item to select it instantly.
/// 2. Dynamic Segmented Corner Radius:
///    - Container: 16px border radius, 4px padding, 2px vertical gap between items.
///    - Items:
///      - 1 item: 12px on all corners.
///      - First item: 12px top corners, 6px bottom corners.
///      - Middle items: 6px on all neighboring corners.
///      - Last item: 6px top corners, 12px bottom corners.
class NixPopupMenu<T> extends StatefulWidget {
  const NixPopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
    this.onCanceled,
    this.enabled = true,
    this.holdDelay = const Duration(milliseconds: 250),
    this.position = NixPopupPosition.auto,
    this.offset = const Offset(0, 4),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.all(4.0),
    this.gap = 2.0,
    this.minWidth,
    this.maxWidth,
    this.barrierColor = Colors.transparent,
    this.barrierDismissible = true,
    this.enableHaptics = true,
    this.tooltip,
  });

  /// The target widget that triggers this popup menu.
  final Widget child;

  /// The list of items to display.
  final List<NixPopupMenuItem<T>> items;

  /// Callback fired when an item is chosen.
  final ValueChanged<T>? onSelected;

  /// Callback fired when the popup menu is dismissed without choosing an item.
  final VoidCallback? onCanceled;

  /// Whether gestures trigger the popup menu.
  final bool enabled;

  /// The duration of holding the trigger before the menu reveals in drag mode.
  final Duration holdDelay;

  /// Position placement strategy relative to the trigger.
  final NixPopupPosition position;

  /// Offset from the trigger widget.
  final Offset offset;

  /// Background color override for the menu container.
  final Color? backgroundColor;

  /// Border color override for the menu container. By default, no border is rendered.
  final Color? borderColor;

  /// Container border radius. Defaults to 16px as per design rule.
  final BorderRadius borderRadius;

  /// Container internal padding. Defaults to 4px as per design rule.
  final EdgeInsets padding;

  /// Vertical gap between items. Defaults to 2px as per design rule.
  final double gap;

  /// Minimum width constraint. Defaults to 200.0 if not specified.
  final double? minWidth;

  /// Maximum width constraint.
  ///
  /// Defaults to 200.0.
  /// - If the content text is longer than 200.0 and does not specify [TextOverflow.ellipsis],
  ///   the menu dynamically adapts its width to fit the text content.
  /// - If any item specifies [TextOverflow.ellipsis] (or fade), the default 200.0 maxWidth
  ///   is used and the text truncates with an ellipsis.
  /// - If set manually, the specified maxWidth is strictly respected.
  final double? maxWidth;

  /// Scrim/barrier color behind the popup.
  final Color barrierColor;

  /// Whether tapping outside the popup dismisses it.
  final bool barrierDismissible;

  /// Whether subtle haptic feedback is triggered on hold open and item hovering.
  final bool enableHaptics;

  /// Optional tooltip on the child.
  final String? tooltip;

  /// Computes the dynamic segmented corner radius according to item position and total item count.
  ///
  /// - If only 1 item exists: all corners are 12px.
  /// - If multiple items:
  ///   - First item (index 0): 12px top corners, 6px bottom corners.
  ///   - Last item (index count - 1): 6px top corners, 12px bottom corners.
  ///   - Neighboring inner items: 6px on all corners.
  static BorderRadius computeItemRadius(int index, int totalCount) {
    if (totalCount <= 1) {
      return const BorderRadius.all(Radius.circular(12.0));
    }
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
        bottomLeft: Radius.circular(6.0),
        bottomRight: Radius.circular(6.0),
      );
    }
    if (index == totalCount - 1) {
      return const BorderRadius.only(
        topLeft: Radius.circular(6.0),
        topRight: Radius.circular(6.0),
        bottomLeft: Radius.circular(12.0),
        bottomRight: Radius.circular(12.0),
      );
    }
    return const BorderRadius.all(Radius.circular(6.0));
  }

  @override
  State<NixPopupMenu<T>> createState() => _NixPopupMenuState<T>();
}

class _NixPopupMenuState<T> extends State<NixPopupMenu<T>> {
  _NixPopupMenuOverlayController<T>? _activeOverlayController;
  Offset? _pointerDownPosition;

  void _handlePointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    if (_activeOverlayController != null) {
      _activeOverlayController?.dismiss(null);
      _activeOverlayController = null;
    }
  }

  void _handleTap() {
    if (!widget.enabled || widget.items.isEmpty) return;
    _openMenu(initialPointerPosition: null, isDragSession: false);
  }

  void _handleHoldTriggered() {
    if (!widget.enabled || widget.items.isEmpty) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _openMenu(initialPointerPosition: null, isDragSession: true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _activeOverlayController?.updatePointer(event.position);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final triggerRect = _getTriggerRect();
    _activeOverlayController?.handleDragRelease(event.position, triggerRect);
  }

  void _handlePointerCancel() {
    _activeOverlayController?.dismiss(null);
  }

  Rect _getTriggerRect() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }
    return Rect.fromLTWH(
      _pointerDownPosition?.dx ?? 0,
      _pointerDownPosition?.dy ?? 0,
      1,
      1,
    );
  }

  void _openMenu({required Offset? initialPointerPosition, required bool isDragSession}) {
    if (!mounted || widget.items.isEmpty) return;

    final triggerRect = _getTriggerRect();
    final overlayState = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

    late final OverlayEntry overlayEntry;

    final controller = _NixPopupMenuOverlayController<T>(
      onDismissed: () {
        if (_activeOverlayController?.entry == overlayEntry) {
          _activeOverlayController = null;
        }
      },
    );

    overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _NixPopupMenuOverlay<T>(
          controller: controller,
          overlayEntry: overlayEntry,
          triggerRect: triggerRect,
          items: widget.items,
          initialPointerPosition: initialPointerPosition,
          isDragSession: isDragSession,
          position: widget.position,
          offset: widget.offset,
          backgroundColor: widget.backgroundColor,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          gap: widget.gap,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          barrierColor: widget.barrierColor,
          barrierDismissible: widget.barrierDismissible,
          enableHaptics: widget.enableHaptics,
          onSelected: (val) {
            widget.onSelected?.call(val);
          },
          onCanceled: widget.onCanceled,
        );
      },
    );

    controller.entry = overlayEntry;
    _activeOverlayController = controller;
    overlayState.insert(overlayEntry);
  }

  @override
  void dispose() {
    _activeOverlayController?.dismiss(null);
    _activeOverlayController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (!widget.enabled || widget.items.isEmpty) {
      result = widget.child;
    } else {
      result = RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          _NixPopupMenuGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<_NixPopupMenuGestureRecognizer>(
            () => _NixPopupMenuGestureRecognizer(
              onTap: _handleTap,
              onHoldTriggered: _handleHoldTriggered,
              onPointerMoveCallback: _handlePointerMove,
              onPointerUpCallback: _handlePointerUp,
              onPointerCancelCallback: _handlePointerCancel,
              onPointerDownCallback: _handlePointerDown,
              holdDelay: widget.holdDelay,
            ),
            (_NixPopupMenuGestureRecognizer instance) {
              instance
                ..onTap = _handleTap
                ..onHoldTriggered = _handleHoldTriggered
                ..onPointerMoveCallback = _handlePointerMove
                ..onPointerUpCallback = _handlePointerUp
                ..onPointerCancelCallback = _handlePointerCancel
                ..onPointerDownCallback = _handlePointerDown
                ..holdDelay = widget.holdDelay;
            },
          ),
        },
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      );
    }

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }

    return result;
  }
}

/// Custom gesture recognizer for [NixPopupMenu] that resolves into the Flutter gesture arena.
///
/// When holding for [holdDelay], this recognizer resolves to [GestureDisposition.accepted],
/// winning the arena and rejecting competing recognizers such as [VerticalDragGestureRecognizer]
/// from any parent [Scrollable] / [ListView]. This completely prevents parent body scroll from
/// triggering when press-holding the popup button.
class _NixPopupMenuGestureRecognizer extends OneSequenceGestureRecognizer {
  _NixPopupMenuGestureRecognizer({
    required this.onTap,
    required this.onHoldTriggered,
    required this.onPointerMoveCallback,
    required this.onPointerUpCallback,
    required this.onPointerCancelCallback,
    required this.onPointerDownCallback,
    required this.holdDelay,
  });

  VoidCallback onTap;
  VoidCallback onHoldTriggered;
  ValueChanged<PointerMoveEvent> onPointerMoveCallback;
  ValueChanged<PointerUpEvent> onPointerUpCallback;
  VoidCallback onPointerCancelCallback;
  ValueChanged<PointerDownEvent> onPointerDownCallback;
  Duration holdDelay;

  Timer? _holdTimer;
  int? _primaryPointer;
  Offset? _downPosition;
  bool _isHoldActive = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_primaryPointer != null) return;
    _primaryPointer = event.pointer;
    _downPosition = event.position;
    _isHoldActive = false;

    onPointerDownCallback(event);

    startTrackingPointer(event.pointer, event.transform);

    _holdTimer?.cancel();
    _holdTimer = Timer(holdDelay, _onHoldTimeout);
  }

  void _onHoldTimeout() {
    if (_primaryPointer == null) return;
    _isHoldActive = true;

    // Win the gesture arena to cancel parent Scrollable / ListView vertical drag recognizers!
    resolve(GestureDisposition.accepted);

    onHoldTriggered();
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _primaryPointer) return;

    if (event is PointerMoveEvent) {
      if (!_isHoldActive) {
        final distance = (event.position - (_downPosition ?? event.position)).distance;
        if (distance > kTouchSlop) {
          _holdTimer?.cancel();
          _holdTimer = null;
          resolve(GestureDisposition.rejected);
          stopTrackingPointer(event.pointer);
          _primaryPointer = null;
          return;
        }
      } else {
        onPointerMoveCallback(event);
      }
    } else if (event is PointerUpEvent) {
      _holdTimer?.cancel();
      _holdTimer = null;

      if (_isHoldActive) {
        onPointerUpCallback(event);
      } else {
        final distance = (event.position - (_downPosition ?? event.position)).distance;
        if (distance <= kTouchSlop) {
          resolve(GestureDisposition.accepted);
          onTap();
        } else {
          resolve(GestureDisposition.rejected);
        }
      }
      stopTrackingPointer(event.pointer);
      _primaryPointer = null;
      _isHoldActive = false;
    } else if (event is PointerCancelEvent) {
      _holdTimer?.cancel();
      _holdTimer = null;
      if (_isHoldActive) {
        onPointerCancelCallback();
      }
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
      _primaryPointer = null;
      _isHoldActive = false;
    }
  }

  @override
  void rejectGesture(int pointer) {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_isHoldActive) {
      onPointerCancelCallback();
    }
    _primaryPointer = null;
    _isHoldActive = false;
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _holdTimer?.cancel();
    _holdTimer = null;
    _primaryPointer = null;
    _isHoldActive = false;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _holdTimer = null;
    super.dispose();
  }

  @override
  String get debugDescription => 'NixPopupMenuGestureRecognizer';
}

/// Controller used by the trigger widget and imperative helpers to coordinate with the overlay.
class _NixPopupMenuOverlayController<T> {
  _NixPopupMenuOverlayController({required this.onDismissed});

  final VoidCallback onDismissed;
  OverlayEntry? entry;
  _NixPopupMenuOverlayState<T>? _state;

  void attach(_NixPopupMenuOverlayState<T> state) {
    _state = state;
  }

  void updatePointer(Offset position) {
    _state?.updatePointerPosition(position);
  }

  void handleDragRelease(Offset position, Rect triggerRect) {
    _state?.handleDragRelease(position, triggerRect);
  }

  void dismiss(T? result) {
    _state?.dismiss(result);
  }
}

/// The stateful overlay widget that renders the popup menu and handles animations and hit testing.
class _NixPopupMenuOverlay<T> extends StatefulWidget {
  const _NixPopupMenuOverlay({
    required this.controller,
    required this.overlayEntry,
    required this.triggerRect,
    required this.items,
    required this.initialPointerPosition,
    required this.isDragSession,
    required this.position,
    required this.offset,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.padding,
    required this.gap,
    this.minWidth,
    this.maxWidth,
    required this.barrierColor,
    required this.barrierDismissible,
    required this.enableHaptics,
    required this.onSelected,
    required this.onCanceled,
  });

  final _NixPopupMenuOverlayController<T> controller;
  final OverlayEntry overlayEntry;
  final Rect triggerRect;
  final List<NixPopupMenuItem<T>> items;
  final Offset? initialPointerPosition;
  final bool isDragSession;
  final NixPopupPosition position;
  final Offset offset;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double gap;
  final double? minWidth;
  final double? maxWidth;
  final Color barrierColor;
  final bool barrierDismissible;
  final bool enableHaptics;
  final ValueChanged<T> onSelected;
  final VoidCallback? onCanceled;

  @override
  State<_NixPopupMenuOverlay<T>> createState() => _NixPopupMenuOverlayState<T>();
}

class _NixPopupMenuOverlayState<T> extends State<_NixPopupMenuOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final List<GlobalKey> _itemKeys;
  int? _highlightedIndex;
  late bool _isDragSession;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(this);
    _isDragSession = widget.isDragSession;
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _animController.forward();

    if (widget.initialPointerPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isDragSession) {
          updatePointerPosition(widget.initialPointerPosition!);
        }
      });
    }
  }

  void updatePointerPosition(Offset globalPosition) {
    if (!mounted || _isClosing) return;

    int? foundIndex;
    for (int i = 0; i < widget.items.length; i++) {
      final key = _itemKeys[i];
      final itemContext = key.currentContext;
      if (itemContext != null) {
        final renderBox = itemContext.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize && renderBox.attached) {
          final localPos = renderBox.globalToLocal(globalPosition);
          // Expand vertical bounds slightly across the 2px gap for seamless dragging
          final hitRect = Rect.fromLTWH(
            0.0,
            -widget.gap / 2.0,
            renderBox.size.width,
            renderBox.size.height + widget.gap,
          );
          if (hitRect.contains(localPos)) {
            foundIndex = i;
            break;
          }
        }
      }
    }

    if (foundIndex != _highlightedIndex) {
      setState(() {
        _highlightedIndex = foundIndex;
      });
      if (foundIndex != null &&
          widget.items[foundIndex].enabled &&
          widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void handleDragRelease(Offset releasePosition, Rect triggerRect) {
    if (!mounted || _isClosing) return;

    if (_highlightedIndex != null) {
      final selectedItem = widget.items[_highlightedIndex!];
      if (selectedItem.enabled) {
        _selectItem(selectedItem);
        return;
      }
    }

    // If released on or near the trigger widget itself without dragging to an item,
    // remain open in tap mode so user can comfortably tap an item!
    final safeTriggerRect = triggerRect.inflate(12.0);
    if (safeTriggerRect.contains(releasePosition)) {
      setState(() {
        _isDragSession = false;
        _highlightedIndex = null;
      });
      return;
    }

    // Otherwise, dragged away and released in empty space: cancel & dismiss
    dismiss(null);
  }

  void _selectItem(NixPopupMenuItem<T> item) {
    if (!item.enabled || _isClosing) return;
    _isClosing = true;

    item.onTap?.call();
    widget.onSelected(item.value);

    _animController.reverse().then((_) {
      if (mounted) {
        widget.overlayEntry.remove();
        widget.controller.onDismissed();
      }
    });
  }

  void dismiss(T? result) {
    if (_isClosing) return;
    _isClosing = true;

    if (result == null) {
      widget.onCanceled?.call();
    } else {
      widget.onSelected(result);
    }

    _animController.reverse().then((_) {
      if (mounted) {
        widget.overlayEntry.remove();
        widget.controller.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _checkHasEllipsis() {
    for (final item in widget.items) {
      if (_hasEllipsis(item.label) || _hasEllipsis(item.customChild)) {
        return true;
      }
    }
    return false;
  }

  bool _hasEllipsis(Widget? widget) {
    if (widget == null) return false;
    if (widget is Text) {
      return widget.overflow == TextOverflow.ellipsis ||
          widget.overflow == TextOverflow.fade;
    }
    if (widget is DefaultTextStyle) {
      return widget.overflow == TextOverflow.ellipsis ||
          widget.overflow == TextOverflow.fade;
    }
    return false;
  }

  double _measureMaxItemWidth(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w500,
    );

    double maxItemWidth = 0.0;

    for (final item in widget.items) {
      double itemWidth = 0.0;

      final EdgeInsets resolvedItemPadding =
          item.padding.resolve(Directionality.maybeOf(context));
      itemWidth += resolvedItemPadding.horizontal;

      if (item.icon != null) {
        itemWidth += 20.0 + 12.0;
      }

      if (item.trailing != null) {
        if (item.trailing is Text) {
          final trailingText = (item.trailing as Text).data ?? '';
          final painter = TextPainter(
            text: TextSpan(
              text: trailingText,
              style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
            maxLines: 1,
          )..layout();
          itemWidth += painter.width + 8.0;
          painter.dispose();
        } else {
          itemWidth += 24.0 + 8.0;
        }
      }

      if (item.label is Text) {
        final textWidget = item.label as Text;
        final text = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
        final style = textStyle.merge(textWidget.style);

        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
          maxLines: 1,
        )..layout();

        itemWidth += painter.width;
        painter.dispose();
      } else if (item.label != null) {
        itemWidth += 140.0;
      }

      if (itemWidth > maxItemWidth) {
        maxItemWidth = itemWidth;
      }
    }

    return maxItemWidth > 0 ? (maxItemWidth + widget.padding.horizontal + 6.0) : 0.0;
  }

  Widget _buildItem(
    NixPopupMenuItem<T> item,
    int index,
    int totalCount,
    bool hasEllipsis,
  ) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final itemRadius = NixPopupMenu.computeItemRadius(index, totalCount);
    final isHighlighted = _highlightedIndex == index;
    final isDestructive = item.isDestructive;
    final isEnabled = item.enabled;

    Color itemBgColor;
    if (!isEnabled) {
      itemBgColor = Colors.transparent;
    } else if (isHighlighted) {
      if (isDestructive) {
        itemBgColor = (nixTheme.error ?? colors.error).withValues(alpha: 0.15);
      } else {
        itemBgColor = (nixTheme.primary ?? colors.primary).withValues(alpha: 0.12);
      }
    } else {
      itemBgColor = Colors.transparent;
    }

    Color contentColor;
    if (!isEnabled) {
      contentColor = colors.onSurface.withValues(alpha: 0.38);
    } else if (isDestructive) {
      contentColor = nixTheme.error ?? colors.error;
    } else if (isHighlighted) {
      contentColor = nixTheme.primary ?? colors.primary;
    } else {
      contentColor = colors.onSurface;
    }

    Color iconColor;
    if (!isEnabled) {
      iconColor = colors.onSurface.withValues(alpha: 0.38);
    } else if (isDestructive) {
      iconColor = nixTheme.error ?? colors.error;
    } else if (isHighlighted) {
      iconColor = nixTheme.primary ?? colors.primary;
    } else {
      iconColor = colors.onSurfaceVariant;
    }

    return Material(
      key: _itemKeys[index],
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: itemRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: itemRadius,
        onTap: isEnabled ? () => _selectItem(item) : null,
        onHover: isEnabled
            ? (hovered) {
                if (!_isDragSession) {
                  setState(() {
                    _highlightedIndex = hovered ? index : null;
                  });
                }
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: itemBgColor,
            borderRadius: itemRadius,
          ),
          padding: item.padding,
          constraints: BoxConstraints(minHeight: item.height),
          child: item.customChild ??
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (item.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: iconColor,
                        size: 20.0,
                      ),
                      child: item.icon!,
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  if (item.label != null)
                    Expanded(
                      child: DefaultTextStyle(
                        style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          color: contentColor,
                          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: hasEllipsis ? 1 : null,
                        overflow: hasEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
                        child: item.label!,
                      ),
                    ),
                  if (item.trailing != null) ...[
                    const SizedBox(width: 8.0),
                    DefaultTextStyle(
                      style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
                        color: contentColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: iconColor,
                          size: 18.0,
                        ),
                        child: item.trailing!,
                      ),
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final resolvedBg = widget.backgroundColor ??
        (nixTheme.surfaceContainerHigh ??
            (colors.brightness == Brightness.dark
                ? colors.surfaceContainerHigh
                : colors.surface));

    // No border by default; only apply border if developer set borderColor
    final BorderSide resolvedBorderSide = widget.borderColor != null
        ? BorderSide(color: widget.borderColor!, width: 1.0)
        : BorderSide.none;

    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final targetCenter = widget.triggerRect.center;

    final maxAllowedOnScreen =
        (screenWidth - mediaQuery.padding.horizontal - 16.0).clamp(100.0, double.infinity);

    final bool hasEllipsis = _checkHasEllipsis();
    final double resolvedMaxWidth;
    final double resolvedMinWidth;

    const double defaultWidth = 200.0;

    if (widget.maxWidth != null) {
      // 1. Developer set maxWidth manually: strictly respect it
      resolvedMaxWidth = widget.maxWidth!.clamp(40.0, maxAllowedOnScreen);
      resolvedMinWidth =
          (widget.minWidth ?? math.min(defaultWidth, resolvedMaxWidth)).clamp(0.0, resolvedMaxWidth);
    } else {
      // 2. Default maxWidth is 200.0
      if (hasEllipsis) {
        // If developer added overflow: TextOverflow.ellipsis or fade, clamp to default 200.0
        resolvedMaxWidth = math.min(defaultWidth, maxAllowedOnScreen);
        resolvedMinWidth = (widget.minWidth ?? resolvedMaxWidth).clamp(0.0, resolvedMaxWidth);
      } else {
        // If text is longer than maxWidth, adapt to text content
        final measured = _measureMaxItemWidth(context);
        if (measured > defaultWidth) {
          resolvedMaxWidth = math.min(measured.ceilToDouble(), maxAllowedOnScreen);
          resolvedMinWidth = (widget.minWidth ?? defaultWidth).clamp(0.0, resolvedMaxWidth);
        } else {
          resolvedMaxWidth = math.min(defaultWidth, maxAllowedOnScreen);
          resolvedMinWidth = (widget.minWidth ?? resolvedMaxWidth).clamp(0.0, resolvedMaxWidth);
        }
      }
    }

    // Origin-aware transform alignment: scale in/out relative to the trigger position
    final double originX;
    if (targetCenter.dx > screenWidth * 0.6) {
      originX = 1.0;
    } else if (targetCenter.dx < screenWidth * 0.4) {
      originX = -1.0;
    } else {
      originX = ((targetCenter.dx / screenWidth) * 2.0 - 1.0).clamp(-1.0, 1.0);
    }

    final double yBelow = widget.triggerRect.bottom + widget.offset.dy;
    final double estimatedHeight = widget.items.length * 44.0 + 8.0;
    final bool opensBelow = widget.position == NixPopupPosition.below ||
        (widget.position == NixPopupPosition.auto &&
            yBelow + estimatedHeight <= screenHeight - mediaQuery.padding.bottom - 8.0);

    final double originY = opensBelow ? -1.0 : 1.0;
    final transformAlignment = Alignment(originX, originY);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Barrier layer to detect any outside interaction (tap, scroll, drag, pan) and dismiss
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              if (widget.barrierDismissible) {
                dismiss(null);
              }
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent && widget.barrierDismissible) {
                dismiss(null);
              }
            },
            onPointerPanZoomStart: (event) {
              if (widget.barrierDismissible) {
                dismiss(null);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.barrierDismissible ? () => dismiss(null) : null,
              onVerticalDragStart: widget.barrierDismissible ? (_) => dismiss(null) : null,
              onHorizontalDragStart: widget.barrierDismissible ? (_) => dismiss(null) : null,
              child: Container(
                color: widget.barrierColor,
              ),
            ),
          ),
        ),

        // Popup Container positioned relative to targetRect
        CustomSingleChildLayout(
          delegate: _NixPopupMenuLayoutDelegate(
            targetRect: widget.triggerRect,
            screenPadding: mediaQuery.padding + const EdgeInsets.all(8.0),
            position: widget.position,
            offset: widget.offset,
          ),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                alignment: transformAlignment,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Listener(
              onPointerMove: (event) {
                if (_isDragSession) {
                  updatePointerPosition(event.position);
                }
              },
              onPointerUp: (event) {
                if (_isDragSession && _highlightedIndex != null) {
                  final item = widget.items[_highlightedIndex!];
                  if (item.enabled) {
                    _selectItem(item);
                  }
                }
              },
              child: Container(
                decoration: ShapeDecoration(
                  color: resolvedBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius,
                    side: resolvedBorderSide,
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: colors.brightness == Brightness.dark ? 0.38 : 0.12,
                      ),
                      blurRadius: 18.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: widget.padding,
                constraints: BoxConstraints(
                  minWidth: resolvedMinWidth,
                  maxWidth: resolvedMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < widget.items.length; i++) ...[
                      if (i > 0) SizedBox(height: widget.gap),
                      _buildItem(widget.items[i], i, widget.items.length, hasEllipsis),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom layout delegate that computes ideal positioning and avoids screen boundary overflows.
class _NixPopupMenuLayoutDelegate extends SingleChildLayoutDelegate {
  _NixPopupMenuLayoutDelegate({
    required this.targetRect,
    required this.screenPadding,
    required this.position,
    required this.offset,
  });

  final Rect targetRect;
  final EdgeInsets screenPadding;
  final NixPopupPosition position;
  final Offset offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(screenPadding);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Horizontal positioning: align with target's left, clamp within screen margins
    double x = targetRect.left + offset.dx;
    if (x + childSize.width > size.width - screenPadding.right) {
      x = targetRect.right - childSize.width - offset.dx;
    }
    x = x.clamp(screenPadding.left, (size.width - screenPadding.right - childSize.width).clamp(screenPadding.left, double.infinity));

    // Vertical positioning: auto-detect best fit between below and above
    final double yBelow = targetRect.bottom + offset.dy;
    final double yAbove = targetRect.top - childSize.height - offset.dy;

    final bool fitsBelow = yBelow + childSize.height <= size.height - screenPadding.bottom;
    final bool fitsAbove = yAbove >= screenPadding.top;

    double y;

    switch (position) {
      case NixPopupPosition.below:
        y = yBelow;
        break;
      case NixPopupPosition.above:
        y = yAbove;
        break;
      case NixPopupPosition.auto:
        if (fitsBelow) {
          y = yBelow;
        } else if (fitsAbove) {
          y = yAbove;
        } else {
          // If neither fits completely, pick side with greater room
          final spaceBelow = size.height - screenPadding.bottom - yBelow;
          final spaceAbove = targetRect.top - screenPadding.top;
          y = spaceBelow >= spaceAbove ? yBelow : yAbove;
        }
        break;
    }

    y = y.clamp(screenPadding.top, (size.height - screenPadding.bottom - childSize.height).clamp(screenPadding.top, double.infinity));

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_NixPopupMenuLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        screenPadding != oldDelegate.screenPadding ||
        position != oldDelegate.position ||
        offset != oldDelegate.offset;
  }
}

/// Standalone imperative helper to open a [NixPopupMenu] from any callback or custom gesture.
Future<T?> showNixPopupMenu<T>({
  required BuildContext context,
  required List<NixPopupMenuItem<T>> items,
  Rect? targetRect,
  Offset? position,
  NixPopupPosition popupPosition = NixPopupPosition.auto,
  Offset offset = const Offset(0, 4),
  Color? backgroundColor,
  Color? borderColor,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  EdgeInsets padding = const EdgeInsets.all(4.0),
  double gap = 2.0,
  double? minWidth,
  double? maxWidth,
  Color barrierColor = Colors.transparent,
  bool barrierDismissible = true,
  bool enableHaptics = true,
}) {
  final completer = Completer<T?>();
  final overlayState = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

  Rect effectiveTargetRect;
  if (targetRect != null) {
    effectiveTargetRect = targetRect;
  } else if (position != null) {
    effectiveTargetRect = Rect.fromLTWH(position.dx, position.dy, 1, 1);
  } else {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      effectiveTargetRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    } else {
      effectiveTargetRect = Rect.zero;
    }
  }

  late final OverlayEntry overlayEntry;

  final controller = _NixPopupMenuOverlayController<T>(
    onDismissed: () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    },
  );

  overlayEntry = OverlayEntry(
    builder: (overlayContext) {
      return _NixPopupMenuOverlay<T>(
        controller: controller,
        overlayEntry: overlayEntry,
        triggerRect: effectiveTargetRect,
        items: items,
        initialPointerPosition: null,
        isDragSession: false,
        position: popupPosition,
        offset: offset,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: borderRadius,
        padding: padding,
        gap: gap,
        minWidth: minWidth,
        maxWidth: maxWidth,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        enableHaptics: enableHaptics,
        onSelected: (val) {
          if (!completer.isCompleted) {
            completer.complete(val);
          }
        },
        onCanceled: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );
    },
  );

  controller.entry = overlayEntry;
  overlayState.insert(overlayEntry);

  return completer.future;
}
