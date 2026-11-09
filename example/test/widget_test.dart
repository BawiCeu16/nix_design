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
    expect(find.text('Widgets Options'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Widgets Options'), findsNothing);
  });
}
