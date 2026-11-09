# nix_design

> [!NOTE]
> **Open Source for Nix Projects**: This package is open source and hosted on GitHub for direct use across **Nix projects** via Git dependencies. It is intentionally not published on [pub.dev](https://pub.dev).

A modern, pill-first custom Flutter design system. Every widget features smooth stadium/capsule pill aesthetics, mirrors Flutter's native developer ergonomics, and automatically adapts to your app's `ThemeData`, `ColorScheme`, and `TextTheme`.

## Installation

Add `nix_design` directly from GitHub to your project's `pubspec.yaml`:

```yaml
dependencies:
  nix_design:
    git:
      url: https://github.com/BawiCeu16/nix_design.git
      ref: main
```

## Highlights

- **Pure Stadium / Pill Geometry**: Buttons, chips, segmented controls, switches, cards, dialogs, and snackbars all use cohesive pill styling (`StadiumBorder`, `Radius.circular(9999)`).
- **Material 3 Expressive Shape States**: Buttons dynamically morph their corners from full stadium pills to expressive squircles/rounded rectangles on press and hold without shrinking button bounds.
- **Flutter Native Developer UX**: Uses Flutter's idiomatic constructors, parameters (`onPressed`, `onChanged`, `controller`, `prefixIcon`, etc.), semantics, and standard interaction patterns with zero learning curve.
- **App Theme Reactive**: Automatically derives styling from `Theme.of(context).colorScheme` and `textTheme`. Light mode, Dark mode, or dynamic color seed switching seamlessly updates all Nix widgets with zero configuration.
- **Customizable**: Extend or override tokens easily via `ThemeData.extensions: [NixThemeData(...)]` or local `NixTheme` widget.

## Component Catalog

- **Buttons**: `NixButton` (`.filled`, `.tonal`, `.outlined`, `.text`, `.ghost`), `NixIconButton`, `NixButtonGroup`
- **Inputs**: `NixSwitch`
- **Chips**: `NixChip`, `NixFilterChip`
- **Navigation**: `NixSegmentedControl`, `NixTabBar`, `NixBottomBar`
- **Surfaces**: `NixCard` (`.pill`, `outlined`, `filled`)
- **Feedback**: `NixSnackBar`, `NixDialog`, `showNixDialog`

## Quick Start

### 1. Buttons

```dart
// Filled pill button
NixButton.filled(
  onPressed: () => print('Pressed'),
  icon: const Icon(Icons.send_rounded),
  label: const Text('Send Message'),
)

// Outlined pill button
NixButton.outlined(
  onPressed: () {},
  label: const Text('Cancel'),
)

// Loading state
NixButton(
  isLoading: true,
  onPressed: () {},
  child: const Text('Submit'),
)
```

### 2. Switch

```dart
// Stadium pill switch
NixSwitch(
  value: isEnabled,
  onChanged: (val) => setState(() => isEnabled = val),
)
```

### 3. Segmented Control

```dart
NixSegmentedControl<int>(
  value: selectedIndex,
  onChanged: (newVal) => setState(() => selectedIndex = newVal),
  items: const [
    NixSegment(value: 0, label: 'Day', icon: Icon(Icons.wb_sunny_rounded)),
    NixSegment(value: 1, label: 'Week', icon: Icon(Icons.view_week_rounded)),
    NixSegment(value: 2, label: 'Month', icon: Icon(Icons.calendar_month_rounded)),
  ],
)
```

### 4. Chips

```dart
// Filter Chip
NixFilterChip(
  label: const Text('Design'),
  selected: isSelected,
  onSelected: (val) => setState(() => isSelected = val),
)

// Deletable Chip
NixChip(
  avatar: const Icon(Icons.person, size: 14),
  label: const Text('Design System'),
  onDeleted: () {},
)
```

### 5. Floating Navigation Bar

> [!IMPORTANT]
> **Scaffold Integration (`extendBody: true`)**:
> When using `NixBottomBar`, always place it in `Scaffold.bottomNavigationBar` with `extendBody: true`.
> This allows your scrollable body content to extend to the bottom edge of the screen and scroll smoothly underneath the floating pill navigation bar.
>
> **Avoid Using a `Stack`**:
> Manually overlaying `NixBottomBar` on top of your page inside a `Stack` is **not recommended**. Using `Scaffold(bottomNavigationBar: ..., extendBody: true)` is Flutter's official pattern—it automatically coordinates with system navigation bars, handles keyboard insets (`resizeToAvoidBottomInset`), and preserves proper accessibility focus order.

```dart
Scaffold(
  extendBody: true, // Recommended: content flows underneath the floating pill navigation bar!
  bottomNavigationBar: NixBottomBar(
    scrollController: scrollController, // Auto hide & shrink on scroll (tap bar or item to unshrink)
    shrinkScale: 0.92, // Subtle, polished shrink scale (reduces margin & scale)
    currentIndex: currentIndex,
    onTap: (index) => setState(() => currentIndex = index),
    // Handle long-press on any item to trigger popups, dialogs, etc.
    onLongPress: (index) {
      showNixDialog(
        context: context,
        builder: (ctx) => NixDialog(
          title: Text('Item $index Options'),
          content: const Text('Long-press triggered popup!'),
        ),
      );
    },
    // All items have equal dynamic width by default
    equalWidth: true,
    // Responsive max width (defaults to 560.0 for polished floating pill on wide screens)
    maxWidth: 560.0,
    items: const [
      // Icon + label (label is placed neatly under the icon)
      NixBottomBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      // Only icon (no label)
      NixBottomBarItem(
        icon: Icon(Icons.widgets_outlined),
      ),
      // Only text (no icon)
      NixBottomBarItem(
        label: 'Docs',
      ),
    ],
    // Separate companion action button placed beside the bar (left or right)
    action: NixIconButton.filled(
      icon: const Icon(Icons.search_rounded),
      onPressed: () {},
    ),
    actionPosition: NixBarActionPosition.right, // or NixBarActionPosition.left
  ),
  body: ListView( ... ),
)
```

### 6. Dialogs & Snackbars

```dart
// Floating Stadium Pill SnackBar (floats over all layers with dynamic width and slide in/out)
NixSnackBar.show(
  context,
  position: NixSnackBarPosition.bottom, // or NixSnackBarPosition.top
  message: 'Settings saved successfully!',
  icon: const Icon(Icons.check_circle_rounded),
  actionLabel: 'Undo',
  onAction: () {},
);

// Pill Modal Dialog
showNixDialog(
  context: context,
  builder: (ctx) => NixDialog(
    icon: const Icon(Icons.info_rounded),
    title: const Text('Confirm Action'),
    content: const Text('Do you want to proceed with this operation?'),
    actions: [
      NixButton.ghost(
        label: const Text('Cancel'),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
      NixButton.filled(
        label: const Text('Confirm'),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
    ],
  ),
);
```

## Running the Example App
The package comes with a full interactive showcase demonstrating dynamic theme seed switching, dark mode toggle, and all components:

```bash
cd example
flutter run
```
