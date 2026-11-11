import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  testWidgets('ExampleApp renders pure nix_design package widgets', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Nix Design System'), findsWidgets);
    expect(find.byType(NixSegmentedControl<int>), findsOneWidget);
    expect(find.byType(NixBottomBar), findsOneWidget);
    expect(find.byType(NixButton), findsWidgets);
    expect(find.byType(NixCard), findsWidgets);

    await tester.scrollUntilVisible(find.byType(NixSwitch), 100);
    expect(find.byType(NixSwitch), findsOneWidget);

    // Test NixBottomBar equal dynamic widths
    final homeFinder = find.ancestor(
      of: find.text('Home'),
      matching: find.byType(KeyedSubtree),
    );
    final widgetsFinder = find.ancestor(
      of: find.text('Widgets'),
      matching: find.byType(KeyedSubtree),
    );
    final homeSize = tester.getSize(homeFinder);
    final widgetsSize = tester.getSize(widgetsFinder);
    expect(homeSize.width, equals(widgetsSize.width));

    // Test long press opens dialog
    await tester.longPress(find.text('Widgets'));
    await tester.pumpAndSettle();
    expect(find.byType(NixDialog), findsOneWidget);
    if (find.text('Close').evaluate().isNotEmpty) {
      await tester.tap(find.text('Close'));
    } else {
      await tester.tap(find.text('Dismiss'));
    }
    await tester.pumpAndSettle();
    expect(find.byType(NixDialog), findsNothing);

    // Test tapping AppBar info icon opens About dialog without overflow
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.byType(NixDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(NixDialog), findsNothing);
  });

  testWidgets(
    'ExampleApp renders cleanly on narrow 350px screens without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(350, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Scroll down through all showcase sections including popup menu
      await tester.scrollUntilVisible(
        find.text('Custom Popup Menu (Dual Gesture & Dynamic Corners)'),
        200,
      );
      expect(
        find.text('Custom Popup Menu (Dual Gesture & Dynamic Corners)'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Top snackbar and popup interaction works smoothly without unwanted snackbars',
    (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Tap 'Top' to show top snackbar
      await tester.tap(find.text('Top'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Top floating pill (slide down/up)'), findsOneWidget);

      // Tap popup in AppBar
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Profile menu item should be visible
      expect(find.text('Profile'), findsOneWidget);

      // Select Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Menu is closed, and last selected text is updated
      expect(find.text('Profile'), findsNothing);
    },
  );

  testWidgets(
    'Switching category tabs via NixBottomBar shows dedicated category views',
    (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Tap Lists tab
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();

      expect(find.byType(NixListView), findsOneWidget);
      expect(find.text('Midnight City Waves'), findsOneWidget);

      // Tap Feedback tab
      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Floating Pill Snackbars'), findsOneWidget);

      // Tap Widgets tab
      await tester.tap(find.text('Widgets'));
      await tester.pumpAndSettle();

      expect(find.text('NixButton Variants & Morphing'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Segmented Switch Tiles'), 200);
      expect(find.text('Segmented Switch Tiles'), findsOneWidget);
      expect(find.byType(NixSwitchTile), findsWidgets);
      expect(find.text('Wi-Fi Network'), findsOneWidget);

      // Tap Wi-Fi tile to toggle
      await tester.tap(find.text('Wi-Fi Network'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Search actionbutton opens search bottom sheet and navigates to selected component',
    (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Tap Search action button on NixBottomBar
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('NixButton'), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Corner');
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ListTile, 'Dynamic Corner Morphs'),
        findsOneWidget,
      );

      // Tap result to navigate to Lists category
      await tester.tap(find.widgetWithText(ListTile, 'Dynamic Corner Morphs'));
      await tester.pumpAndSettle();

      // Verifies search sheet dismissed and navigated to Lists tab
      expect(find.byType(NixListView), findsOneWidget);
      expect(find.text('Midnight City Waves'), findsOneWidget);
    },
  );

  testWidgets(
    'NixBottomBar Playground toggles between standard and separated style with dynamic items',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Scroll to the Playground card
      await tester.scrollUntilVisible(
        find.text('NixBottomBar Playground'),
        200,
      );
      expect(find.text('NixBottomBar Playground'), findsOneWidget);

      // Switch to Separated style
      await tester.tap(find.text('Separated'));
      await tester.pumpAndSettle();

      // Switch to 2 Items
      await tester.tap(find.text('2 Items'));
      await tester.pumpAndSettle();

      // Verify only 2 items are rendered in bottom bar
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Widgets'), findsOneWidget);
      expect(find.text('Lists'), findsNothing);

      // Verify navigation bar pill is at BottomLeft (margin is 16.0)
      final pillFinder = find
          .ancestor(of: find.text('Home'), matching: find.byType(Material))
          .first;
      final pillRect = tester.getRect(pillFinder);
      expect(pillRect.left, equals(16.0));

      // Verify search action button is at BottomRight (800 - 16 = 784)
      final searchFinder = find
          .ancestor(
            of: find.byIcon(Icons.search_rounded),
            matching: find.byType(Material),
          )
          .first;
      final searchRect = tester.getRect(searchFinder);
      expect(searchRect.right, equals(800.0 - 16.0));

      // Switch Action Position to Bottom Left
      await tester.tap(find.text('Bottom Left'));
      await tester.pumpAndSettle();

      final newSearchRect = tester.getRect(searchFinder);
      expect(newSearchRect.left, equals(16.0));

      final newPillRect = tester.getRect(pillFinder);
      expect(newPillRect.right, equals(800.0 - 16.0));

      // Test Item Content Types: Icon Only & Text Only
      await tester.tap(find.text('Icon Only'));
      await tester.pumpAndSettle();
      expect(
        find.text('Home'),
        findsNothing,
      ); // Label is hidden in icon only mode
      expect(
        find.byIcon(Icons.home_rounded),
        findsOneWidget,
      ); // Active icon shown

      await tester.tap(find.text('Text Only'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget); // Text label restored
      expect(
        find.byIcon(Icons.home_rounded),
        findsNothing,
      ); // Icon is hidden in text only mode
    },
  );

  testWidgets(
    'Renders NixExpandable update and switch tile showcases in Widgets tab',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Scroll to Widgets tab
      await tester.tap(find.text('Widgets'));
      await tester.pumpAndSettle();

      // Scroll down to Single Switch Tile and Expandable showcases
      await tester.scrollUntilVisible(find.text('Fast Charging'), 200);
      expect(
        find.text('Single Switch Tile (Pilled Corner Radius)'),
        findsOneWidget,
      );
      expect(find.text('Fast Charging'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Software Update'), 150);
      // Drag upwards so Software Update is clearly centered and not behind the floating bottom bar
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();

      expect(
        find.text('App Update Expandable (NixExpandable.update)'),
        findsOneWidget,
      );
      expect(find.text('Software Update'), findsOneWidget);
      expect(find.text('v2.5.0'), findsWidgets);
      expect(find.text('RECOMMENDED'), findsOneWidget);

      // Expand the update tile
      await tester.tap(find.text('Software Update'));
      await tester.pumpAndSettle();

      // Scroll down to view expanded update content
      await tester.scrollUntilVisible(find.text("What's New"), 150);
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Build 148'), findsOneWidget);
      expect(find.text('Nov 11, 2026'), findsOneWidget);
      expect(find.text('42.5 MB'), findsOneWidget);
      expect(find.text('Automatic Updates'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
      expect(
        find.textContaining(
          'Arbitrary custom widget: Package integrity verified',
        ),
        findsOneWidget,
      );

      // Test Expandable Switch Tile
      await tester.scrollUntilVisible(find.text('Nix Secure VPN'), 150);
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('Nix Secure VPN'), findsOneWidget);
      // Tapping the switch turns it on and auto-expands the card
      await tester.tap(find.text('Nix Secure VPN'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Connected Server: Frankfurt 04'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Version History native bottom sheet renders versions 1 to 9 with Single & Multi expand toggles',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Navigate to Widgets tab
      await tester.tap(find.text('Widgets'));
      await tester.pumpAndSettle();

      // Scroll to the Native Sheet showcase card
      await tester.scrollUntilVisible(
        find.text('Native Sheet: Releases v1 to v9'),
        150,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('Open Native Sheet (Versions 1 to 9)'), findsOneWidget);

      // Tap to open native Flutter modal bottom sheet
      await tester.tap(find.text('Open Native Sheet (Versions 1 to 9)'));
      await tester.pumpAndSettle();

      // Verify sheet title and versions header
      expect(find.text('Version History'), findsOneWidget);
      expect(find.text('Releases 1 to 9 • Software Changelog'), findsOneWidget);

      // Verify versions 9, 8, 7, etc. exist in the sheet
      expect(find.text('Nix Design System 9.0'), findsOneWidget);
      expect(find.text('Navigation Architecture'), findsOneWidget);

      // Initial state: Single Expand mode with Version 9.0 expanded
      expect(find.text('Single Expand'), findsOneWidget);
      expect(find.text('Single'), findsOneWidget);
      expect(find.text('Multi'), findsOneWidget);
      expect(
        find.text(
          'Dual expansion modes: Single accordion and multi-expand disclosure',
        ),
        findsOneWidget,
      );

      // In Single Expand mode: Tap Version 8.0.0
      await tester.tap(find.text('Navigation Architecture'));
      await tester.pumpAndSettle();

      // Version 8 should now be open, and Version 9 should be closed
      expect(
        find.text(
          'NixBottomBar: Separated floating action button with dynamic alignment',
        ),
        findsOneWidget,
      );
      // Version 9 fixes should be closed (sizeFactor = 0)
      final v9Finder = find.byKey(const ValueKey('version_9.0.0'));
      final v9SizeTransition = tester.widget<SizeTransition>(
        find.descendant(of: v9Finder, matching: find.byType(SizeTransition)),
      );
      expect(v9SizeTransition.sizeFactor.value, equals(0.0));

      // Toggle to Multi Expand mode
      await tester.tap(find.text('Multi'));
      await tester.pumpAndSettle();

      // In Multi Expand mode: Tap Version 9.0.0 again to expand it as well
      await tester.tap(find.text('Nix Design System 9.0'));
      await tester.pumpAndSettle();

      // Both Version 8 and Version 9 should now be open simultaneously
      expect(v9SizeTransition.sizeFactor.value, equals(1.0));
      final v8Finder = find.byKey(const ValueKey('version_8.0.0'));
      final v8SizeTransition = tester.widget<SizeTransition>(
        find.descendant(of: v8Finder, matching: find.byType(SizeTransition)),
      );
      expect(v8SizeTransition.sizeFactor.value, equals(1.0));

      // Tap Collapse All
      expect(find.text('Collapse All'), findsOneWidget);
      await tester.tap(find.text('Collapse All'));
      await tester.pumpAndSettle();
      expect(v9SizeTransition.sizeFactor.value, equals(0.0));
      expect(v8SizeTransition.sizeFactor.value, equals(0.0));

      // Tap Expand All
      expect(find.text('Expand All'), findsOneWidget);
      await tester.tap(find.text('Expand All'));
      await tester.pumpAndSettle();
      expect(v9SizeTransition.sizeFactor.value, equals(1.0));
      expect(v8SizeTransition.sizeFactor.value, equals(1.0));

      // Close the bottom sheet via close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Releases 1 to 9 • Software Changelog'), findsNothing);
    },
  );

  testWidgets(
    'Renders NixWaveSlider with active squiggly wave and smooth scrub interaction',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Navigate to Widgets tab
      await tester.tap(find.text('Widgets'));
      await tester.pumpAndSettle();

      // Scroll to Squiggly Wave Slider
      await tester.scrollUntilVisible(
        find.text('Squiggly Wave Slider (Music Player)'),
        150,
      );
      expect(find.text('Squiggly Wave Slider (Music Player)'), findsOneWidget);
      expect(
        find.text('Active squiggly wave • Sleek pill thumb • Rounded ends'),
        findsOneWidget,
      );

      // Initial timestamps
      expect(find.text('1:24'), findsOneWidget);
      expect(find.text('3:45'), findsOneWidget);

      // Toggle Play / Pause button
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      // Pause it again so test can settle
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Drag the wave slider to scrub smoothly
      final waveSliderFinder = find.byType(NixWaveSlider);
      final sliderCenter = tester.getCenter(waveSliderFinder);
      await tester.dragFrom(sliderCenter, const Offset(60, 0));
      await tester.pumpAndSettle();

      // Timestamp should have updated to later position (not 1:24)
      expect(find.text('1:24'), findsNothing);
      expect(find.text('3:45'), findsOneWidget);
    },
  );

  testWidgets(
    'Toggles DynamicSchemeVariant.expressive via toggle button and updates theme',
    (tester) async {
      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Expressive toggle chip is rendered in Theme & Colors card
      expect(find.text('Expressive'), findsOneWidget);

      // Verify initial theme uses DynamicSchemeVariant.expressive (active)
      final initialContext = tester.element(find.byType(ExampleHomePage));
      final initialScope = AppThemeScope.of(initialContext);
      expect(initialScope.useExpressiveScheme, isTrue);

      // Tap the Expressive toggle button in the card header
      await tester.tap(find.text('Expressive'));
      await tester.pumpAndSettle();

      // Verify theme scope updated to disabled
      final updatedContext = tester.element(find.byType(ExampleHomePage));
      final updatedScope = AppThemeScope.of(updatedContext);
      expect(updatedScope.useExpressiveScheme, isFalse);

      // Tap the AppBar auto_awesome toggle button to enable it again
      final appBarToggle = find.byTooltip(
        'Expressive Scheme: OFF (DynamicSchemeVariant.tonalSpot)',
      );
      expect(appBarToggle, findsOneWidget);
      await tester.tap(appBarToggle);
      await tester.pumpAndSettle();

      final reenabledContext = tester.element(find.byType(ExampleHomePage));
      final reenabledScope = AppThemeScope.of(reenabledContext);
      expect(reenabledScope.useExpressiveScheme, isTrue);
    },
  );
}
