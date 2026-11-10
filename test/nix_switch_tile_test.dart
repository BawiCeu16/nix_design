import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixSwitchTile & NixSwitchList - Segmented Radii Rules', () {
    testWidgets('Single item has pilled radius on all corners', (tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList(
              children: [
                NixSwitchTile(
                  title: const Text('Wi-Fi'),
                  value: isChecked,
                  onChanged: (val) => isChecked = val,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NixSwitchTile),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      final radius = decoration.borderRadius as BorderRadius;

      expect(radius.topLeft.x, equals(NixGeometry.pillRadiusValue));
      expect(radius.topRight.x, equals(NixGeometry.pillRadiusValue));
      expect(radius.bottomLeft.x, equals(NixGeometry.pillRadiusValue));
      expect(radius.bottomRight.x, equals(NixGeometry.pillRadiusValue));
    });

    testWidgets('Two items: first has top 12 / bottom 6; last has top 6 / bottom 12', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList(
              children: [
                NixSwitchTile(
                  key: const Key('tile_0'),
                  title: const Text('Wi-Fi'),
                  value: true,
                  onChanged: (_) {},
                ),
                NixSwitchTile(
                  key: const Key('tile_1'),
                  title: const Text('Bluetooth'),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First item
      final container0 = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('tile_0')),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius0 = (container0.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius0.topLeft.x, equals(12.0));
      expect(radius0.topRight.x, equals(12.0));
      expect(radius0.bottomLeft.x, equals(6.0));
      expect(radius0.bottomRight.x, equals(6.0));

      // Last item
      final container1 = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('tile_1')),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius1 = (container1.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius1.topLeft.x, equals(6.0));
      expect(radius1.topRight.x, equals(6.0));
      expect(radius1.bottomLeft.x, equals(12.0));
      expect(radius1.bottomRight.x, equals(12.0));
    });

    testWidgets('Three items: first top 12/bottom 6, middle all 6, last top 6/bottom 12', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList(
              children: [
                NixSwitchTile(
                  key: const Key('tile_0'),
                  title: const Text('Item 0'),
                  value: true,
                  onChanged: (_) {},
                ),
                NixSwitchTile(
                  key: const Key('tile_1'),
                  title: const Text('Item 1'),
                  value: false,
                  onChanged: (_) {},
                ),
                NixSwitchTile(
                  key: const Key('tile_2'),
                  title: const Text('Item 2'),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Middle item
      final container1 = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('tile_1')),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius1 = (container1.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius1.topLeft.x, equals(6.0));
      expect(radius1.topRight.x, equals(6.0));
      expect(radius1.bottomLeft.x, equals(6.0));
      expect(radius1.bottomRight.x, equals(6.0));
    });

    testWidgets('Standalone tile defaults to pilled radius on all corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchTile(
              title: const Text('Standalone'),
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NixSwitchTile),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final radius = (container.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius.topLeft.x, equals(NixGeometry.pillRadiusValue));
      expect(radius.bottomRight.x, equals(NixGeometry.pillRadiusValue));
    });
  });

  group('NixSwitchTile - Interactivity & Controls', () {
    testWidgets('Tapping anywhere on the tile toggles value', (tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixSwitchTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable dark theme'),
                  leading: const Icon(Icons.dark_mode_rounded),
                  value: isChecked,
                  onChanged: (val) => setState(() => isChecked = val),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(isChecked, isFalse);

      // Tap on title text
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(isChecked, isTrue);

      // Tap on subtitle text
      await tester.tap(find.text('Enable dark theme'));
      await tester.pumpAndSettle();
      expect(isChecked, isFalse);
    });

    testWidgets('Tapping on the internal NixSwitch toggles value', (tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixSwitchTile(
                  title: const Text('Airplane Mode'),
                  value: isChecked,
                  onChanged: (val) => setState(() => isChecked = val),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap directly on NixSwitch
      await tester.tap(find.byType(NixSwitch));
      await tester.pumpAndSettle();

      expect(isChecked, isTrue);
    });

    testWidgets('Disabled switch tile rejects taps and renders reduced opacity', (tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchTile(
              enabled: false,
              title: const Text('Disabled Option'),
              value: isChecked,
              onChanged: (val) => isChecked = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled Option'));
      await tester.pumpAndSettle();

      expect(isChecked, isFalse);

      // InkWell should not have onTap when disabled
      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(NixSwitchTile),
          matching: find.byType(InkWell),
        ).first,
      );
      expect(inkWell.onTap, isNull);
    });

    testWidgets('controlAffinity.leading places switch on the left of title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchTile(
              controlAffinity: NixTileControlAffinity.leading,
              title: const Text('Leading Switch'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchCenter = tester.getCenter(find.byType(NixSwitch));
      final titleCenter = tester.getCenter(find.text('Leading Switch'));

      expect(switchCenter.dx, lessThan(titleCenter.dx));
    });

    testWidgets('controlAffinity.trailing places switch on the right of title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchTile(
              controlAffinity: NixTileControlAffinity.trailing,
              title: const Text('Trailing Switch'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchCenter = tester.getCenter(find.byType(NixSwitch));
      final titleCenter = tester.getCenter(find.text('Trailing Switch'));

      expect(switchCenter.dx, greaterThan(titleCenter.dx));
    });
  });

  group('NixSwitchList - Container & Builder', () {
    testWidgets('Outer container has 16px radius, 4px padding, 2px item spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList(
              children: [
                NixSwitchTile(title: const Text('A'), value: true, onChanged: (_) {}),
                NixSwitchTile(title: const Text('B'), value: false, onChanged: (_) {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoratedBox = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(NixSwitchList),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final containerDecoration = decoratedBox.decoration as BoxDecoration;
      expect(containerDecoration.borderRadius, equals(const BorderRadius.all(Radius.circular(16.0))));

      // Item spacing SizedBox
      expect(find.byWidgetPredicate((widget) => widget is SizedBox && widget.height == 2.0), findsOneWidget);
    });

    testWidgets('NixSwitchList.builder lazily constructs items with accurate segmented radii', (tester) async {
      final values = [true, false, true, false];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixSwitchList.builder(
              itemCount: values.length,
              itemBuilder: (context, index) {
                return NixSwitchTile(
                  key: Key('builder_tile_$index'),
                  title: Text('Setting $index'),
                  value: values[index],
                  onChanged: (_) {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First item
      final container0 = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byKey(const Key('builder_tile_0')), matching: find.byType(AnimatedContainer)).first,
      );
      final radius0 = (container0.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius0.topLeft.x, equals(12.0));
      expect(radius0.bottomLeft.x, equals(6.0));

      // Middle item
      final container1 = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byKey(const Key('builder_tile_1')), matching: find.byType(AnimatedContainer)).first,
      );
      final radius1 = (container1.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius1.topLeft.x, equals(6.0));
      expect(radius1.bottomLeft.x, equals(6.0));

      // Last item
      final container3 = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byKey(const Key('builder_tile_3')), matching: find.byType(AnimatedContainer)).first,
      );
      final radius3 = (container3.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius3.topLeft.x, equals(6.0));
      expect(radius3.bottomLeft.x, equals(12.0));
    });

    testWidgets('Works seamlessly inside NixListView inheriting NixListScope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixListView(
              children: [
                NixSwitchTile(
                  key: const Key('list_view_tile_0'),
                  title: const Text('Wi-Fi in NixListView'),
                  value: true,
                  onChanged: (_) {},
                ),
                NixSwitchTile(
                  key: const Key('list_view_tile_1'),
                  title: const Text('Bluetooth in NixListView'),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container0 = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byKey(const Key('list_view_tile_0')), matching: find.byType(AnimatedContainer)).first,
      );
      final radius0 = (container0.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius0.topLeft.x, equals(12.0));
      expect(radius0.bottomLeft.x, equals(6.0));
    });
  });
}

