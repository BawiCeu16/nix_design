import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_geometry.dart';
import '../../theme/nix_theme_data.dart';
import '../buttons/nix_button.dart';
import '../inputs/nix_switch.dart';
import '../lists/nix_list_item.dart';
import '../lists/nix_list_physics.dart';
import '../lists/nix_switch_tile.dart';

/// Position of the rotating expansion indicator within [NixExpandable].
enum NixExpandableChevronPosition {
  /// Place the chevron at the trailing edge of the tile (default).
  trailing,

  /// Place the chevron at the leading edge of the tile.
  leading,

  /// Do not display a chevron indicator.
  none,
}

/// A premium, segmented expandable card/tile for the Nix Design System.
///
/// Shares the exact styling, rounded corner aesthetics, and native Flutter [InkWell]
/// splash ergonomics of [NixSwitchTile] and [NixListItem].
///
/// ### Features:
/// - **Segmented Corner Radii**: Automatically computes `12px` outer and `6px` neighbor
///   radii when arranged inside [NixSwitchList] or [NixListView].
/// - **Segmented & Rounded Radii**: Automatically computes `12px` outer and `6px` neighbor
///   radii when arranged inside [NixSwitchList] or [NixListView], or a stable `16px`
///   radius when standalone/single. Corner radius stays constant with zero shape-warping
///   during expansion or collapse.
/// - **Multiple Constructors**:
///   - [NixExpandable]: Flexible general-purpose expandable with customizable header and body.
///   - [NixExpandable.switchTile]: Combines a [NixSwitch] header with expandable content.
///   - [NixExpandable.update]: Dedicated app update showcase featuring version badge,
///     fixes list, metadata chips, progress bar, auto-update toggle, action button, and
///     support for blank arbitrary custom widgets.
class NixExpandable extends StatefulWidget {
  /// Creates a standard [NixExpandable] tile.
  const NixExpandable({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.header,
    this.child,
    this.children,
    this.expandedBuilder,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.enabled = true,
    this.showChevron = true,
    this.chevronPosition = NixExpandableChevronPosition.trailing,
    this.chevron,
    this.chevronColor,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.border,
    this.expandedBorder,
    this.borderRadius,
    this.expandedBorderRadius,
    this.tilePosition,
    this.elevation,
    this.expandedElevation,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.headerPadding,
    this.contentPadding = const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
    this.showDivider = false,
    this.divider,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOutCubic,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
  })  : isSwitchTile = false,
        switchValue = null,
        onSwitchChanged = null,
        expandOnSwitch = false,
        expandOnTap = true,
        controlAffinity = NixTileControlAffinity.trailing,
        switchKey = null,
        activeColor = null,
        inactiveColor = null,
        activeTrackColor = null,
        inactiveTrackColor = null,
        thumbColor = null,
        isUpdateTile = false,
        version = null,
        currentVersion = null,
        fixes = null,
        fixesHeader = null,
        titleText = null,
        subtitleText = null,
        releaseDate = null,
        fileSize = null,
        buildNumber = null,
        badge = null,
        badgeText = null,
        autoUpdate = null,
        onAutoUpdateChanged = null,
        autoUpdateTitle = null,
        autoUpdateSubtitle = null,
        action = null,
        onUpdate = null,
        updateButtonText = 'Update Now',
        isUpdating = false,
        progress = null;

  /// Creates a [NixExpandable] with an integrated [NixSwitch] header.
  ///
  /// Combines switch control ergonomics with expandable disclosure.
  const NixExpandable.switchTile({
    super.key,
    required this.switchValue,
    required this.onSwitchChanged,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.header,
    this.child,
    this.children,
    this.expandedBuilder,
    this.expandOnSwitch = false,
    this.expandOnTap = true,
    this.controlAffinity = NixTileControlAffinity.trailing,
    this.switchKey,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.enabled = true,
    this.showChevron = true,
    this.chevronPosition = NixExpandableChevronPosition.trailing,
    this.chevron,
    this.chevronColor,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.border,
    this.expandedBorder,
    this.borderRadius,
    this.expandedBorderRadius,
    this.tilePosition,
    this.elevation,
    this.expandedElevation,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.headerPadding,
    this.contentPadding = const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
    this.showDivider = false,
    this.divider,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOutCubic,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
  })  : isSwitchTile = true,
        isUpdateTile = false,
        version = null,
        currentVersion = null,
        fixes = null,
        fixesHeader = null,
        titleText = null,
        subtitleText = null,
        releaseDate = null,
        fileSize = null,
        buildNumber = null,
        badge = null,
        badgeText = null,
        autoUpdate = null,
        onAutoUpdateChanged = null,
        autoUpdateTitle = null,
        autoUpdateSubtitle = null,
        action = null,
        onUpdate = null,
        updateButtonText = 'Update Now',
        isUpdating = false,
        progress = null;

  /// Creates a dedicated app update [NixExpandable].
  ///
  /// Features:
  /// - Header showing update icon, title, [version] pill chip, and optional [badge].
  /// - Expanded body featuring [fixes] bullet list, metadata chips (version,
  ///   build number, release date, file size), optional [autoUpdate] toggle,
  ///   [progress] indicator, and [onUpdate] action button.
  /// - Full support for blank arbitrary custom widgets via [child] and [children].
  const NixExpandable.update({
    super.key,
    this.version,
    this.currentVersion,
    this.fixes,
    this.fixesHeader,
    this.titleText,
    this.title,
    this.subtitleText,
    this.subtitle,
    this.header,
    this.leading,
    this.trailing,
    this.releaseDate,
    this.fileSize,
    this.buildNumber,
    this.badge,
    this.badgeText,
    this.autoUpdate,
    this.onAutoUpdateChanged,
    this.autoUpdateTitle,
    this.autoUpdateSubtitle,
    this.action,
    this.onUpdate,
    this.updateButtonText = 'Update Now',
    this.isUpdating = false,
    this.progress,
    this.child,
    this.children,
    this.expandedBuilder,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.enabled = true,
    this.showChevron = true,
    this.chevronPosition = NixExpandableChevronPosition.trailing,
    this.chevron,
    this.chevronColor,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.border,
    this.expandedBorder,
    this.borderRadius,
    this.expandedBorderRadius,
    this.tilePosition,
    this.elevation,
    this.expandedElevation,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.headerPadding,
    this.contentPadding = const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
    this.showDivider = true,
    this.divider,
    this.animationDuration = const Duration(milliseconds: 260),
    this.curve = Curves.easeInOutCubic,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
  })  : isSwitchTile = false,
        switchValue = null,
        onSwitchChanged = null,
        expandOnSwitch = false,
        expandOnTap = true,
        controlAffinity = NixTileControlAffinity.trailing,
        switchKey = null,
        activeColor = null,
        inactiveColor = null,
        activeTrackColor = null,
        inactiveTrackColor = null,
        thumbColor = null,
        isUpdateTile = true;

  // Header & Tile Content
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? header;

  // Expanded Body
  final Widget? child;
  final List<Widget>? children;
  final Widget Function(BuildContext context, bool isExpanded)? expandedBuilder;

  // Expansion State & Control
  final bool initiallyExpanded;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool enabled;

  // Chevron Indicator
  final bool showChevron;
  final NixExpandableChevronPosition chevronPosition;
  final Widget? chevron;
  final Color? chevronColor;

  // Styling & Geometry
  final Color? backgroundColor;
  final Color? expandedBackgroundColor;
  final BoxBorder? border;
  final BoxBorder? expandedBorder;
  final BorderRadius? borderRadius;
  final BorderRadius? expandedBorderRadius;
  final NixTilePosition? tilePosition;
  final double? elevation;
  final double? expandedElevation;

  // Padding & Divider
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry contentPadding;
  final bool showDivider;
  final Widget? divider;

  // Animation
  final Duration animationDuration;
  final Curve curve;

  // Ink Ripple & Splash
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;

  // Switch Tile properties
  final bool isSwitchTile;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool expandOnSwitch;
  final bool expandOnTap;
  final NixTileControlAffinity controlAffinity;
  final Key? switchKey;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;

  // Update properties
  final bool isUpdateTile;
  final String? version;
  final String? currentVersion;
  final List<String>? fixes;
  final Widget? fixesHeader;
  final String? titleText;
  final String? subtitleText;
  final String? releaseDate;
  final String? fileSize;
  final String? buildNumber;
  final Widget? badge;
  final String? badgeText;
  final bool? autoUpdate;
  final ValueChanged<bool>? onAutoUpdateChanged;
  final String? autoUpdateTitle;
  final String? autoUpdateSubtitle;
  final Widget? action;
  final VoidCallback? onUpdate;
  final String updateButtonText;
  final bool isUpdating;
  final double? progress;

  @override
  State<NixExpandable> createState() => _NixExpandableState();
}

class _NixExpandableState extends State<NixExpandable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _chevronAnimation;

  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded ?? widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _chevronAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_animation);
  }

  @override
  void didUpdateWidget(covariant NixExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != _isExpanded) {
      _setExpanded(widget.expanded!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setExpanded(bool value) {
    if (_isExpanded == value) return;
    setState(() => _isExpanded = value);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggleExpansion() {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    final next = !_isExpanded;
    _setExpanded(next);
    widget.onExpansionChanged?.call(next);
  }

  void _handleSwitchChanged(bool val) {
    widget.onSwitchChanged?.call(val);
    if (widget.expandOnSwitch) {
      _setExpanded(val);
      widget.onExpansionChanged?.call(val);
    }
  }

  BorderRadius _computeRadius(BuildContext context) {
    if (_isExpanded && widget.expandedBorderRadius != null) {
      return widget.expandedBorderRadius!;
    }
    if (widget.borderRadius != null) {
      return widget.borderRadius!;
    }

    final switchScope = NixSwitchScope.of(context);
    final listScope = NixListScope.of(context);

    final position = widget.tilePosition;
    final int index = switchScope?.index ?? listScope?.index ?? 0;
    final int totalCount = switchScope?.totalCount ?? listScope?.totalCount ?? 1;

    final bool isSingle = (position == NixTilePosition.single) ||
        (position == null && totalCount <= 1);

    if (isSingle) {
      // Stable 16px radius matching Nix card/container aesthetics
      return const BorderRadius.all(
        Radius.circular(NixListPhysics.containerRadius),
      );
    }

    final bool isFirst =
        (position == NixTilePosition.first) || (position == null && index == 0);
    final bool isLast = (position == NixTilePosition.last) ||
        (position == null && index == totalCount - 1);

    if (isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(NixListPhysics.outerItemRadius),
        topRight: Radius.circular(NixListPhysics.outerItemRadius),
        bottomLeft: Radius.circular(NixListPhysics.innerItemRadius),
        bottomRight: Radius.circular(NixListPhysics.innerItemRadius),
      );
    }
    if (isLast) {
      return const BorderRadius.only(
        topLeft: Radius.circular(NixListPhysics.innerItemRadius),
        topRight: Radius.circular(NixListPhysics.innerItemRadius),
        bottomLeft: Radius.circular(NixListPhysics.outerItemRadius),
        bottomRight: Radius.circular(NixListPhysics.outerItemRadius),
      );
    }
    return const BorderRadius.all(
      Radius.circular(NixListPhysics.innerItemRadius),
    );
  }

  Widget _buildChevron(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final effectiveColor = widget.chevronColor ?? colors.onSurfaceVariant;

    return RotationTransition(
      turns: _chevronAnimation,
      child: widget.chevron ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22.0,
            color: widget.enabled
                ? effectiveColor
                : effectiveColor.withValues(alpha: 0.38),
          ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    if (widget.header != null) {
      return widget.header!;
    }

    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    Widget? leading = widget.leading;
    Widget? title = widget.title;
    Widget? subtitle = widget.subtitle;
    Widget? trailing = widget.trailing;

    if (widget.isUpdateTile) {
      // Automatic update leading icon if none provided
      leading ??= Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.system_update_rounded,
            size: 20,
            color: nixTheme.primary ?? colors.primary,
          ),
        ),
      );

      // Automatic update title
      final effectiveTitleText = widget.titleText ?? 'Software Update';
      title ??= Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              effectiveTitleText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.version != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.14),
                borderRadius: NixGeometry.pillBorderRadius,
              ),
              child: Text(
                widget.version!.startsWith('v')
                    ? widget.version!
                    : 'v${widget.version}',
                style: (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11))
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  color: nixTheme.primary ?? colors.primary,
                ),
              ),
            ),
          ],
        ],
      );

      // Automatic update subtitle
      if (subtitle == null) {
        if (widget.subtitleText != null) {
          subtitle = Text(widget.subtitleText!);
        } else {
          final parts = <String>[];
          if (widget.currentVersion != null) {
            parts.add('Current: ${widget.currentVersion}');
          }
          if (widget.fileSize != null) {
            parts.add(widget.fileSize!);
          }
          if (widget.releaseDate != null) {
            parts.add(widget.releaseDate!);
          }
          if (parts.isNotEmpty) {
            subtitle = Text(parts.join(' • '));
          } else {
            subtitle = const Text('Tap to view update details');
          }
        }
      }

      // Update badge if provided
      if (widget.badge != null) {
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.badge!,
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        );
      } else if (widget.badgeText != null) {
        final badgeWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.14),
            borderRadius: NixGeometry.pillBorderRadius,
            border: Border.all(
              color: (nixTheme.primary ?? colors.primary).withValues(alpha: 0.28),
              width: 1.0,
            ),
          ),
          child: Text(
            widget.badgeText!,
            style: (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10))
                .copyWith(
              fontWeight: FontWeight.w600,
              color: nixTheme.primary ?? colors.primary,
              letterSpacing: 0.3,
            ),
          ),
        );
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            badgeWidget,
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        );
      }
    }

    Widget? switchWidget;
    if (widget.isSwitchTile && widget.switchValue != null) {
      switchWidget = NixSwitch(
        key: widget.switchKey,
        value: widget.switchValue!,
        onChanged: widget.enabled ? _handleSwitchChanged : null,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
        activeTrackColor: widget.activeTrackColor,
        inactiveTrackColor: widget.inactiveTrackColor,
        thumbColor: widget.thumbColor,
      );
    }

    final bool showLeadingChevron =
        widget.showChevron && widget.chevronPosition == NixExpandableChevronPosition.leading;
    final bool showTrailingChevron =
        widget.showChevron && widget.chevronPosition == NixExpandableChevronPosition.trailing;

    return Row(
      children: [
        if (showLeadingChevron) ...[
          _buildChevron(context),
          const SizedBox(width: 12),
        ],
        if (widget.isSwitchTile &&
            widget.controlAffinity == NixTileControlAffinity.leading &&
            switchWidget != null) ...[
          switchWidget,
          const SizedBox(width: 12),
        ],
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(
              color: widget.enabled
                  ? (_isExpanded
                      ? (nixTheme.primary ?? colors.primary)
                      : colors.onSurfaceVariant)
                  : colors.onSurfaceVariant.withValues(alpha: 0.38),
              size: 24.0,
            ),
            child: leading,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: (theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16))
                      .copyWith(
                    fontWeight: FontWeight.w500,
                    color: widget.enabled
                        ? colors.onSurface
                        : colors.onSurface.withValues(alpha: 0.38),
                  ),
                  child: title,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 13))
                      .copyWith(
                    color: widget.enabled
                        ? colors.onSurfaceVariant
                        : colors.onSurfaceVariant.withValues(alpha: 0.38),
                  ),
                  child: subtitle,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing,
        ],
        if (widget.isSwitchTile &&
            widget.controlAffinity == NixTileControlAffinity.trailing &&
            switchWidget != null) ...[
          const SizedBox(width: 12),
          switchWidget,
        ],
        if (showTrailingChevron) ...[
          const SizedBox(width: 10),
          _buildChevron(context),
        ],
      ],
    );
  }

  Widget _buildMetadataChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: NixGeometry.pillBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11))
                .copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final bodyWidgets = <Widget>[];

    if (widget.isUpdateTile) {
      // 1. Metadata chips row
      final hasMetadata = widget.version != null ||
          widget.buildNumber != null ||
          widget.releaseDate != null ||
          widget.fileSize != null;

      if (hasMetadata) {
        bodyWidgets.add(
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: [
              if (widget.version != null)
                _buildMetadataChip(
                  context,
                  Icons.tag_rounded,
                  widget.version!.startsWith('v')
                      ? widget.version!
                      : 'v${widget.version}',
                ),
              if (widget.buildNumber != null)
                _buildMetadataChip(
                  context,
                  Icons.numbers_rounded,
                  'Build ${widget.buildNumber}',
                ),
              if (widget.releaseDate != null)
                _buildMetadataChip(
                  context,
                  Icons.calendar_today_rounded,
                  widget.releaseDate!,
                ),
              if (widget.fileSize != null)
                _buildMetadataChip(
                  context,
                  Icons.storage_rounded,
                  widget.fileSize!,
                ),
            ],
          ),
        );
      }

      // 2. Fixes / Release Notes
      if (widget.fixes != null && widget.fixes!.isNotEmpty) {
        if (bodyWidgets.isNotEmpty) {
          bodyWidgets.add(const SizedBox(height: 12));
        }
        bodyWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fixesHeader != null)
                widget.fixesHeader!
              else
                Text(
                  "What's New",
                  style: (theme.textTheme.titleSmall ?? const TextStyle(fontSize: 14))
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              const SizedBox(height: 8),
              for (final fix in widget.fixes!) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: nixTheme.primary ?? colors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fix,
                          style: (theme.textTheme.bodyMedium ??
                                  const TextStyle(fontSize: 13))
                              .copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }

      // 3. Blank / Custom widgets support
      if (widget.child != null) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.add(widget.child!);
      }
      if (widget.children != null && widget.children!.isNotEmpty) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.addAll(widget.children!);
      }
      if (widget.expandedBuilder != null) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.add(widget.expandedBuilder!(context, _isExpanded));
      }

      // 4. Progress bar (downloading / installing)
      if (widget.progress != null || widget.isUpdating) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.progress != null
                        ? 'Downloading update... ${(widget.progress! * 100).toInt()}%'
                        : 'Preparing update...',
                    style: (theme.textTheme.bodySmall ??
                            const TextStyle(fontSize: 12))
                        .copyWith(
                      fontWeight: FontWeight.w500,
                      color: nixTheme.primary ?? colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: NixGeometry.pillBorderRadius,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    nixTheme.primary ?? colors.primary,
                  ),
                  minHeight: 6.0,
                ),
              ),
            ],
          ),
        );
      }

      // 5. Auto-update switch toggle
      if (widget.autoUpdate != null) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.add(
          NixSwitchTile(
            title: Text(
              widget.autoUpdateTitle ?? 'Automatic Updates',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              widget.autoUpdateSubtitle ??
                  'Download and install future updates automatically',
              style: const TextStyle(fontSize: 12),
            ),
            value: widget.autoUpdate!,
            onChanged: widget.onAutoUpdateChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            tilePosition: NixTilePosition.single,
          ),
        );
      }

      // 6. Action button (e.g. Update Now)
      if (widget.action != null) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 12));
        bodyWidgets.add(widget.action!);
      } else if (widget.onUpdate != null) {
        if (bodyWidgets.isNotEmpty) bodyWidgets.add(const SizedBox(height: 14));
        bodyWidgets.add(
          NixButton(
            onPressed: widget.isUpdating ? null : widget.onUpdate,
            label: Text(widget.updateButtonText),
            isLoading: widget.isUpdating,
            isExpanded: true,
            icon: const Icon(Icons.download_rounded, size: 18),
          ),
        );
      }
    } else {
      // Standard or switchTile expandable content:
      if (widget.child != null) {
        bodyWidgets.add(widget.child!);
      }
      if (widget.children != null) {
        bodyWidgets.addAll(widget.children!);
      }
      if (widget.expandedBuilder != null) {
        bodyWidgets.add(widget.expandedBuilder!(context, _isExpanded));
      }
    }

    return Padding(
      padding: widget.contentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bodyWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final computedRadius = _computeRadius(context);

    // Dynamic background color
    final baseBg = widget.backgroundColor ?? colors.surfaceContainerLow;
    Color effectiveBgColor = _isExpanded
        ? (widget.expandedBackgroundColor ?? baseBg)
        : baseBg;

    if (effectiveBgColor.a < 1.0) {
      effectiveBgColor = Color.alphaBlend(effectiveBgColor, colors.surface);
    }

    // Dynamic border & elevation
    final effectiveBorder = _isExpanded
        ? (widget.expandedBorder ?? widget.border)
        : widget.border;

    final effectiveElevation = _isExpanded
        ? (widget.expandedElevation ?? widget.elevation ?? 0.0)
        : (widget.elevation ?? 0.0);

    final List<BoxShadow>? effectiveShadow = effectiveElevation > 0
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: effectiveElevation * 2.5,
              offset: Offset(0, effectiveElevation),
            ),
          ]
        : null;

    final bool canTapToExpand = widget.enabled &&
        (!widget.isSwitchTile || widget.expandOnTap);

    return AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.curve,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: computedRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: computedRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: canTapToExpand ? _toggleExpansion : null,
                splashColor: widget.splashColor,
                highlightColor: widget.highlightColor,
                hoverColor: widget.hoverColor,
                child: Padding(
                  padding: widget.headerPadding ?? widget.padding,
                  child: _buildHeaderContent(context),
                ),
              ),
            ),
            if (widget.showDivider)
              FadeTransition(
                opacity: _animation,
                child: widget.divider ??
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
              ),
            ClipRect(
              child: SizeTransition(
                sizeFactor: _animation,
                alignment: Alignment.topCenter,
                child: _buildExpandedContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
