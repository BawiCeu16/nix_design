import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';

/// Position of a separate companion action widget relative to [NixBottomBar].
enum NixBarActionPosition {
  /// Place the separate action widget to the left of the navigation bar.
  left,

  /// Place the separate action widget to the right of the navigation bar.
  right,
}

/// Label visibility behavior for [NixBottomBar].
enum NixNavigationLabelBehavior {
  /// Always display labels alongside or under icons.
  alwaysShow,

  /// Display labels only when the item is currently selected.
  onlySelected,

  /// Always hide labels and show only icons.
  alwaysHide,
}

/// Navigation item for [NixBottomBar].
///
/// Supports:
/// - Both icon and text (label placed vertically under the icon)
/// - Only icon (no label)
/// - Only text (pure text with no icon)
/// - Or custom arbitrary [child] widgets with dynamic widths.
class NixBottomBarItem {
  const NixBottomBarItem({
    this.icon,
    this.activeIcon,
    this.label,
    this.child,
    this.badge,
    this.tooltip,
    this.padding,
    this.onLongPress,
  }) : assert(
         icon != null || child != null || label != null,
         'NixBottomBarItem must provide at least an icon, label, or custom child widget',
       );

  /// The default icon widget shown for this item.
  final Widget? icon;

  /// Optional active icon shown when this item is currently selected.
  final Widget? activeIcon;

  /// Optional text label for this item (rendered underneath the icon, or as standalone text).
  final String? label;

  /// Optional arbitrary widget content supporting dynamic width and layout.
  /// If provided, this is rendered inside the item slot.
  final Widget? child;

  /// Optional badge widget attached to the top-right corner of the icon or child.
  final Widget? badge;

  /// Optional tooltip displayed on mouse hover or long press.
  final String? tooltip;

  /// Optional custom padding for this item.
  final EdgeInsetsGeometry? padding;

  /// Optional callback invoked when this item is long-pressed.
  ///
  /// Can be used to trigger dialogs, popups, bottom sheets, or custom actions.
  final VoidCallback? onLongPress;
}

/// A floating stadium/pill bottom navigation bar with an interactive sliding indicator,
/// dynamic item widths, responsive screen-size scaling, separate companion action buttons
/// (left or right), and scroll-to-hide/shrink support.
///
/// ### Scaffold & Suggestion:
/// When using [NixBottomBar] as the `bottomNavigationBar` in a [Scaffold],
/// always set `extendBody: true` on the [Scaffold].
class NixBottomBar extends StatefulWidget {
  const NixBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.onLongPress,
    this.equalWidth = true,
    this.itemWidth,
    this.maxWidth = 560.0,
    this.height,
    this.action,
    this.actionPosition = NixBarActionPosition.right,
    this.leading,
    this.trailing,
    this.actionSpacing = 10.0,
    this.scrollController,
    this.hideOnScroll = true,
    this.shrinkOnScroll = true,
    this.shrinkScale = 0.92,
    this.labelBehavior = NixNavigationLabelBehavior.alwaysShow,
    this.enableGestureSliding = true,
    this.backgroundColor,
    this.borderColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.indicatorColor,
    this.elevation = 0.0,
    this.margin = const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 14.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 6.0,
      vertical: 6.0,
    ),
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.mainAxisSize = MainAxisSize.max,
    this.alignment = Alignment.bottomCenter,
  });

  /// The list of navigation items.
  final List<NixBottomBarItem> items;

  /// The currently active index.
  final int currentIndex;

  /// Callback when an item is selected by tap or gesture sliding.
  final ValueChanged<int> onTap;

  /// Optional callback invoked when any navigation item is long-pressed.
  /// Receives the index of the long-pressed item.
  final ValueChanged<int>? onLongPress;

  /// Whether all navigation bar items should have equal dynamic width.
  /// Defaults to `true`.
  ///
  /// When `true`, all items dynamically adapt to the same uniform width
  /// (sized to fit the widest item's content or distributed across available space).
  /// When `false`, each item dynamically sizes strictly to its own individual content.
  final bool equalWidth;

  /// Optional fixed width override for each item.
  /// If null (default), items dynamically compute equal widths based on content and layout.
  final double? itemWidth;

  /// Maximum width constraint for the floating navigation bar.
  ///
  /// Defaults to 560.0, ensuring the floating pill maintains an elegant,
  /// proportional size on wide screens (tablets, desktop, and landscape orientation)
  /// while expanding naturally on mobile phone screens.
  /// Set to [double.infinity] if you want the bar to stretch across the full width.
  final double? maxWidth;

  /// Optional fixed height for the navigation items inside the bar.
  ///
  /// If null (default), the height is determined dynamically by item contents and padding.
  final double? height;

  /// Optional separate companion action widget placed beside the floating navigation bar
  /// (e.g. search button, FAB, avatar, or any custom widget).
  final Widget? action;

  /// Whether the [action] widget is placed to the [left] or [right] of the navigation bar.
  /// Defaults to [NixBarActionPosition.right].
  final NixBarActionPosition actionPosition;

  /// Optional separate widget placed to the left of the navigation bar.
  final Widget? leading;

  /// Optional separate widget placed to the right of the navigation bar.
  final Widget? trailing;

  /// Spacing between the navigation bar pill and the separate side action widgets.
  /// Defaults to 10.0.
  final double actionSpacing;

  /// Optional [ScrollController] to automatically hide or shrink the bar on scroll.
  final ScrollController? scrollController;

  /// Whether to slide the bar down off-screen when scrolling downwards.
  final bool hideOnScroll;

  /// Whether to shrink the bar scale/size when scrolling downwards.
  final bool shrinkOnScroll;

  /// Scale factor applied to the navigation bar when fully shrunk on scroll.
  /// Defaults to 0.92 (a subtle ~8% shrink, rather than an aggressive reduction).
  final double shrinkScale;

  /// Visibility behavior of text labels.
  final NixNavigationLabelBehavior labelBehavior;

  /// Whether to enable sliding the active indicator by hand gestures across items.
  final bool enableGestureSliding;

  /// Background color of the floating pill.
  /// Defaults to app theme [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  /// Optional border color for the floating navigation bar pill.
  /// Defaults to null (no border).
  final Color? borderColor;

  /// Color for the selected item's icon and label.
  final Color? selectedItemColor;

  /// Color for unselected items' icons and labels.
  final Color? unselectedItemColor;

  /// Color of the sliding pill indicator.
  final Color? indicatorColor;

  /// Elevation / drop shadow of the floating pill (rendered when background is not transparent).
  final double elevation;

  /// Outer margin around the floating pill bar.
  final EdgeInsetsGeometry margin;

  /// Inner padding inside the floating pill bar.
  final EdgeInsetsGeometry padding;

  /// Inner padding for each item.
  final EdgeInsetsGeometry itemPadding;

  /// Duration for sliding indicator and scroll transitions.
  final Duration animationDuration;

  /// Animation curve for sliding transitions.
  final Curve animationCurve;

  /// Main axis sizing of the bar row (`MainAxisSize.min` for compact pill, `MainAxisSize.max` for full-width).
  final MainAxisSize mainAxisSize;

  /// Alignment of the floating bar in its container (defaults to `Alignment.bottomCenter`).
  final AlignmentGeometry alignment;

  @override
  State<NixBottomBar> createState() => _NixBottomBarState();
}

class _NixBottomBarState extends State<NixBottomBar>
    with TickerProviderStateMixin {
  final GlobalKey _itemsContainerKey = GlobalKey();
  late List<GlobalKey> _itemKeys;

  late final AnimationController _indicatorController;
  late final Animation<double> _indicatorAnimation;

  late final AnimationController _hideController;
  late final Animation<double> _hideAnimation;

  double _indicatorPosition = 0.0;
  double _fromPosition = 0.0;
  double _toPosition = 0.0;

  bool _isDragging = false;
  double _dragStartX = 0.0;
  double _dragStartPosition = 0.0;
  int? _dragActiveIndex;
  int? _lastHapticIndex;
  ScrollController? _scrollController;
  DateTime? _lastUnshrinkTime;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _indicatorPosition = widget.currentIndex.toDouble();
    _fromPosition = _indicatorPosition;
    _toPosition = _indicatorPosition;

    _indicatorController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: widget.animationCurve,
    )..addListener(_onIndicatorTick);

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _hideAnimation = CurvedAnimation(
      parent: _hideController,
      curve: Curves.easeInOutCubic,
    );

    _updateScrollController();
  }

  void _onIndicatorTick() {
    setState(() {
      _indicatorPosition =
          ui.lerpDouble(
            _fromPosition,
            _toPosition,
            _indicatorAnimation.value,
          ) ??
          _toPosition;
    });
  }

  @override
  void didUpdateWidget(covariant NixBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
      final maxPos = (widget.items.length - 1).toDouble();
      if (_indicatorPosition > maxPos) {
        _indicatorPosition = maxPos.clamp(0.0, double.infinity);
      }
    }

    if (oldWidget.currentIndex != widget.currentIndex) {
      if (!_isDragging) {
        _animateTo(widget.currentIndex.toDouble());
      }
    }

    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController?.removeListener(_onScroll);
      _updateScrollController();
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _indicatorController.dispose();
    _hideController.dispose();
    super.dispose();
  }

  void _updateScrollController() {
    _scrollController = widget.scrollController;
    _scrollController?.addListener(_onScroll);
  }

  void _unshrink() {
    if (_hideController.value > 0.0 ||
        _hideController.status == AnimationStatus.forward) {
      _lastUnshrinkTime = DateTime.now();
      _hideController.reverse();
    }
  }

  EdgeInsetsGeometry _getReducedMargin(
    EdgeInsetsGeometry margin,
    double factor,
  ) {
    if (margin is EdgeInsets) {
      return EdgeInsets.only(
        left: margin.left * factor,
        right: margin.right * factor,
        top: margin.top * factor,
        bottom: margin.bottom * factor,
      );
    } else if (margin is EdgeInsetsDirectional) {
      return EdgeInsetsDirectional.only(
        start: margin.start * factor,
        end: margin.end * factor,
        top: margin.top * factor,
        bottom: margin.bottom * factor,
      );
    }
    return margin;
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (_lastUnshrinkTime != null &&
        DateTime.now().difference(_lastUnshrinkTime!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    final position = _scrollController!.position;

    if (position.userScrollDirection == ScrollDirection.reverse) {
      if ((widget.hideOnScroll || widget.shrinkOnScroll) &&
          _hideController.status != AnimationStatus.forward &&
          _hideController.value < 1.0) {
        _hideController.forward();
      }
    } else if (position.userScrollDirection == ScrollDirection.forward ||
        position.pixels <= 0) {
      if (_hideController.status != AnimationStatus.reverse &&
          _hideController.value > 0.0) {
        _hideController.reverse();
      }
    }
  }

  void _animateTo(double targetPosition) {
    _fromPosition = _indicatorPosition;
    _toPosition = targetPosition;

    _indicatorController.duration = widget.animationDuration;
    _indicatorController.reset();
    _indicatorController.forward();
  }

  void _handleItemTap(int index) {
    _unshrink();
    HapticFeedback.selectionClick();
    _animateTo(index.toDouble());
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  void _handleItemLongPress(int index) {
    _unshrink();
    if (index >= 0 && index < widget.items.length) {
      HapticFeedback.selectionClick();
      widget.items[index].onLongPress?.call();
      widget.onLongPress?.call(index);
    }
  }

  void _onDragStart(DragStartDetails details) {
    _unshrink();
    if (widget.items.isEmpty) return;
    _isDragging = true;
    _indicatorController.stop();
    _dragStartX = details.localPosition.dx;
    _dragStartPosition = _indicatorPosition;
    _lastHapticIndex = _indicatorPosition.round();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || widget.items.isEmpty) return;
    final box =
        _itemsContainerKey.currentContext?.findRenderObject() as RenderBox?;
    final totalWidth = (box != null && box.hasSize) ? box.size.width : 300.0;
    final itemCount = widget.items.length;
    final itemWidth = totalWidth / itemCount;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final deltaX = details.localPosition.dx - _dragStartX;
    final deltaPos = isRtl ? (-deltaX / itemWidth) : (deltaX / itemWidth);
    final maxPos = (itemCount - 1).toDouble();
    final newPos = (_dragStartPosition + deltaPos).clamp(0.0, maxPos);

    final closestIndex = newPos.round();
    if (closestIndex != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = closestIndex;
    }

    setState(() {
      _indicatorPosition = newPos;
      _dragActiveIndex = closestIndex;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    final itemCount = widget.items.length;
    if (itemCount == 0) return;

    int targetIndex = _indicatorPosition.round();
    final velocity = details.primaryVelocity;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (velocity != null && velocity.abs() > 300) {
      final forward = isRtl ? velocity < 0 : velocity > 0;
      if (forward && targetIndex < itemCount - 1) {
        targetIndex = (_indicatorPosition.floor() + 1).clamp(0, itemCount - 1);
      } else if (!forward && targetIndex > 0) {
        targetIndex = (_indicatorPosition.ceil() - 1).clamp(0, itemCount - 1);
      }
    }

    setState(() {
      _dragActiveIndex = null;
    });

    _animateTo(targetIndex.toDouble());
    if (targetIndex != widget.currentIndex) {
      widget.onTap(targetIndex);
    }
  }

  void _onDragCancel() {
    _isDragging = false;
    setState(() {
      _dragActiveIndex = null;
    });
    _animateTo(widget.currentIndex.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bg =
        widget.backgroundColor ??
        (nixTheme.surfaceContainer ?? colors.surfaceContainer);
    final isTransparent = bg == Colors.transparent || bg.a == 0.0;
    final effectiveElevation = isTransparent ? 0.0 : widget.elevation;

    final activeFg =
        widget.selectedItemColor ?? (nixTheme.primary ?? colors.primary);
    final inactiveFg = widget.unselectedItemColor ?? colors.onSurfaceVariant;
    final indBg =
        widget.indicatorColor ??
        (nixTheme.primary?.withValues(alpha: 0.16) ??
            colors.primary.withValues(alpha: 0.16));

    final effectiveActiveIndex = _isDragging
        ? (_dragActiveIndex ?? _indicatorPosition.round())
        : _indicatorPosition.round();

    // 1. Navigation items layout with integrated sliding indicator:
    Widget itemsSection = _NixBarLayout(
      key: _itemsContainerKey,
      mainAxisSize: widget.mainAxisSize,
      equalWidth: widget.equalWidth,
      indicatorPosition: _indicatorPosition,
      indicatorColor: indBg,
      itemWidth: widget.itemWidth,
      barHeight: widget.height,
      children: [
        for (int i = 0; i < widget.items.length; i++)
          KeyedSubtree(
            key: _itemKeys[i],
            child: _buildItem(
              index: i,
              item: widget.items[i],
              isSelected: i == effectiveActiveIndex,
              activeColor: activeFg,
              inactiveColor: inactiveFg,
              onTap: () => _handleItemTap(i),
            ),
          ),
      ],
    );

    if (widget.enableGestureSliding) {
      itemsSection = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: _onDragCancel,
        child: itemsSection,
      );
    }

    // 2. The main navigation bar stadium pill:
    final navBarPill = Material(
      color: bg,
      elevation: effectiveElevation,
      shadowColor: isTransparent
          ? Colors.transparent
          : Colors.black.withValues(alpha: 0.18),
      shape: StadiumBorder(
        side: widget.borderColor != null
            ? BorderSide(color: widget.borderColor!)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: widget.padding, child: itemsSection),
    );

    // 3. Resolve separate companion side actions (beside the navigation bar on left or right):
    Widget? leftAction = widget.leading;
    Widget? rightAction = widget.trailing;

    if (widget.action != null) {
      if (widget.actionPosition == NixBarActionPosition.left) {
        leftAction ??= widget.action;
      } else {
        rightAction ??= widget.action;
      }
    }

    // 4. Assemble the complete floating bar group:
    Widget fullBar;
    if (leftAction == null && rightAction == null) {
      fullBar = navBarPill;
    } else {
      fullBar = Row(
        mainAxisSize: widget.mainAxisSize,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leftAction != null) ...[
            leftAction,
            SizedBox(width: widget.actionSpacing),
          ],
          if (widget.mainAxisSize == MainAxisSize.max)
            Expanded(child: navBarPill)
          else
            Flexible(child: navBarPill),
          if (rightAction != null) ...[
            SizedBox(width: widget.actionSpacing),
            rightAction,
          ],
        ],
      );
    }

    // Dynamic width constraint: ensures the floating bar maintains an elegant,
    // proportional width on wide screens (tablets, landscape, desktop) while expanding on phones.
    final double? effectiveMaxWidth = widget.maxWidth;
    if (effectiveMaxWidth != null && effectiveMaxWidth.isFinite) {
      fullBar = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: fullBar,
      );
    }

    // 5. When pressed anywhere while shrunk or hiding, unshrink back to normal size:
    fullBar = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _unshrink,
      child: fullBar,
    );

    // 6. Scroll to hide & shrink animations:
    if (widget.scrollController != null) {
      return AnimatedBuilder(
        animation: _hideAnimation,
        builder: (context, child) {
          final t = _hideAnimation.value;
          if (t == 1.0 && widget.hideOnScroll) {
            return const SizedBox.shrink();
          }

          final minScale = widget.shrinkScale.clamp(0.5, 1.0);
          final scale = widget.shrinkOnScroll
              ? (1.0 - ((1.0 - minScale) * t))
              : 1.0;
          final translateY = widget.hideOnScroll ? (120.0 * t) : 0.0;
          final opacity = widget.hideOnScroll ? (1.0 - t).clamp(0.0, 1.0) : 1.0;

          final reducedMargin = _getReducedMargin(widget.margin, 0.65);
          final currentMargin =
              EdgeInsetsGeometry.lerp(widget.margin, reducedMargin, t) ??
              widget.margin;

          return SafeArea(
            bottom: true,
            child: Align(
              alignment: widget.alignment,
              heightFactor: 1.0,
              child: Padding(
                padding: currentMargin,
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(opacity: opacity, child: child),
                  ),
                ),
              ),
            ),
          );
        },
        child: fullBar,
      );
    }

    return SafeArea(
      bottom: true,
      child: Align(
        alignment: widget.alignment,
        heightFactor: 1.0,
        child: Padding(padding: widget.margin, child: fullBar),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required NixBottomBarItem item,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    final fg = isSelected ? activeColor : inactiveColor;
    final padding = item.padding ?? widget.itemPadding;

    Widget content;
    if (item.child != null) {
      content = DefaultTextStyle(
        style: TextStyle(
          color: fg,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 12.0,
        ),
        child: IconTheme(
          data: IconThemeData(color: fg, size: 22.0),
          child: item.child!,
        ),
      );
    } else {
      Widget? iconWidget;
      if (item.icon != null) {
        iconWidget = isSelected && item.activeIcon != null
            ? item.activeIcon!
            : item.icon!;
        if (item.badge != null) {
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              Positioned(top: -3, right: -6, child: item.badge!),
            ],
          );
        }
      }

      final hasIcon = iconWidget != null;
      final showLabel =
          item.label != null &&
          (widget.labelBehavior == NixNavigationLabelBehavior.alwaysShow ||
              (widget.labelBehavior ==
                      NixNavigationLabelBehavior.onlySelected &&
                  isSelected));

      if (hasIcon && showLabel) {
        // Label placed UNDER the icon
        content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: fg, size: 22.0),
              child: iconWidget,
            ),
            const SizedBox(height: 3.0),
            Text(
              item.label!,
              style: TextStyle(
                color: fg,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11.5,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (hasIcon) {
        // ONLY ICON (no label)
        content = IconTheme(
          data: IconThemeData(color: fg, size: 24.0),
          child: iconWidget,
        );
      } else if (item.label != null) {
        // ONLY TEXT (if text is used, no extra icon or duplicate label)
        content = Text(
          item.label!,
          style: TextStyle(
            color: fg,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        content = const SizedBox.shrink();
      }
    }

    final hasLongPress = item.onLongPress != null || widget.onLongPress != null;

    // Pure gesture detector with no InkWell press/ripple effect:
    Widget itemWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: hasLongPress ? () => _handleItemLongPress(index) : null,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: padding,
          child: Center(widthFactor: 1.0, heightFactor: 1.0, child: content),
        ),
      ),
    );

    if (item.tooltip != null) {
      itemWidget = Tooltip(
        message: item.tooltip!,
        triggerMode: hasLongPress
            ? TooltipTriggerMode.manual
            : TooltipTriggerMode.longPress,
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}

/// Multi-child layout widget that arranges navigation items and paints the sliding indicator.
class _NixBarLayout extends MultiChildRenderObjectWidget {
  const _NixBarLayout({
    super.key,
    required super.children,
    required this.mainAxisSize,
    required this.equalWidth,
    required this.indicatorPosition,
    required this.indicatorColor,
    this.itemWidth,
    this.barHeight,
  });

  final MainAxisSize mainAxisSize;
  final bool equalWidth;
  final double indicatorPosition;
  final Color indicatorColor;
  final double? itemWidth;
  final double? barHeight;

  @override
  _RenderNixBar createRenderObject(BuildContext context) {
    return _RenderNixBar(
      mainAxisSize: mainAxisSize,
      equalWidth: equalWidth,
      indicatorPosition: indicatorPosition,
      indicatorColor: indicatorColor,
      itemWidth: itemWidth,
      barHeight: barHeight,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderNixBar renderObject) {
    renderObject
      ..mainAxisSize = mainAxisSize
      ..equalWidth = equalWidth
      ..indicatorPosition = indicatorPosition
      ..indicatorColor = indicatorColor
      ..itemWidth = itemWidth
      ..barHeight = barHeight
      ..textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
  }
}

class _NixBarParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderNixBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _NixBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _NixBarParentData> {
  _RenderNixBar({
    required this._mainAxisSize,
    this._itemWidth,
    required this._equalWidth,
    required this._indicatorPosition,
    required this._indicatorColor,
    this._barHeight,
    required this._textDirection,
  });

  MainAxisSize get mainAxisSize => _mainAxisSize;
  MainAxisSize _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize == value) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  double? get itemWidth => _itemWidth;
  double? _itemWidth;
  set itemWidth(double? value) {
    if (_itemWidth == value) return;
    _itemWidth = value;
    markNeedsLayout();
  }

  bool get equalWidth => _equalWidth;
  bool _equalWidth;
  set equalWidth(bool value) {
    if (_equalWidth == value) return;
    _equalWidth = value;
    markNeedsLayout();
  }

  double get indicatorPosition => _indicatorPosition;
  double _indicatorPosition;
  set indicatorPosition(double value) {
    if (_indicatorPosition == value) return;
    _indicatorPosition = value;
    markNeedsPaint();
  }

  Color get indicatorColor => _indicatorColor;
  Color _indicatorColor;
  set indicatorColor(Color value) {
    if (_indicatorColor == value) return;
    _indicatorColor = value;
    markNeedsPaint();
  }

  double? get barHeight => _barHeight;
  double? _barHeight;
  set barHeight(double? value) {
    if (_barHeight == value) return;
    _barHeight = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  final List<Rect> _childRects = [];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _NixBarParentData) {
      child.parentData = _NixBarParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (childCount == 0) return 0.0;
    if (_itemWidth != null) return _itemWidth! * childCount;
    if (_equalWidth) {
      double maxMin = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as _NixBarParentData;
        maxMin = math.max(maxMin, child.getMinIntrinsicWidth(height));
        child = childParentData.nextSibling;
      }
      return maxMin * childCount;
    } else {
      double total = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as _NixBarParentData;
        total += child.getMinIntrinsicWidth(height);
        child = childParentData.nextSibling;
      }
      return total;
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (childCount == 0) return 0.0;
    if (_itemWidth != null) return _itemWidth! * childCount;
    if (_equalWidth) {
      double maxMax = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as _NixBarParentData;
        maxMax = math.max(maxMax, child.getMaxIntrinsicWidth(height));
        child = childParentData.nextSibling;
      }
      return maxMax * childCount;
    } else {
      double total = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as _NixBarParentData;
        total += child.getMaxIntrinsicWidth(height);
        child = childParentData.nextSibling;
      }
      return total;
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (childCount == 0) return 0.0;
    if (_barHeight != null) return _barHeight!;
    final childW = _equalWidth ? (width / childCount) : width;
    double maxMinH = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _NixBarParentData;
      maxMinH = math.max(maxMinH, child.getMinIntrinsicHeight(childW));
      child = childParentData.nextSibling;
    }
    return maxMinH;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (childCount == 0) return 0.0;
    if (_barHeight != null) return _barHeight!;
    final childW = _equalWidth ? (width / childCount) : width;
    double maxMaxH = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _NixBarParentData;
      maxMaxH = math.max(maxMaxH, child.getMaxIntrinsicHeight(childW));
      child = childParentData.nextSibling;
    }
    return maxMaxH;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) return constraints.constrain(Size.zero);

    double maxHeight = _barHeight ?? 0.0;
    if (_barHeight == null) {
      RenderBox? child = firstChild;
      while (child != null) {
        final h = child.getMaxIntrinsicHeight(double.infinity);
        if (h.isFinite && h > maxHeight) maxHeight = h;
        child = (child.parentData! as _NixBarParentData).nextSibling;
      }
      if (constraints.hasBoundedHeight) {
        maxHeight = math.min(maxHeight, constraints.maxHeight);
      }
      maxHeight = math.max(maxHeight, constraints.minHeight);
      maxHeight = math.max(maxHeight, 40.0);
    }

    if (_equalWidth) {
      double childWidth;
      if (_itemWidth != null) {
        childWidth = _itemWidth!;
      } else if (constraints.hasBoundedWidth &&
          _mainAxisSize == MainAxisSize.max) {
        childWidth = constraints.maxWidth / childCount;
      } else {
        double maxIntrinsic = constraints.hasBoundedWidth
            ? (constraints.minWidth / childCount)
            : 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          final w = child.getMaxIntrinsicWidth(maxHeight);
          if (w.isFinite && w > maxIntrinsic) maxIntrinsic = w;
          child = (child.parentData! as _NixBarParentData).nextSibling;
        }
        if (maxIntrinsic == 0.0) maxIntrinsic = 64.0;
        if (constraints.hasBoundedWidth) {
          childWidth = math.min(
            maxIntrinsic,
            constraints.maxWidth / childCount,
          );
        } else {
          childWidth = maxIntrinsic;
        }
      }
      childWidth = math.max(0.0, childWidth);
      return constraints.constrain(Size(childWidth * childCount, maxHeight));
    } else {
      double totalWidth = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childSize = child.getDryLayout(
          BoxConstraints(
            minWidth: 0.0,
            maxWidth: constraints.maxWidth,
            minHeight: maxHeight,
            maxHeight: maxHeight,
          ),
        );
        totalWidth += childSize.width;
        child = (child.parentData! as _NixBarParentData).nextSibling;
      }
      return constraints.constrain(Size(totalWidth, maxHeight));
    }
  }

  @override
  void performLayout() {
    _childRects.clear();
    if (childCount == 0) {
      size = constraints.constrain(Size.zero);
      return;
    }

    double maxHeight = _barHeight ?? 0.0;
    if (_barHeight == null) {
      RenderBox? child = firstChild;
      while (child != null) {
        final h = child.getMaxIntrinsicHeight(double.infinity);
        if (h.isFinite && h > maxHeight) maxHeight = h;
        child = (child.parentData! as _NixBarParentData).nextSibling;
      }
      if (constraints.hasBoundedHeight) {
        maxHeight = math.min(maxHeight, constraints.maxHeight);
      }
      maxHeight = math.max(maxHeight, constraints.minHeight);
      maxHeight = math.max(maxHeight, 40.0);
    }

    if (_equalWidth) {
      double childWidth;
      if (_itemWidth != null) {
        childWidth = _itemWidth!;
      } else if (constraints.hasBoundedWidth &&
          _mainAxisSize == MainAxisSize.max) {
        childWidth = constraints.maxWidth / childCount;
      } else {
        double maxIntrinsic = constraints.hasBoundedWidth
            ? (constraints.minWidth / childCount)
            : 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          final w = child.getMaxIntrinsicWidth(maxHeight);
          if (w.isFinite && w > maxIntrinsic) maxIntrinsic = w;
          child = (child.parentData! as _NixBarParentData).nextSibling;
        }
        if (maxIntrinsic == 0.0) maxIntrinsic = 64.0;
        if (constraints.hasBoundedWidth) {
          childWidth = math.min(
            maxIntrinsic,
            constraints.maxWidth / childCount,
          );
        } else {
          childWidth = maxIntrinsic;
        }
      }
      childWidth = math.max(0.0, childWidth);

      final childConstraints = BoxConstraints.tightFor(
        width: childWidth,
        height: maxHeight,
      );

      RenderBox? child = firstChild;
      while (child != null) {
        child.layout(childConstraints, parentUsesSize: true);
        child = (child.parentData! as _NixBarParentData).nextSibling;
      }

      final totalW = childWidth * childCount;
      size = constraints.constrain(Size(totalW, maxHeight));

      double start = 0.0;
      if (_textDirection == TextDirection.rtl) {
        start = size.width - childWidth;
      }

      child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as _NixBarParentData;
        childParentData.offset = Offset(start, 0.0);
        _childRects.add(Rect.fromLTWH(start, 0.0, childWidth, maxHeight));
        if (_textDirection == TextDirection.rtl) {
          start -= childWidth;
        } else {
          start += childWidth;
        }
        child = childParentData.nextSibling;
      }
    } else {
      double totalWidth = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childConstraints = BoxConstraints(
          minWidth: 0.0,
          maxWidth: constraints.maxWidth,
          minHeight: maxHeight,
          maxHeight: maxHeight,
        );
        child.layout(childConstraints, parentUsesSize: true);
        totalWidth += child.size.width;
        child = (child.parentData! as _NixBarParentData).nextSibling;
      }

      size = constraints.constrain(Size(totalWidth, maxHeight));

      double start = 0.0;
      if (_textDirection == TextDirection.rtl) {
        start = size.width;
        child = firstChild;
        while (child != null) {
          final childParentData = child.parentData! as _NixBarParentData;
          start -= child.size.width;
          childParentData.offset = Offset(start, 0.0);
          _childRects.add(
            Rect.fromLTWH(start, 0.0, child.size.width, maxHeight),
          );
          child = childParentData.nextSibling;
        }
      } else {
        child = firstChild;
        while (child != null) {
          final childParentData = child.parentData! as _NixBarParentData;
          childParentData.offset = Offset(start, 0.0);
          _childRects.add(
            Rect.fromLTWH(start, 0.0, child.size.width, maxHeight),
          );
          start += child.size.width;
          child = childParentData.nextSibling;
        }
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount > 0 &&
        _indicatorColor.a > 0 &&
        _childRects.isNotEmpty &&
        size.height > 0) {
      Rect indRect;
      final clampedPos = _indicatorPosition.clamp(
        0.0,
        (childCount - 1).toDouble(),
      );

      if (_equalWidth) {
        final childWidth = size.width / childCount;
        final indLeft = _textDirection == TextDirection.rtl
            ? (size.width - (clampedPos + 1.0) * childWidth)
            : (clampedPos * childWidth);
        indRect = Rect.fromLTWH(
          offset.dx + indLeft,
          offset.dy,
          childWidth,
          size.height,
        );
      } else {
        final idxA = clampedPos.floor().clamp(0, _childRects.length - 1);
        final idxB = clampedPos.ceil().clamp(0, _childRects.length - 1);
        final t = clampedPos - idxA;
        final rA = _childRects[idxA];
        final rB = _childRects[idxB];
        final left = ui.lerpDouble(rA.left, rB.left, t) ?? rA.left;
        final width = ui.lerpDouble(rA.width, rB.width, t) ?? rA.width;
        indRect = Rect.fromLTWH(
          offset.dx + left,
          offset.dy,
          width,
          size.height,
        );
      }

      final rrect = RRect.fromRectAndRadius(
        indRect,
        Radius.circular(size.height / 2),
      );
      final paint = Paint()
        ..color = _indicatorColor
        ..style = PaintingStyle.fill;
      context.canvas.drawRRect(rrect, paint);
    }

    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
