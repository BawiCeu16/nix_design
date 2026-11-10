import 'package:flutter/material.dart';

/// The behavior executed when a swipe gesture crosses the action threshold.
enum NixSwipeActionType {
  /// Dismisses and collapses the item, removing it from the list.
  dismiss,

  /// Triggers the action callback and springs the item back into its resting position.
  action,
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
  }) : assert(
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
}

