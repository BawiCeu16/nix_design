import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/nix_geometry.dart';
import '../../theme/nix_size.dart';
import '../../theme/nix_theme_data.dart';
import '../buttons/nix_button.dart';

/// Position where [NixSnackBar] floats on the screen.
enum NixSnackBarPosition {
  /// Floats at the top of the screen (slides down from top to enter, slides up to exit).
  top,

  /// Floats at the bottom of the screen (slides up from bottom to enter, slides down to exit).
  bottom,
}

/// Controller handle returned by [NixSnackBar.show] to manage an active snackbar.
class NixSnackBarController {
  NixSnackBarController._();

  OverlayEntry? _overlayEntry;
  _NixSnackBarWidgetState? _state;

  /// The underlying [OverlayEntry] displaying the snackbar.
  OverlayEntry? get overlayEntry => _overlayEntry;

  /// Dismisses this snackbar with its slide-out animation.
  void dismiss({bool immediately = false}) {
    _state?.dismiss(immediately: immediately);
  }
}

/// A stadium/pill-shaped floating snackbar that floats over all layers in the root overlay
/// with dynamic width and physical slide in/out animations.
class NixSnackBar {
  NixSnackBar._();

  static _NixSnackBarWidgetState? _activeState;

  /// Shows a stadium/pill [NixSnackBar] floating over all layers with slide in and out animations.
  ///
  /// Supports:
  /// - Floating over any layer (including bottom navigation bars, sheets, and dialogs) via the root [Overlay].
  /// - Dynamic width: hugs its content rather than stretching across the entire screen.
  /// - Slide in / slide out from [NixSnackBarPosition.bottom] (slides up to enter, slides down to exit)
  ///   or [NixSnackBarPosition.top] (slides down to enter, slides up to exit).
  /// - Vertical and horizontal swipe-to-dismiss gestures.
  static NixSnackBarController show(
    BuildContext context, {
    String? message,
    Widget? content,
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? action,
    Duration duration = const Duration(seconds: 4),
    NixSnackBarPosition position = NixSnackBarPosition.bottom,
    double maxWidth = 560.0,
    Color? backgroundColor,
    Color? textColor,
    Color? actionColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double elevation = 8.0,
    VoidCallback? onDismissed,
  }) {
    assert(
      message != null || content != null,
      'NixSnackBar must provide either message text or content widget',
    );

    // Smoothly dismiss any currently visible snackbar
    _activeState?.dismiss(immediately: true);
    _activeState = null;

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);
    late final OverlayEntry overlayEntry;
    final controller = NixSnackBarController._();

    overlayEntry = OverlayEntry(
      builder: (ctx) => InheritedTheme.captureAll(
        context,
        _NixSnackBarWidget(
          key: UniqueKey(),
          message: message,
          content: content,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          action: action,
          duration: duration,
          position: position,
          maxWidth: maxWidth,
          backgroundColor: backgroundColor,
          textColor: textColor,
          actionColor: actionColor,
          margin: margin,
          padding: padding,
          elevation: elevation,
          onDismissed: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
            if (_activeState == controller._state) {
              _activeState = null;
            }
            onDismissed?.call();
          },
          onStateCreated: (state) {
            controller._state = state;
            _activeState = state;
          },
        ),
      ),
    );

    controller._overlayEntry = overlayEntry;
    overlay.insert(overlayEntry);
    return controller;
  }

  /// Dismisses any currently visible [NixSnackBar].
  static void dismiss({bool immediately = false}) {
    _activeState?.dismiss(immediately: immediately);
    _activeState = null;
  }

  /// Builds a raw [SnackBar] instance configured with stadium pill borders.
  ///
  /// Useful for standard [ScaffoldMessenger] integration where native [SnackBar] widgets are required.
  static SnackBar create({
    required Widget content,
    Color? backgroundColor,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
    EdgeInsetsGeometry? margin,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: NixGeometry.stadiumBorder,
      backgroundColor: backgroundColor,
      margin: margin ?? const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      duration: duration,
      content: content,
      action: action,
    );
  }
}

class _NixSnackBarWidget extends StatefulWidget {
  const _NixSnackBarWidget({
    super.key,
    this.message,
    this.content,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.action,
    required this.duration,
    required this.position,
    required this.maxWidth,
    this.backgroundColor,
    this.textColor,
    this.actionColor,
    this.margin,
    this.padding,
    required this.elevation,
    required this.onDismissed,
    required this.onStateCreated,
  });

  final String? message;
  final Widget? content;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;
  final Duration duration;
  final NixSnackBarPosition position;
  final double maxWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? actionColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final VoidCallback onDismissed;
  final ValueChanged<_NixSnackBarWidgetState> onStateCreated;

  @override
  State<_NixSnackBarWidget> createState() => _NixSnackBarWidgetState();
}

class _NixSnackBarWidgetState extends State<_NixSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    // Physical slide in/out from off-screen:
    // If bottom: begins at Offset(0, 3.5) below screen, slides UP into place.
    // If top: begins at Offset(0, -3.5) above screen, slides DOWN into place.
    final beginOffset = widget.position == NixSnackBarPosition.top
        ? const Offset(0.0, -3.5)
        : const Offset(0.0, 3.5);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    if (widget.duration > Duration.zero) {
      _dismissTimer = Timer(widget.duration, dismiss);
    }
  }

  void dismiss({bool immediately = false}) {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();

    if (immediately || !mounted) {
      widget.onDismissed();
      return;
    }

    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final isDark = colors.brightness == Brightness.dark;
    final ext = theme.extension<NixThemeData>();

    final bg = widget.backgroundColor ??
        ext?.surfaceContainerHigh ??
        (isDark
            ? (nixTheme.surfaceContainerHigh ?? colors.surfaceContainerHighest)
            : colors.inverseSurface);

    final fg = widget.textColor ??
        ext?.onSurface ??
        (isDark
            ? (nixTheme.onSurface ?? colors.onSurface)
            : colors.onInverseSurface);

    final actColor = widget.actionColor ??
        ext?.primary ??
        (isDark
            ? (nixTheme.primary ?? colors.primary)
            : colors.inversePrimary);

    final isTop = widget.position == NixSnackBarPosition.top;
    final defaultMargin = isTop
        ? const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0)
        : const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0);
    final effectiveMargin = widget.margin ?? defaultMargin;

    Widget pillContent = Row(
      mainAxisSize: MainAxisSize.min, // Dynamic width! Hugs content.
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: 20.0),
            child: widget.icon!,
          ),
          const SizedBox(width: 10.0),
        ],
        if (widget.content != null)
          Flexible(child: widget.content!)
        else if (widget.message != null)
          Flexible(
            child: Text(
              widget.message!,
              style: TextStyle(
                color: fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
        if (widget.actionLabel != null && widget.onAction != null) ...[
          const SizedBox(width: 10.0),
          NixButton.text(
            size: NixSize.small,
            foregroundColor: actColor,
            label: Text(widget.actionLabel!),
            onPressed: () {
              dismiss();
              widget.onAction!();
            },
          ),
        ] else if (widget.action != null) ...[
          const SizedBox(width: 10.0),
          widget.action!,
        ],
      ],
    );

    final materialPill = Material(
      key: const Key('nix_snack_bar_pill'),
      color: bg,
      shape: const StadiumBorder(),
      elevation: widget.elevation,
      shadowColor: colors.shadow.withValues(alpha: 0.22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: pillContent,
      ),
    );

    // Swipe-to-dismiss gesture handling (dismiss in natural direction)
    final gesturePill = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        if (isTop) {
          if (details.primaryDelta != null && details.primaryDelta! < -3.0) {
            dismiss();
          }
        } else {
          if (details.primaryDelta != null && details.primaryDelta! > 3.0) {
            dismiss();
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > 250.0) {
          dismiss();
        }
      },
      child: materialPill,
    );

    return SafeArea(
      top: isTop,
      bottom: !isTop,
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: Padding(
          padding: effectiveMargin,
          child: SlideTransition(
            key: const Key('nix_snack_bar_slide'),
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth,
                minWidth: 80.0,
              ),
              child: gesturePill,
            ),
          ),
        ),
      ),
    );
  }
}
