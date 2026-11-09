import 'package:flutter/material.dart';

/// Geometry constants and helpers for the Nix Design System's signature pill aesthetic.
class NixGeometry {
  NixGeometry._();

  /// Very large radius value that guarantees a full stadium pill curve regardless of widget dimensions.
  static const double pillRadiusValue = 9999.0;

  /// Radius object representing full pill curvature.
  static const Radius pillRadius = Radius.circular(pillRadiusValue);

  /// [BorderRadius] representing full stadium curvature on all four corners.
  static const BorderRadius pillBorderRadius = BorderRadius.all(pillRadius);

  /// Standard [StadiumBorder] used across buttons, chips, and tags.
  static const StadiumBorder stadiumBorder = StadiumBorder();

  /// Generates a [StadiumBorder] with the specified border side.
  static StadiumBorder stadium({
    Color color = const Color(0x00000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    return StadiumBorder(
      side: BorderSide(
        color: color,
        width: width,
        style: style,
      ),
    );
  }

  /// Generates an [OutlineInputBorder] with stadium pill curves for [InputDecoration].
  static OutlineInputBorder pillOutlineInputBorder({
    BorderSide borderSide = BorderSide.none,
  }) {
    return OutlineInputBorder(
      borderRadius: pillBorderRadius,
      borderSide: borderSide,
    );
  }
}
