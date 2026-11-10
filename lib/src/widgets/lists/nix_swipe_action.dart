import 'package:flutter/material.dart';

/// The behavior executed when a swipe gesture crosses the action threshold.
enum NixSwipeActionType {
  /// Dismisses and collapses the item, removing it from the list.
  dismiss,

  /// Triggers the action callback and springs the item back into its resting position.
  action,
}

/// The swipe interaction mode for [NixListItem] and [NixListView].
enum NixSwipeMode {
  /// Swiping slides the card all the way through and dismisses it, collapsing its height.
  dismiss,

  /// Swiping reveals interactive action buttons (e.g. Share, Archive, Collaborator, Edit)
  /// that snap open and can be tapped.
  actions,
}

/// Permitted swipe directions for [NixListItem] and [NixListView].
enum NixSwipeDirection {
  /// Both start-to-end (swipe right) and end-to-start (swipe left) gestures are enabled.
  both,

  /// Only swipe right (primary / start-to-end) is enabled.
  rightOnly,

  /// Only swipe left (secondary / end-to-start) is enabled.
  leftOnly,

  /// All horizontal swipe gestures are disabled.
  disabled,
}

/// Defines an independent swipe action for [NixListItem] (left or right).
///
/// Swipe actions allow swipe-to-dismiss (e.g. delete or archive) or swipe-to-trigger
/// (e.g. toggle favorite, queue next, or mark read) with independent thresholds,
/// icons, labels, colors, and callbacks.
class NixSwipeAction {
  /// Creates a [NixSwipeAction].
  const NixSwipeAction({
    required this.onTriggered,
    this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.threshold = 0.35,
    this.actionType = NixSwipeActionType.dismiss,
    this.confirmDismiss,
    this.builder,
    this.hapticFeedback = true,
    this.centeredIcon = false,
    bool? emailStyle,
  })  : emailStyle = emailStyle ?? centeredIcon,
        assert(
          threshold > 0.0 && threshold < 1.0,
          'Threshold must be strictly between 0.0 and 1.0',
        );

  /// Callback executed when the swipe gesture triggers this action.
  final VoidCallback onTriggered;

  /// Optional leading or primary icon displayed in the action background.
  final Widget? icon;

  /// Optional text label displayed in the action background.
  final Widget? label;

  /// Custom background color revealed as the user swipes.
  ///
  /// If null, defaults to [ColorScheme.error] for destructive dismiss actions,
  /// or [ColorScheme.primary] / [ColorScheme.secondary] for trigger actions.
  final Color? backgroundColor;

  /// Foreground color for [icon] and [label].
  final Color? foregroundColor;

  /// The fraction of the item width (from 0.0 to 1.0) that must be swiped
  /// to arm and trigger the action. Defaults to `0.35`.
  final double threshold;

  /// Whether the item collapses and dismisses, or triggers and springs back.
  final NixSwipeActionType actionType;

  /// Optional confirmation callback before a dismiss action is finalized.
  /// If it returns `false`, the item springs back and is not dismissed.
  final Future<bool> Function()? confirmDismiss;

  /// Optional custom builder for the revealed action surface.
  ///
  /// Provides the [BuildContext] and normalized swipe progress (0.0 to 1.0+).
  final Widget Function(BuildContext context, double progress)? builder;

  /// Whether to produce subtle haptic feedback when crossing the threshold.
  final bool hapticFeedback;

  /// Whether the icon is centered in the action background (Gmail style).
  final bool centeredIcon;

  /// Whether this action uses email/Gmail style: circle shape adapting to the
  /// swipe side and stadium pilled style on both sides.
  final bool emailStyle;

  /// Creates a Gmail-style green archive swipe action.
  factory NixSwipeAction.gmailArchive({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
    Future<bool> Function()? confirmDismiss,
    bool centeredIcon = true,
    bool? emailStyle,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.archive_rounded),
      label: label,
      backgroundColor: backgroundColor ?? const Color(0xFF2E7D32),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: NixSwipeActionType.dismiss,
      confirmDismiss: confirmDismiss,
      centeredIcon: centeredIcon,
      emailStyle: emailStyle ?? true,
    );
  }

  /// Creates a Gmail-style red delete swipe action.
  factory NixSwipeAction.gmailDelete({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
    Future<bool> Function()? confirmDismiss,
    bool centeredIcon = true,
    bool? emailStyle,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.delete_outline_rounded),
      label: label,
      backgroundColor: backgroundColor ?? const Color(0xFFC62828),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: NixSwipeActionType.dismiss,
      confirmDismiss: confirmDismiss,
      centeredIcon: centeredIcon,
      emailStyle: emailStyle ?? true,
    );
  }

  /// Creates a Share action button preset.
  factory NixSwipeAction.share({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.share_rounded),
      label: label ?? const Text('Share'),
      backgroundColor: backgroundColor ?? const Color(0xFF1976D2),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: NixSwipeActionType.action,
    );
  }

  /// Creates an Archive action button preset.
  factory NixSwipeAction.archive({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
    NixSwipeActionType actionType = NixSwipeActionType.action,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.archive_rounded),
      label: label ?? const Text('Archive'),
      backgroundColor: backgroundColor ?? const Color(0xFF2E7D32),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: actionType,
    );
  }

  /// Creates a Collaborator action button preset.
  factory NixSwipeAction.collaborator({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.person_add_rounded),
      label: label ?? const Text('Collaborator'),
      backgroundColor: backgroundColor ?? const Color(0xFF7B1FA2),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: NixSwipeActionType.action,
    );
  }

  /// Creates an Edit action button preset.
  factory NixSwipeAction.edit({
    VoidCallback? onTriggered,
    Widget? icon,
    Widget? label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return NixSwipeAction(
      onTriggered: onTriggered ?? () {},
      icon: icon ?? const Icon(Icons.edit_rounded),
      label: label ?? const Text('Edit'),
      backgroundColor: backgroundColor ?? const Color(0xFFE65100),
      foregroundColor: foregroundColor ?? Colors.white,
      actionType: NixSwipeActionType.action,
    );
  }
}
