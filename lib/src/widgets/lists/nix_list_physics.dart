import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Physics and geometry calculations for [NixListView] and [NixListItem].
///
/// Implements:
/// - Dynamic segmented corner radii (16px container, 12px outer, 6px inner/neighbour).
/// - Dynamic corner radius morphing (14px detached pill on swipe, selection, or playback).
/// - Dynamic neighbor sealing (adjacent cards morph to 12px when a card detaches or swipes).
/// - Critically-damped spring physics for smooth snap-backs.
class NixListPhysics {
  const NixListPhysics._();

  /// Default container border radius (16px).
  static const double containerRadius = 16.0;

  /// Default outer corner radius for top-of-first, bottom-of-last, or isolated items (12px).
  static const double outerItemRadius = 12.0;

  /// Default inner corner radius between adjacent items (6px).
  static const double innerItemRadius = 6.0;

  /// Default radius for detached items (e.g. active/playing or selected) (12px).
  static const double detachedItemRadius = 12.0;

  /// Proximity reach distance (in logical pixels) within which a dragged card
  /// begins squishing and displacing adjacent neighbor cards.
  static const double defaultReachDistance = 80.0;

  /// Computes the dynamic segmented [BorderRadius] for an item in [NixListView].
  ///
  /// - If [isDragged] is true, the item detaches into an isolated pill card
  ///   with [detachedRadius] on all 4 corners.
  /// - If [totalCount] <= 1: all corners are [outerRadius] (12px).
  /// - Top corners: [outerRadius] (12px) if first item (index 0) or if the
  ///   previous neighbor is detached or not in the same state;
  ///   otherwise [innerRadius] (6px) when sharing contiguous selected/playing state.
  /// - Bottom corners: [outerRadius] (12px) if last item (index count - 1)
  ///   or if the next neighbor is detached or not in the same state;
  ///   otherwise [innerRadius] (6px) when sharing contiguous selected/playing state.
  /// - Dynamically applies neighbor reach shape deformation via [squishTopReach]
  ///   and [squishBottomReach].
  static BorderRadius computeSegmentedRadius({
    required int index,
    required int totalCount,
    bool isSelected = false,
    bool isPlaying = false,
    bool isDragged = false,
    bool prevDetached = false,
    bool nextDetached = false,
    bool prevSameState = false,
    bool nextSameState = false,
    double squishTopReach = 0.0,
    double squishBottomReach = 0.0,
    double outerRadius = outerItemRadius,
    double innerRadius = innerItemRadius,
    double detachedRadius = outerItemRadius,
  }) {
    if (isDragged) {
      return BorderRadius.all(Radius.circular(detachedRadius));
    }

    if (totalCount <= 1) {
      return BorderRadius.all(Radius.circular(outerRadius));
    }

    // Top corners: 12px if first or previous neighbor detached / different state, else 6px
    final double baseTop;
    if (isSelected || isPlaying) {
      baseTop = (index == 0 || !prevSameState) ? outerRadius : innerRadius;
    } else {
      baseTop = (index == 0 || prevDetached) ? outerRadius : innerRadius;
    }

    // Bottom corners: 12px if last or next neighbor detached / different state, else 6px
    final double baseBottom;
    if (isSelected || isPlaying) {
      baseBottom = (index == totalCount - 1 || !nextSameState)
          ? outerRadius
          : innerRadius;
    } else {
      baseBottom = (index == totalCount - 1 || nextDetached)
          ? outerRadius
          : innerRadius;
    }

    // Shape morphing under reach compression (squish)
    final effectiveTop = (baseTop - (squishTopReach * 3.0)).clamp(3.0, 16.0);
    final effectiveBottom = (baseBottom - (squishBottomReach * 3.0)).clamp(
      3.0,
      16.0,
    );

    return BorderRadius.only(
      topLeft: Radius.circular(effectiveTop),
      topRight: Radius.circular(effectiveTop),
      bottomLeft: Radius.circular(effectiveBottom),
      bottomRight: Radius.circular(effectiveBottom),
    );
  }

  /// Calculates the reach factor (0.0 to 1.0) of an item affecting
  /// an adjacent neighbor card.
  ///
  /// Can be calculated from horizontal swipe drag progress ([swipeOffset] and [threshold])
  /// or from vertical spatial proximity ([dragCenterY] and [neighborCenterY]).
  static double computeReachFactor({
    double? swipeOffset,
    double? threshold,
    double? dragCenterY,
    double? neighborCenterY,
    double reachDistance = defaultReachDistance,
  }) {
    if (swipeOffset != null) {
      final t = threshold ?? 110.0;
      if (t <= 0.0) return 0.0;
      return (swipeOffset.abs() / t).clamp(0.0, 1.0);
    }
    if (dragCenterY != null && neighborCenterY != null) {
      final distance = (dragCenterY - neighborCenterY).abs();
      if (distance >= reachDistance) return 0.0;
      return (1.0 - (distance / reachDistance)).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  /// Computes the spring-driven vertical displacement offset of an adjacent card
  /// during swipe drag.
  static double computeDisplacementOffset({
    required double reachFactor,
    required bool isDraggedAbove,
    double maxDisplacement = 6.0,
  }) {
    // If dragged card is above neighbor, displace neighbor down (+Y).
    // If dragged card is below neighbor, displace neighbor up (-Y).
    final direction = isDraggedAbove ? 1.0 : -1.0;
    return direction * reachFactor * maxDisplacement;
  }

  /// Computes volume-preserving squish scale factors for an adjacent card.
  ///
  /// Compresses along the displacement axis (Y) while subtly expanding
  /// along the orthogonal axis (X) to simulate physical squish elasticity.
  static ({double scaleX, double scaleY}) computeSquishScale({
    required double reachFactor,
    double maxCompression = 0.07,
    double maxStretch = 0.035,
  }) {
    final scaleY = 1.0 - (reachFactor * maxCompression);
    final scaleX = 1.0 + (reachFactor * maxStretch);
    return (scaleX: scaleX, scaleY: scaleY);
  }

  /// Computes the subtle horizontal pull offset & vertical squish imparted
  /// onto adjacent neighbors when an item is swiped horizontally.
  static ({double offsetX, double offsetY, double scaleY})
  computeSwipeNeighborPull({
    required double swipeOffset,
    required double itemWidth,
    required bool isNeighborAbove,
  }) {
    if (itemWidth <= 0 || swipeOffset == 0.0) {
      return (offsetX: 0.0, offsetY: 0.0, scaleY: 1.0);
    }

    final ratio = (swipeOffset / itemWidth).clamp(-1.0, 1.0);
    final magnitude = ratio.abs();

    // Subtle elastic horizontal follow-through
    final offsetX = ratio * 6.0;

    // Vertical pull towards the swiped item
    final offsetY = isNeighborAbove ? (magnitude * 3.0) : -(magnitude * 3.0);

    // Subtle compression
    final scaleY = 1.0 - (magnitude * 0.025);

    return (offsetX: offsetX, offsetY: offsetY, scaleY: scaleY);
  }
}

/// A critically-damped spring curve used for organic physical snap-backs.
class NixSpringCurve extends Curve {
  const NixSpringCurve({
    this.damping = 20.0,
    this.stiffness = 180.0,
    this.mass = 1.0,
  });

  final double damping;
  final double stiffness;
  final double mass;

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    // Damped harmonic oscillation curve
    final omega = math.sqrt(stiffness / mass);
    final zeta = damping / (2 * math.sqrt(stiffness * mass));
    final decay = math.exp(-zeta * omega * t);
    final omegaD = omega * math.sqrt(math.max(0.0, 1.0 - zeta * zeta));

    return 1.0 -
        decay *
            (math.cos(omegaD * t) +
                (zeta / math.sqrt(math.max(0.001, 1.0 - zeta * zeta))) *
                    math.sin(omegaD * t));
  }
}
