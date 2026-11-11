import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixExpandable - Core Expansion & Radii', () {
    testWidgets('Defaults to collapsed and expands when tapped', (tester) async {
      bool? expandedReported;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixExpandable(
              title: const Text('Title'),
              subtitle: const Text('Subtitle'),
              onExpansionChanged: (val) => expandedReported = val,
              child: const Text('Hidden Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Content exists in tree but SizeTransition heightFactor is 0
      final sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));
      expect(expandedReported, isNull);

      // Tap header to expand
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();

      final expandedSizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(expandedSizeTransition.sizeFactor.value, equals(1.0));
      expect(expandedReported, isTrue);

      // Tap header again to collapse
      await tester.tap(find.text('Title'));
      await tester.pumpAndSettle();

      final collapsedSizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(collapsedSizeTransition.sizeFactor.value, equals(0.0));
      expect(expandedReported, isFalse);
    });

    testWidgets('Single standalone item has consistent containerRadius (20px) both when collapsed and when expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixExpandable(
              title: const Text('Standalone Expandable'),
              child: const Text('Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Collapsed: stable container radius (20px)
      AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      BoxDecoration decoration = container.decoration as BoxDecoration;
      BorderRadius radius = decoration.borderRadius as BorderRadius;
      expect(radius.topLeft.x, equals(NixListPhysics.containerRadius));
      expect(radius.bottomRight.x, equals(NixListPhysics.containerRadius));

      // Expand: remains stable container radius (20px) (zero shape morphing)
      await tester.tap(find.text('Standalone Expandable'));
      await tester.pumpAndSettle();

      container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      decoration = container.decoration as BoxDecoration;
      radius = decoration.borderRadius as BorderRadius;
      expect(radius.topLeft.x, equals(NixListPhysics.containerRadius));
      expect(radius.bottomRight.x, equals(NixListPhysics.containerRadius));
    });

    testWidgets('Respects segmented radii inside NixSwitchList', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList(
              children: [
                NixExpandable(
                  key: const Key('exp_0'),
                  title: const Text('First'),
                  child: const Text('C0'),
                ),
                NixExpandable(
                  key: const Key('exp_1'),
                  title: const Text('Second'),
                  child: const Text('C1'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container0 = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('exp_0')),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius0 = (container0.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius0.topLeft.x, equals(12.0));
      expect(radius0.bottomLeft.x, equals(6.0));

      final container1 = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('exp_1')),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius1 = (container1.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius1.topLeft.x, equals(6.0));
      expect(radius1.bottomLeft.x, equals(12.0));
    });
  });

  group('NixExpandable.switchTile - Switch integration', () {
    testWidgets('Tapping switch toggles value without auto-expanding if expandOnSwitch is false', (tester) async {
      bool switchVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixExpandable.switchTile(
                  title: const Text('Dark Mode'),
                  switchValue: switchVal,
                  onSwitchChanged: (val) => setState(() => switchVal = val),
                  child: const Text('Dark Mode Options'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the switch itself
      await tester.tap(find.byType(NixSwitch));
      await tester.pumpAndSettle();
      expect(switchVal, isTrue);

      // Should still be collapsed
      final sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));

      // Tapping title expands
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      final expandedSize = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(expandedSize.sizeFactor.value, equals(1.0));
    });

    testWidgets('expandOnSwitch true automatically expands when switch is turned on', (tester) async {
      bool switchVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixExpandable.switchTile(
                  title: const Text('VPN'),
                  switchValue: switchVal,
                  expandOnSwitch: true,
                  onSwitchChanged: (val) => setState(() => switchVal = val),
                  child: const Text('VPN Server Settings'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(switchVal, isFalse);
      var sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));

      // Tap switch to turn on
      await tester.tap(find.byType(NixSwitch));
      await tester.pumpAndSettle();
      expect(switchVal, isTrue);

      sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(1.0));
    });
  });

  group('NixExpandable.update - App Update showcase', () {
    testWidgets('Renders header with version badge and auto-generates fixes list', (tester) async {
      bool updateClicked = false;
      bool autoUpdate = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixExpandable.update(
                  initiallyExpanded: true,
                  version: '2.5.0',
                  buildNumber: '142',
                  releaseDate: 'Nov 11, 2026',
                  fileSize: '48.2 MB',
                  badgeText: 'RECOMMENDED',
                  fixes: const [
                    'Added NixSwitchTile with segmented pill design',
                    'Fixed navigation action button positioning',
                    'Performance and responsiveness improvements',
                  ],
                  autoUpdate: autoUpdate,
                  onAutoUpdateChanged: (val) => setState(() => autoUpdate = val),
                  onUpdate: () => updateClicked = true,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Software Update'), findsOneWidget);
      expect(find.text('v2.5.0'), findsNWidgets(2)); // in header chip and metadata chip
      expect(find.text('RECOMMENDED'), findsOneWidget);

      // Check metadata chips
      expect(find.text('Build 142'), findsOneWidget);
      expect(find.text('Nov 11, 2026'), findsOneWidget);
      expect(find.text('48.2 MB'), findsOneWidget);

      // Check fixes
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Added NixSwitchTile with segmented pill design'), findsOneWidget);
      expect(find.text('Fixed navigation action button positioning'), findsOneWidget);
      expect(find.text('Performance and responsiveness improvements'), findsOneWidget);

      // Check auto-update toggle
      expect(find.text('Automatic Updates'), findsOneWidget);
      await tester.tap(find.text('Automatic Updates'));
      await tester.pumpAndSettle();
      expect(autoUpdate, isTrue);

      // Check action button
      expect(find.text('Update Now'), findsOneWidget);
      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();
      expect(updateClicked, isTrue);
    });

    testWidgets('Supports blank to add any widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixExpandable.update(
              initiallyExpanded: true,
              version: '3.0.0',
              child: Container(
                key: const Key('custom_widget_1'),
                height: 50,
                color: Colors.blue,
                child: const Text('Custom Banner Widget'),
              ),
              children: const [
                Text('Custom Item A'),
                Text('Custom Item B'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_widget_1')), findsOneWidget);
      expect(find.text('Custom Banner Widget'), findsOneWidget);
      expect(find.text('Custom Item A'), findsOneWidget);
      expect(find.text('Custom Item B'), findsOneWidget);
    });

    testWidgets('Renders progress bar when progress is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NixExpandable.update(
              initiallyExpanded: true,
              version: '1.2.0',
              progress: 0.65,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Downloading update... 65%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}

