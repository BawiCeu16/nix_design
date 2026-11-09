import 'package:flutter/material.dart';
import 'nix_theme_data.dart';

/// An inherited widget that overrides [NixThemeData] for a subtree of widgets.
///
/// While [NixThemeData] integrates automatically with [ThemeData.extensions],
/// [NixTheme] provides a declarative syntax for localized style overrides:
///
/// ```dart
/// NixTheme(
///   data: NixThemeData(primary: Colors.deepPurple),
///   child: NixButton(onPressed: () {}, label: Text('Custom Nix')),
/// )
/// ```
class NixTheme extends InheritedWidget {
  const NixTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The [NixThemeData] provided to descendants.
  final NixThemeData data;

  /// Retrieves the nearest [NixThemeData] from [context], falling back to
  /// [ThemeData.extensions] or Flutter's native [Theme.of].
  static NixThemeData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<NixTheme>();
    if (inherited != null) {
      return inherited.data.resolveWithTheme(Theme.of(context));
    }
    return NixThemeData.of(context);
  }

  @override
  bool updateShouldNotify(NixTheme oldWidget) => data != oldWidget.data;
}

/// Convenience extensions on [BuildContext] for ergonomic Flutter developer UX.
extension NixContextX on BuildContext {
  /// The active [NixThemeData], respecting app [ThemeData] and any [NixTheme] overrides.
  NixThemeData get nixTheme => NixTheme.of(this);

  /// The active [ColorScheme] from the app's [ThemeData].
  ColorScheme get nixColors => Theme.of(this).colorScheme;

  /// The active [TextTheme] from the app's [ThemeData].
  TextTheme get nixTypography => Theme.of(this).textTheme;

  /// Whether the ambient theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
