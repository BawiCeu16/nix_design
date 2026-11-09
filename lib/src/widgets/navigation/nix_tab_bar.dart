import 'package:flutter/material.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';

/// A stadium/pill tab bar using Flutter's native [TabController].
class NixTabBar extends StatelessWidget implements PreferredSizeWidget {
  const NixTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.onTap,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorPadding = const EdgeInsets.all(3.0),
    this.height = 46.0,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final EdgeInsetsGeometry indicatorPadding;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bg =
        backgroundColor ??
        (nixTheme.surfaceContainer ??
            colors.surfaceContainerHighest.withValues(alpha: 0.5));
    final indColor =
        indicatorColor ??
        (colors.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface);

    final selectedFg = labelColor ?? (nixTheme.primary ?? colors.primary);
    final unselectedFg = unselectedLabelColor ?? colors.onSurfaceVariant;

    return Container(
      height: height,
      decoration: ShapeDecoration(color: bg, shape: NixGeometry.stadiumBorder),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        onTap: onTap,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashBorderRadius: NixGeometry.pillBorderRadius,
        labelColor: selectedFg,
        unselectedLabelColor: unselectedFg,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13.5,
        ),
        indicatorPadding: indicatorPadding,
        indicator: ShapeDecoration(
          color: indColor,
          shape: NixGeometry.stadiumBorder,
          // shadows: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.08),
          //     blurRadius: 4,
          //     offset: const Offset(0, 1.5),
          //   ),
          // ],
        ),
      ),
    );
  }
}
