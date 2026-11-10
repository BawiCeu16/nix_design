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
}
