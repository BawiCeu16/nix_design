import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  testWidgets('ExampleApp renders pure nix_design package widgets', (tester) async {
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
    final homeFinder = find.ancestor(of: find.text('Home'), matching: find.byType(KeyedSubtree));
    final widgetsFinder = find.ancestor(of: find.text('Widgets'), matching: find.byType(KeyedSubtree));
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

  testWidgets('ExampleApp renders cleanly on narrow 350px screens without overflow', (tester) async {
    tester.view.physicalSize = const Size(350, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Scroll down through all showcase sections including popup menu
    await tester.scrollUntilVisible(find.text('Custom Popup Menu (Dual Gesture & Dynamic Corners)'), 200);
    expect(find.text('Custom Popup Menu (Dual Gesture & Dynamic Corners)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Top snackbar and popup interaction works smoothly without unwanted snackbars', (tester) async {
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
  });

  testWidgets('Switching category tabs via NixBottomBar shows dedicated category views', (tester) async {
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
  });

  testWidgets('Search actionbutton opens search bottom sheet and navigates to selected component', (tester) async {
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

    expect(find.widgetWithText(ListTile, 'Dynamic Corner Morphs'), findsOneWidget);

    // Tap result to navigate to Lists category
    await tester.tap(find.widgetWithText(ListTile, 'Dynamic Corner Morphs'));
    await tester.pumpAndSettle();

    // Verifies search sheet dismissed and navigated to Lists tab
    expect(find.byType(NixListView), findsOneWidget);
    expect(find.text('Midnight City Waves'), findsOneWidget);
  });

  testWidgets('NixBottomBar Playground toggles between standard and separated style with dynamic items', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Scroll to the Playground card
    await tester.scrollUntilVisible(find.text('NixBottomBar Playground'), 200);
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
    final pillFinder = find.ancestor(of: find.text('Home'), matching: find.byType(Material)).first;
    final pillRect = tester.getRect(pillFinder);
    expect(pillRect.left, equals(16.0));

    // Verify search action button is at BottomRight (800 - 16 = 784)
    final searchFinder = find.ancestor(of: find.byIcon(Icons.search_rounded), matching: find.byType(Material)).first;
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
    expect(find.text('Home'), findsNothing); // Label is hidden in icon only mode
    expect(find.byIcon(Icons.home_rounded), findsOneWidget); // Active icon shown

    await tester.tap(find.text('Text Only'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget); // Text label restored
    expect(find.byIcon(Icons.home_rounded), findsNothing); // Icon is hidden in text only mode
  });
}
