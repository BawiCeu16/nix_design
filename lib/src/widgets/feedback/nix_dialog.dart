import 'package:flutter/material.dart';
import '../../theme/nix_theme_data.dart';

/// A pill-styled modal dialog following Flutter's native [AlertDialog] ergonomics.
class NixDialog extends StatelessWidget {
  const NixDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(24.0),
    this.actionsPadding = const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
  });

  /// Optional header icon positioned prominently at the top.
  final Widget? icon;

  /// Dialog title widget.
  final Widget? title;

  /// Main content body.
  final Widget? content;

  /// Action buttons at the bottom (recommend using [NixButton]).
  final List<Widget>? actions;

  /// Background color override.
  final Color? backgroundColor;

  /// Corner radius override.
  final BorderRadiusGeometry? borderRadius;

  /// Internal padding for title and content.
  final EdgeInsetsGeometry padding;

  /// Padding around the action buttons.
  final EdgeInsetsGeometry actionsPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bg = backgroundColor ??
        (colors.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface);

    final effectiveRadius = borderRadius ?? BorderRadius.circular(28.0);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: ShapeDecoration(
                          color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.12),
                          shape: const CircleBorder(),
                        ),
                        child: Center(
                          child: IconTheme(
                            data: IconThemeData(
                              color: nixTheme.primary ?? colors.primary,
                              size: 26.0,
                            ),
                            child: icon!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    if (title != null) ...[
                      DefaultTextStyle(
                        style: (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        child: title!,
                      ),
                      const SizedBox(height: 10.0),
                    ],
                    if (content != null) ...[
                      DefaultTextStyle(
                        style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        child: content!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: actionsPadding,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Displays a [NixDialog] with native [showDialog] semantics.
Future<T?> showNixDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black54,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}
