import 'package:flutter/material.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';

/// Segment item configuration for [NixSegmentedControl].
class NixSegment<T> {
  const NixSegment({required this.value, this.label, this.icon, this.child})
    : assert(
        label != null || child != null || icon != null,
        'Provide label, icon, or child',
      );

  final T value;
  final String? label;
  final Widget? icon;
  final Widget? child;
}

/// A stadium/pill segmented control with a sliding pill thumb.
///
/// Automatically follows app [ThemeData] and updates with buttery smooth motion.
class NixSegmentedControl<T> extends StatelessWidget {
  const NixSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.backgroundColor,
    this.thumbColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.height = 42.0,
    this.padding = const EdgeInsets.all(4.0),
  });

  /// The currently selected value.
  final T value;

  /// The list of selectable segments.
  final List<NixSegment<T>> items;

  /// Callback when a segment is selected.
  final ValueChanged<T> onChanged;

  /// Background color of the outer pill track.
  final Color? backgroundColor;

  /// Color of the sliding pill thumb.
  final Color? thumbColor;

  /// Text color for the selected segment.
  final Color? selectedTextColor;

  /// Text color for unselected segments.
  final Color? unselectedTextColor;

  /// Height of the segmented control.
  final double height;

  /// Padding around the track.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final selectedIndex = items.indexWhere((item) => item.value == value);
    final count = items.length;

    final trackBg =
        backgroundColor ??
        (nixTheme.surfaceContainer ??
            colors.surfaceContainerHighest.withValues(alpha: 0.5));
    final sliderBg =
        thumbColor ??
        (colors.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : colors.surface);

    final activeFg = selectedTextColor ?? (nixTheme.primary ?? colors.primary);
    final inactiveFg = unselectedTextColor ?? colors.onSurfaceVariant;

    return Container(
      height: height,
      padding: padding,
      decoration: ShapeDecoration(
        color: trackBg,
        shape: NixGeometry.stadiumBorder,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final segmentWidth = count > 0 ? totalWidth / count : 0.0;
          final thumbOffset = selectedIndex >= 0
              ? selectedIndex * segmentWidth
              : 0.0;

          return Stack(
            children: [
              // Sliding pill indicator
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: nixTheme.animationDuration,
                  curve: nixTheme.animationCurve,
                  left: thumbOffset,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: sliderBg,
                      shape: NixGeometry.stadiumBorder,
                      shadows: [
                        // BoxShadow(
                        //   color: Colors.black.withValues(alpha: 0.08),
                        //   blurRadius: 4,
                        //   offset: const Offset(0, 1.5),
                        // ),
                      ],
                    ),
                  ),
                ),

              // Segment items row
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    Expanded(
                      child: _SegmentItem(
                        segment: items[i],
                        isSelected: items[i].value == value,
                        activeColor: activeFg,
                        inactiveColor: inactiveFg,
                        onTap: () => onChanged(items[i].value),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.segment,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final NixSegment segment;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? activeColor : inactiveColor;

    Widget content;
    if (segment.child != null) {
      content = segment.child!;
    } else {
      final List<Widget> children = [];
      if (segment.icon != null) {
        children.add(
          IconTheme(
            data: IconThemeData(color: fg, size: 18.0),
            child: segment.icon!,
          ),
        );
        if (segment.label != null) {
          children.add(const SizedBox(width: 6.0));
        }
      }
      if (segment.label != null) {
        children.add(
          Text(
            segment.label!,
            style: TextStyle(
              color: fg,
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(child: content),
    );
  }
}
