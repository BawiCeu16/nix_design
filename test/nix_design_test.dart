import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixTheme & Tokens', () {
    testWidgets('resolves colors automatically from MaterialApp ThemeData', (
      tester,
    ) async {
      const customSeed = Colors.purple;
      late Color resolvedPrimary;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: customSeed),
          ),
          home: Builder(
            builder: (context) {
              final nix = context.nixTheme;
              resolvedPrimary = nix.primary!;
              return const SizedBox();
            },
          ),
        ),
      );

      final expectedPrimary = ColorScheme.fromSeed(seedColor: customSeed)
          .primary;
      expect(resolvedPrimary, equals(expectedPrimary));
    });

    testWidgets('allows local overrides via NixTheme', (tester) async {
      const overrideColor = Colors.tealAccent;
      late Color resolvedPrimary;

      await tester.pumpWidget(
        MaterialApp(
          home: NixTheme(
            data: const NixThemeData(primary: overrideColor),
            child: Builder(
              builder: (context) {
                final nix = context.nixTheme;
                resolvedPrimary = nix.primary!;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolvedPrimary, equals(overrideColor));
    });
  });

  group('NixButton', () {
    testWidgets('renders filled pill button and responds to tap', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: Center(
              child: NixButton(
                onPressed: () => pressed = true,
                label: const Text('Click Me'),
              ),
            ),
          ),
        ),
      );

      final buttonMaterial = find.descendant(
        of: find.byType(NixButton),
        matching: find.byType(Material),
      );
      final material = tester.widget<Material>(buttonMaterial);
      expect(material.shape, isA<StadiumBorder>());

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders loading state without calling onPressed', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixButton(
              isLoading: true,
              onPressed: () => pressed = true,
              label: const Text('Submit'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(NixButton));
      await tester.pump(const Duration(milliseconds: 100));

      expect(pressed, isFalse);
    });

    testWidgets('respects app theme primary color for filled variant', (
      tester,
    ) async {
      const seedColor = Colors.deepOrange;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          ),
          home: Scaffold(
            body: NixButton.filled(
              onPressed: () {},
              label: const Text('Orange Pill'),
            ),
          ),
        ),
      );

      final expectedPrimary = ColorScheme.fromSeed(seedColor: seedColor)
          .primary;
      final buttonMaterial = find.descendant(
        of: find.byType(NixButton),
        matching: find.byType(Material),
      );
      final material = tester.widget<Material>(buttonMaterial);
      expect(material.color, equals(expectedPrimary));
    });

    testWidgets(
      'isExpanded safely handles both bounded and unconstrained layouts',
      (tester) async {
        // 1. In bounded width (Column/SizedBox) -> fills available width
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: NixButton(
                    isExpanded: true,
                    onPressed: () {},
                    label: const Text('Expanded Bounded'),
                  ),
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(NixButton);
        expect(tester.getSize(buttonFinder).width, equals(300.0));

        // 2. In unconstrained horizontal layout (Row) -> does not crash with infinite width
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  NixButton(
                    isExpanded: true,
                    onPressed: () {},
                    label: const Text('Expanded In Unconstrained Row'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Expanded In Unconstrained Row'), findsOneWidget);
      },
    );

    testWidgets('morphs shape on press and hold like Material 3 Expressive', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixButton.filled(
                onPressed: () {},
                label: const Text('Hold Me'),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(NixButton);
      final materialFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Material),
      );

      // Resting state: StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );

      // Press and hold down
      final gesture = await tester.startGesture(tester.getCenter(buttonFinder));
      await tester.pumpAndSettle();

      // Pressed/Held state: morphed to RoundedRectangleBorder with 8.0 radius (crisp squircle)
      final pressedShape = tester.widget<Material>(materialFinder).shape;
      expect(pressedShape, isA<RoundedRectangleBorder>());
      final rrb = pressedShape as RoundedRectangleBorder;
      expect(rrb.borderRadius, equals(BorderRadius.circular(8.0)));

      // Release gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Restores back to StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );
    });

    testWidgets('morphs shape on hover like Material 3 Expressive', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixButton.filled(
                onPressed: () {},
                label: const Text('Hover Me'),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(NixButton);
      final materialFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Material),
      );

      // Resting state: StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );

      // Simulate mouse hover
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(buttonFinder));
      await tester.pumpAndSettle();

      // Hovered state: morphed to intermediate squircle with 15.0 radius
      final hoveredShape = tester.widget<Material>(materialFinder).shape;
      expect(hoveredShape, isA<RoundedRectangleBorder>());
      final rrb = hoveredShape as RoundedRectangleBorder;
      expect(rrb.borderRadius, equals(BorderRadius.circular(15.0)));

      // Move mouse away
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      // Restores back to StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );
    });
  });

  group('NixIconButton', () {
    testWidgets('renders stadium/circle icon button and triggers tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('NixIconButton morphs shape on press and hold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixIconButton.filled(
                icon: const Icon(Icons.star),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(NixIconButton);
      final materialFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Material),
      );

      // Resting state: StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );

      // Press and hold down
      final gesture = await tester.startGesture(tester.getCenter(buttonFinder));
      await tester.pumpAndSettle();

      // Pressed/Held state: morphed to crisp squircle with 8.0 radius
      final pressedShape = tester.widget<Material>(materialFinder).shape;
      expect(pressedShape, isA<RoundedRectangleBorder>());
      final rrb = pressedShape as RoundedRectangleBorder;
      expect(rrb.borderRadius, equals(BorderRadius.circular(8.0)));

      // Release gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Restores back to StadiumBorder
      expect(
        tester.widget<Material>(materialFinder).shape,
        isA<StadiumBorder>(),
      );
    });
  });

  group('NixSwitch', () {
    testWidgets('renders pill switch and toggles on tap', (tester) async {
      bool switchVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixSwitch(
                  value: switchVal,
                  onChanged: (val) {
                    setState(() => switchVal = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(switchVal, isFalse);

      await tester.tap(find.byType(NixSwitch));
      await tester.pumpAndSettle();

      expect(switchVal, isTrue);
    });

    testWidgets(
      'NixSwitch provides accessible 48x48 tap target and responds to taps outside exact visual pill',
      (tester) async {
        bool switchVal = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return NixSwitch(
                      value: switchVal,
                      onChanged: (val) => setState(() => switchVal = val),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final switchCenter = tester.getCenter(find.byType(NixSwitch));

        // Visual track height is 28.0 (top is center.dy - 14, bottom is center.dy + 14).
        // Tap target is 48.0 high (extends to center.dy - 24 and center.dy + 24).
        // Tap 18 pixels above the center (outside visual track of 14px, but inside 24px tap target):
        await tester.tapAt(Offset(switchCenter.dx, switchCenter.dy - 18));
        await tester.pumpAndSettle();

        expect(switchVal, isTrue);

        // Tap 18 pixels below the center:
        await tester.tapAt(Offset(switchCenter.dx, switchCenter.dy + 18));
        await tester.pumpAndSettle();

        expect(switchVal, isFalse);
      },
    );

    testWidgets('NixSwitch smoothly animates track and thumb colors', (
      tester,
    ) async {
      bool switchVal = false;
      const activeTrack = Colors.blue;
      const inactiveTrack = Colors.grey;
      const activeThumb = Colors.white;
      const inactiveThumb = Colors.black;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return NixSwitch(
                    value: switchVal,
                    activeTrackColor: activeTrack,
                    inactiveTrackColor: inactiveTrack,
                    activeColor: activeThumb,
                    inactiveColor: inactiveThumb,
                    duration: const Duration(milliseconds: 300),
                    onChanged: (val) => setState(() => switchVal = val),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Toggle switch
      await tester.tap(find.byType(NixSwitch));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 150)); // Midpoint

      // Verify animation is actively running and colors are intermediate
      final containers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(NixSwitch),
              matching: find.byType(Container),
            ),
          )
          .toList();

      final trackContainer = containers.first;
      final trackColor = (trackContainer.decoration as ShapeDecoration).color!;
      // Track color should be lerped midway between grey and blue
      expect(trackColor, isNot(equals(inactiveTrack)));
      expect(trackColor, isNot(equals(activeTrack)));

      await tester.pumpAndSettle(); // Settle animation
      final finalContainers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(NixSwitch),
              matching: find.byType(Container),
            ),
          )
          .toList();
      final finalTrackColor =
          (finalContainers.first.decoration as ShapeDecoration).color!;
      expect(finalTrackColor, equals(activeTrack));
    });

    testWidgets(
      'NixSwitch triggers haptic feedback only when indicator is fully slid to on or off',
      (tester) async {
        final List<String> hapticCalls = [];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              hapticCalls.add(methodCall.arguments as String);
            }
            return null;
          },
        );

        bool switchVal = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return NixSwitch(
                      value: switchVal,
                      onChanged: (val) => setState(() => switchVal = val),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final center = tester.getCenter(find.byType(NixSwitch));
        final gesture = await tester.startGesture(center);
        await tester.pump();

        // Win arena past touch slop
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump();

        // Drag all the way right (fully slid to ON, value reaches 1.0)
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        expect(hapticCalls.length, equals(1));
        expect(hapticCalls.last, equals('HapticFeedbackType.lightImpact'));

        // Move slightly left (midway): should NOT vibrate midway
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
        expect(hapticCalls.length, equals(1));

        // Drag all the way left (fully slid to OFF, value reaches 0.0)
        await gesture.moveBy(const Offset(-50, 0));
        await tester.pump();
        expect(hapticCalls.length, equals(2));

        // Drag all the way right again (fully slid to ON)
        await gesture.moveBy(const Offset(60, 0));
        await tester.pump();
        expect(hapticCalls.length, equals(3));

        // Release gesture
        await gesture.up();
        await tester.pumpAndSettle();

        expect(switchVal, isTrue);

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      },
    );

    testWidgets(
      'NixSwitch indicator has clean thumb without inner splash overlay or halo glow',
      (tester) async {
        bool switchVal = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return NixSwitch(
                      value: switchVal,
                      onChanged: (val) => setState(() => switchVal = val),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final center = tester.getCenter(find.byType(NixSwitch));

        // When OFF (false): Press down
        final gesture = await tester.startGesture(center);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Exactly 1 AnimatedContainer inside NixSwitch (the thumb itself, no inner splash child)
        final thumbFinder = find.descendant(
          of: find.byType(NixSwitch),
          matching: find.byType(AnimatedContainer),
        );
        expect(thumbFinder, findsOneWidget);

        // Verify only 1 base shadow, no glow or halo BoxShadow
        final thumbContainer = tester.widget<AnimatedContainer>(thumbFinder);
        final thumbDecor = thumbContainer.decoration as ShapeDecoration;
        expect(thumbDecor.shadows!.length, equals(1)); // Base shadow only

        // Release
        await gesture.up();
        await tester.pumpAndSettle();
        expect(switchVal, isTrue);

        // Press down while ON
        final gestureOn = await tester.startGesture(center);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(thumbFinder, findsOneWidget);
        await gestureOn.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('NixSwitch respects enableFeedback: false', (tester) async {
      final List<String> hapticCalls = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(methodCall.arguments as String);
          }
          return null;
        },
      );

      bool switchVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return NixSwitch(
                    value: switchVal,
                    enableFeedback: false,
                    onChanged: (val) => setState(() => switchVal = val),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NixSwitch));
      await tester.pumpAndSettle();

      expect(switchVal, isTrue);
      expect(hapticCalls, isEmpty);

      // Drag with enableFeedback: false
      final center = tester.getCenter(find.byType(NixSwitch));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(hapticCalls, isEmpty);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('NixSwitch responds to Space and Enter keyboard keys', (
      tester,
    ) async {
      bool switchVal = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return NixSwitch(
                    focusNode: focusNode,
                    autofocus: true,
                    value: switchVal,
                    onChanged: (val) => setState(() => switchVal = val),
                  );
                },
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(switchVal, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(switchVal, isFalse);

      focusNode.dispose();
    });
  });

  group('NixChip & NixFilterChip', () {
    testWidgets('NixChip renders with stadium shape and calls onDeleted', (
      tester,
    ) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixChip(
              label: const Text('Flutter'),
              onDeleted: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      final chipMaterial = find.descendant(
        of: find.byType(NixChip),
        matching: find.byType(Material),
      );
      final material = tester.widget<Material>(chipMaterial);
      expect(material.shape, isA<StadiumBorder>());

      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('NixFilterChip toggles selection', (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixFilterChip(
                  label: const Text('Filter'),
                  selected: selected,
                  onSelected: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(selected, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('NixSegmentedControl', () {
    testWidgets('switches selected segment smoothly', (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixSegmentedControl<int>(
                  value: selected,
                  items: const [
                    NixSegment(value: 0, label: 'First'),
                    NixSegment(value: 1, label: 'Second'),
                    NixSegment(value: 2, label: 'Third'),
                  ],
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(selected, equals(0));

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(selected, equals(1));
    });
  });

  group('NixCard', () {
    testWidgets('NixCard renders pill style and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NixCard.pill(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      final cardMaterial = find.descendant(
        of: find.byType(NixCard),
        matching: find.byType(Material),
      );
      final material = tester.widget<Material>(cardMaterial);
      expect(material.shape, isA<StadiumBorder>());

      await tester.tap(find.text('Card Content'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('NixBottomBar', () {
    testWidgets(
      'renders floating pill with dynamic width items, text, icon, and custom child',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: StatefulBuilder(
                builder: (context, setState) {
                  return NixBottomBar(
                    currentIndex: selectedIndex,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                    items: const [
                      NixBottomBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      NixBottomBarItem(
                        icon: Icon(Icons.star_outline),
                        label: 'Starred',
                      ),
                      NixBottomBarItem(
                        child: Text('Custom Dynamic Width Widget'),
                      ),
                    ],
                    trailing: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NixBottomBar), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Starred'), findsOneWidget);
        expect(find.text('Custom Dynamic Width Widget'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);

        // Tap on Starred
        await tester.tap(find.text('Starred'));
        await tester.pumpAndSettle();

        expect(selectedIndex, equals(1));
      },
    );

    testWidgets('slides indicator via hand gestures across items', (
      tester,
    ) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return NixBottomBar(
                  currentIndex: selectedIndex,
                  onTap: (idx) => setState(() => selectedIndex = idx),
                  items: const [
                    NixBottomBarItem(icon: Icon(Icons.home), label: 'First'),
                    NixBottomBarItem(icon: Icon(Icons.person), label: 'Second'),
                    NixBottomBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Third',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(0));

      // Drag horizontally from First to Third
      final firstFinder = find.text('First');
      final thirdFinder = find.text('Third');

      await tester.drag(
        firstFinder,
        Offset(
          tester.getCenter(thirdFinder).dx - tester.getCenter(firstFinder).dx,
          0,
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(2));
    });

    testWidgets('scrolls to hide and shrink with ScrollController', (
      tester,
    ) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NixBottomBar(
              scrollController: scrollController,
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down
      scrollController.jumpTo(300.0);
      await tester.pumpAndSettle();

      expect(find.byType(NixBottomBar), findsOneWidget);

      // Scroll back to top
      scrollController.jumpTo(0.0);
      await tester.pumpAndSettle();

      expect(find.byType(NixBottomBar), findsOneWidget);
    });

    testWidgets(
      'supports label under icon, only icon, only text, and separate action on left or right',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  // Icon + label (under icon)
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  // Only icon
                  NixBottomBarItem(icon: Icon(Icons.favorite)),
                  // Only text
                  NixBottomBarItem(label: 'Explore'),
                ],
                action: const Icon(Icons.search, key: Key('separate_action')),
                actionPosition: NixBarActionPosition.left,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check column with icon and label under it
        final homeColumn = find.ancestor(
          of: find.text('Home'),
          matching: find.byType(Column),
        );
        expect(homeColumn, findsOneWidget);

        // Check only icon exists
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        // Check only text exists without a column
        final exploreFinder = find.text('Explore');
        expect(exploreFinder, findsOneWidget);
        final exploreColumn = find.ancestor(
          of: exploreFinder,
          matching: find.byType(Column),
        );
        expect(exploreColumn, findsNothing);

        // Check separate action is placed on the left
        final actionFinder = find.byKey(const Key('separate_action'));
        expect(actionFinder, findsOneWidget);

        final actionOffset = tester.getCenter(actionFinder);
        final homeOffset = tester.getCenter(find.text('Home'));
        expect(actionOffset.dx, lessThan(homeOffset.dx));
      },
    );

    testWidgets(
      'all items have equal dynamic width regardless of individual content lengths',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'A'),
                  NixBottomBarItem(
                    icon: Icon(Icons.widgets),
                    label: 'Medium Title',
                  ),
                  NixBottomBarItem(
                    icon: Icon(Icons.notifications),
                    label: 'Very Long Label Notifications',
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final aSubtree = find.ancestor(
          of: find.text('A'),
          matching: find.byType(KeyedSubtree),
        );
        final medSubtree = find.ancestor(
          of: find.text('Medium Title'),
          matching: find.byType(KeyedSubtree),
        );
        final longSubtree = find.ancestor(
          of: find.text('Very Long Label Notifications'),
          matching: find.byType(KeyedSubtree),
        );

        final sizeA = tester.getSize(aSubtree);
        final sizeMed = tester.getSize(medSubtree);
        final sizeLong = tester.getSize(longSubtree);

        // All items must have exact equal width
        expect(sizeA.width, equals(sizeMed.width));
        expect(sizeMed.width, equals(sizeLong.width));
        // And the dynamic width must be large enough to comfortably fit the widest content
        expect(
          sizeA.width,
          greaterThanOrEqualTo(
            tester.getSize(find.text('Very Long Label Notifications')).width,
          ),
        );
      },
    );

    testWidgets(
      'supports onLongPress on items and bar to trigger dialogs or popups',
      (tester) async {
        bool itemLongPressed = false;
        int? barLongPressedIndex;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: Builder(
                builder: (context) {
                  return NixBottomBar(
                    currentIndex: 0,
                    onTap: (_) {},
                    onLongPress: (index) {
                      barLongPressedIndex = index;
                      showNixDialog<void>(
                        context: context,
                        builder: (ctx) => const NixDialog(
                          title: Text('Popup Dialog'),
                          content: Text('Long press triggered dialog'),
                        ),
                      );
                    },
                    items: [
                      NixBottomBarItem(
                        icon: const Icon(Icons.home),
                        label: 'Home',
                        onLongPress: () {
                          itemLongPressed = true;
                        },
                      ),
                      const NixBottomBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press the Home item
        await tester.longPress(find.text('Home'));
        await tester.pumpAndSettle();

        expect(itemLongPressed, isTrue);
        expect(barLongPressedIndex, equals(0));
        expect(find.text('Popup Dialog'), findsOneWidget);
        expect(find.text('Long press triggered dialog'), findsOneWidget);
      },
    );

    testWidgets(
      'renders solid theme surface container background with no border by default',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pillMaterial = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(NixBottomBar),
                matching: find.byType(Material),
              )
              .first,
        );

        // Verify no border by default
        final stadiumShape = pillMaterial.shape as StadiumBorder;
        expect(stadiumShape.side, equals(BorderSide.none));

        // Verify background is opaque surfaceContainer
        expect(pillMaterial.color, isNot(equals(Colors.transparent)));
        expect(pillMaterial.color?.a, equals(1.0));
      },
    );

    testWidgets(
      'dynamically adjusts whole bar width and keeps indicator precisely aligned on screen size changes',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int selectedIndex = 1;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: StatefulBuilder(
                builder: (context, setState) {
                  return NixBottomBar(
                    mainAxisSize: MainAxisSize.max,
                    maxWidth: 560.0,
                    currentIndex: selectedIndex,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                    items: const [
                      NixBottomBarItem(icon: Icon(Icons.home), label: 'First'),
                      NixBottomBarItem(icon: Icon(Icons.star), label: 'Second'),
                      NixBottomBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Third',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Material floating pill
        final pillFinder = find
            .descendant(
              of: find.byType(NixBottomBar),
              matching: find.byType(Material),
            )
            .first;
        final phonePillSize = tester.getSize(pillFinder);

        // On 400px screen with 16px left + 16px right margins: pill width is exactly 368px
        expect(phonePillSize.width, equals(368.0));

        final phoneItemFinder = find.ancestor(
          of: find.text('Second'),
          matching: find.byType(KeyedSubtree),
        );
        final phoneItemSize = tester.getSize(phoneItemFinder);
        final expectedPhoneItemWidth =
            (368.0 - 8.0) / 3; // padding 4.0 horizontal on both sides
        expect(phoneItemSize.width, closeTo(expectedPhoneItemWidth, 0.1));

        // Now rotate / resize screen to wide screen (e.g. tablet / landscape: 1000 x 700)
        tester.view.physicalSize = const Size(1000, 700);
        await tester.pumpAndSettle();

        final widePillSize = tester.getSize(pillFinder);
        // Polished constraint: caps at maxWidth (560.0) so it doesn't stretch awkwardly across wide screens
        expect(widePillSize.width, equals(560.0));

        final wideItemFinder = find.ancestor(
          of: find.text('Second'),
          matching: find.byType(KeyedSubtree),
        );
        final wideItemSize = tester.getSize(wideItemFinder);
        final expectedWideItemWidth = (560.0 - 8.0) / 3;
        expect(wideItemSize.width, closeTo(expectedWideItemWidth, 0.1));

        // Tap on third item on wide screen
        await tester.tap(find.text('Third'));
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(2));

        // Resize back to narrow phone screen
        tester.view.physicalSize = const Size(360, 640);
        await tester.pumpAndSettle();

        final narrowPillSize = tester.getSize(pillFinder);
        // 360 - 32 = 328px
        expect(narrowPillSize.width, equals(328.0));
        expect(selectedIndex, equals(2));
      },
    );

    testWidgets(
      'unshrinks when pressed, reduces margin on shrink, and applies subtle shrink scale',
      (tester) async {
        final scrollController = ScrollController();
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: StatefulBuilder(
                builder: (context, setState) {
                  return NixBottomBar(
                    scrollController: scrollController,
                    hideOnScroll: false,
                    shrinkOnScroll: true,
                    shrinkScale: 0.92,
                    currentIndex: selectedIndex,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                    items: const [
                      NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                      NixBottomBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  );
                },
              ),
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Transform widget responsible for scale inside AnimatedBuilder
        final scaleFinder = find
            .descendant(
              of: find.byType(NixBottomBar),
              matching: find.byType(Transform),
            )
            .last;

        // Initially scale is 1.0 (unshrunk)
        expect(
          tester.widget<Transform>(scaleFinder).transform.storage[0],
          equals(1.0),
        );

        // Scroll down by dragging
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Item 2')),
        );
        await gesture.moveBy(const Offset(0, -300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify subtle shrink scale (0.92, not aggressive 0.8)
        expect(
          tester.widget<Transform>(scaleFinder).transform.storage[0],
          closeTo(0.92, 0.01),
        );

        // Verify reduced margin when shrunk
        final paddingFinder = find
            .descendant(of: find.byType(Align), matching: find.byType(Padding))
            .first;
        final shrunkMargin =
            tester.widget<Padding>(paddingFinder).padding as EdgeInsets;
        expect(shrunkMargin.bottom, closeTo(14.0 * 0.65, 0.1));

        // Release drag gesture
        await gesture.up();
        await tester.pumpAndSettle();

        // Tap on the shrunk bar to unshrink it
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Bar has un-shrunk back to 1.0 scale and full margin!
        expect(
          tester.widget<Transform>(scaleFinder).transform.storage[0],
          equals(1.0),
        );
        final unshrunkMargin =
            tester.widget<Padding>(paddingFinder).padding as EdgeInsets;
        expect(unshrunkMargin.bottom, equals(14.0));
        expect(selectedIndex, equals(1));
      },
    );

    testWidgets(
      'enableShrink: false disables all scale and margin shrinking on scroll',
      (tester) async {
        final scrollController = ScrollController();
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: StatefulBuilder(
                builder: (context, setState) {
                  return NixBottomBar(
                    scrollController: scrollController,
                    hideOnScroll: false,
                    enableShrink: false,
                    shrinkOnScroll: true,
                    shrinkScale: 0.92,
                    currentIndex: selectedIndex,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                    items: const [
                      NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                      NixBottomBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  );
                },
              ),
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Scroll down by dragging
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Item 2')),
        );
        await gesture.moveBy(const Offset(0, -300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // With enableShrink: false and hideOnScroll: false, scale remains 1.0 and margin does not compress
        final transforms = tester.widgetList<Transform>(
          find.descendant(
            of: find.byType(NixBottomBar),
            matching: find.byType(Transform),
          ),
        );
        for (final t in transforms) {
          expect(t.transform.storage[0], equals(1.0));
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'NixBottomBarStyle.separated with 2 or 3 items hugs items at BottomLeft and places ActionButton at BottomRight',
      (tester) async {
        int selectedIndex = 0;
        bool actionTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: StatefulBuilder(
                builder: (context, setState) {
                  return NixBottomBar.separated(
                    currentIndex: selectedIndex,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                    items: const [
                      NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                      NixBottomBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                    ],
                    action: NixIconButton.filled(
                      key: const ValueKey('action_btn'),
                      icon: const Icon(Icons.add),
                      onPressed: () => actionTapped = true,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the navigation pill Material and the action button
        final pillFinder = find
            .descendant(
              of: find.byType(NixBottomBar),
              matching: find.byType(Material),
            )
            .first;
        final pillRect = tester.getRect(pillFinder);

        final actionFinder = find.byKey(const ValueKey('action_btn'));
        expect(actionFinder, findsOneWidget);
        final actionRect = tester.getRect(actionFinder);

        // Verify NavigationBar pill is at BottomLeft (margin is 16.0)
        expect(pillRect.left, equals(16.0));

        // Verify NavigationBar pill is compact for 2 items (not stretched to screen width)
        expect(pillRect.width, lessThan(200.0));

        // Verify ActionButton is at BottomRight (screen width 800 by default, margin is 16.0)
        expect(actionRect.right, equals(800.0 - 16.0));

        // Verify there is a wide separated dynamic gap between pill and action button
        expect(actionRect.left - pillRect.right, greaterThan(400.0));

        // Test tapping items and action
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(1));

        await tester.tap(actionFinder);
        await tester.pumpAndSettle();
        expect(actionTapped, isTrue);
      },
    );

    testWidgets(
      'NixBottomBar.separated with actionPosition.left places ActionButton at BottomLeft and NavigationBar at BottomRight',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar.separated(
                currentIndex: 0,
                onTap: (_) {},
                actionPosition: NixBarActionPosition.left,
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.explore), label: 'Explore'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
                action: NixIconButton.filled(
                  key: const ValueKey('left_action_btn'),
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final actionFinder = find.byKey(const ValueKey('left_action_btn'));
        final actionRect = tester.getRect(actionFinder);

        final pillFinder = find
            .ancestor(of: find.text('Home'), matching: find.byType(Material))
            .first;
        final pillRect = tester.getRect(pillFinder);

        // ActionButton is at BottomLeft
        expect(actionRect.left, equals(16.0));

        // NavigationBar pill is at BottomRight
        expect(pillRect.right, equals(800.0 - 16.0));

        // Dynamic gap separates them
        expect(pillRect.left - actionRect.right, greaterThan(300.0));
      },
    );

    testWidgets(
      'in standard by default bar width is dynamic based on NavigationBar children (icon/text, icon only, text only)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Test 1: Icon + Text (2 items) -> hugs dynamically, not stretched across 560px
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.widgets), label: 'Widgets'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pillFinder = find
            .descendant(
              of: find.byType(NixBottomBar),
              matching: find.byType(Material),
            )
            .first;
        final iconTextPillSize = tester.getSize(pillFinder);

        // Dynamic width for 2 items is well below 250px and not stretched to 560px
        expect(iconTextPillSize.width, lessThan(250.0));
        expect(iconTextPillSize.width, greaterThan(150.0));

        // Test 2: Icon Only (2 items) -> even more compact
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home)),
                  NixBottomBarItem(icon: Icon(Icons.widgets)),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final iconOnlyPillSize = tester.getSize(pillFinder);
        expect(iconOnlyPillSize.width, lessThan(iconTextPillSize.width));
        expect(iconOnlyPillSize.width, greaterThan(100.0));

        // Test 3: Text Only (2 items)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(label: 'Home'),
                  NixBottomBarItem(label: 'Widgets'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final textOnlyPillSize = tester.getSize(pillFinder);
        expect(textOnlyPillSize.width, lessThan(250.0));
        expect(textOnlyPillSize.width, greaterThan(140.0));
      },
    );

    testWidgets(
      'in separated by default bar width is dynamic based on NavigationBar children without being too narrow',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // 2 icon+text items in separated mode
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar.separated(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.widgets), label: 'Widgets'),
                ],
                action: const Icon(Icons.search),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pillFinder = find
            .ancestor(of: find.text('Home'), matching: find.byType(Material))
            .first;
        final pillSize = tester.getSize(pillFinder);

        // Comfortable dynamic width for touch, not squished at 112px
        expect(pillSize.width, greaterThan(150.0));
        expect(pillSize.width, lessThan(250.0));
      },
    );

    testWidgets(
      'NixBottomBar supports transparent background and frosted blur via BackdropFilter',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                enableFrostedBlur: true,
                blur: 16.0,
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When frosted blur is active, a BackdropFilter is present
        final backdropFinder = find.descendant(
          of: find.byType(NixBottomBar),
          matching: find.byType(BackdropFilter),
        );
        expect(backdropFinder, findsAtLeastNWidgets(1));

        final backdrop = tester.widget<BackdropFilter>(backdropFinder.first);
        expect(backdrop.filter.toString(), contains('16.0'));
      },
    );

    testWidgets(
      'NixBottomBar ActionButton supports frosted blur and transparent container',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar.separated(
                currentIndex: 0,
                onTap: (_) {},
                enableFrostedBlur: true,
                blur: 20.0,
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
                action: const Icon(Icons.search, key: Key('frosted_action')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Both the nav bar pill and the companion action button receive BackdropFilter
        final backdrops = find.descendant(
          of: find.byType(NixBottomBar),
          matching: find.byType(BackdropFilter),
        );
        expect(backdrops, findsNWidgets(2));

        // Action icon is inside one of the BackdropFilters
        final actionInBackdrop = find.descendant(
          of: backdrops.last,
          matching: find.byKey(const Key('frosted_action')),
        );
        expect(actionInBackdrop, findsOneWidget);
      },
    );

    testWidgets(
      'NixBarActionButton works standalone with frosted blur, tooltip, and press animation',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: NixBarActionButton(
                  icon: const Icon(Icons.search),
                  label: 'Search',
                  tooltip: 'Search components',
                  blur: 15.0,
                  onPressed: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Search'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);

        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'NixBottomBar indicator transparency adapts to frosted blur and transparent background',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                enableFrostedBlur: true,
                adaptIndicatorTransparency: true,
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final barLayout = tester.firstWidget(
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_NixBarLayout',
          ),
        ) as dynamic;

        // Adapted indicator transparency in frosted mode has alpha between 0.15 and 0.40
        final Color indColor = barLayout.indicatorColor as Color;
        expect(indColor.a, greaterThanOrEqualTo(0.15));
        expect(indColor.a, lessThanOrEqualTo(0.40));
      },
    );

    testWidgets(
      'NixBottomBar dim option supports adaptive dimming and customizable dim amount and color',
      (tester) async {
        // Test custom dim and dimColor
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NixBottomBar(
                currentIndex: 0,
                onTap: (_) {},
                enableFrostedBlur: true,
                enableDim: true,
                dim: 0.35,
                dimColor: Colors.purple,
                items: const [
                  NixBottomBarItem(icon: Icon(Icons.home), label: 'Home'),
                  NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Dim layer decorated box is rendered with the specified tint color and alpha
        final dimDecoratedBoxFinder = find.byWidgetPredicate((w) {
          if (w is DecoratedBox) {
            final decoration = w.decoration;
            if (decoration is BoxDecoration && decoration.color != null) {
              final c = decoration.color!;
              return c.r == Colors.purple.r && (c.a - 0.35).abs() < 0.05;
            }
          }
          return false;
        });

        expect(dimDecoratedBoxFinder, findsAtLeastNWidgets(1));
      },
    );
  });

  group('NixSnackBar', () {
    testWidgets(
      'floats over all layers with stadium pill shape and dynamic width',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        message: 'Dynamic Width Message',
                        icon: const Icon(Icons.info),
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Dynamic Width Message'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);

        // Verify StadiumBorder (pill shape)
        final materialPill = tester.widget<Material>(
          find.byKey(const Key('nix_snack_bar_pill')),
        );
        expect(materialPill.shape, isA<StadiumBorder>());

        // Verify dynamic width: Row has mainAxisSize.min
        final rowWidget = tester.widget<Row>(
          find
              .descendant(
                of: find.byKey(const Key('nix_snack_bar_pill')),
                matching: find.byType(Row),
              )
              .first,
        );
        expect(rowWidget.mainAxisSize, equals(MainAxisSize.min));

        // Dismiss smoothly
        NixSnackBar.dismiss();
        await tester.pumpAndSettle();
        expect(find.text('Dynamic Width Message'), findsNothing);
      },
    );

    testWidgets(
      'supports NixSnackBarPosition.bottom with slide-up entrance and slide-down exit',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.bottom,
                        message: 'Bottom Floating Pill',
                      );
                    },
                    child: const Text('Show Bottom'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Bottom'));
        await tester.pump();

        final slideTransitionFinder = find.byKey(
          const Key('nix_snack_bar_slide'),
        );
        expect(slideTransitionFinder, findsOneWidget);

        // Beginning of animation: slide is positioned below resting position (offset Y > 0)
        SlideTransition slideWidget = tester.widget<SlideTransition>(
          slideTransitionFinder,
        );
        expect(slideWidget.position.value.dy, greaterThan(1.0));

        // Settle animation: resting position is Offset.zero
        await tester.pump(const Duration(milliseconds: 350));
        slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
        expect(slideWidget.position.value, equals(Offset.zero));

        // Dismiss: slides down (offset Y increases back to positive)
        NixSnackBar.dismiss();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
        expect(slideWidget.position.value.dy, greaterThan(0.0));

        await tester.pumpAndSettle();
        expect(find.text('Bottom Floating Pill'), findsNothing);
      },
    );

    testWidgets(
      'supports NixSnackBarPosition.top with slide-down entrance and slide-up exit',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.top,
                        message: 'Top Floating Pill',
                      );
                    },
                    child: const Text('Show Top'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Top'));
        await tester.pump();

        final slideTransitionFinder = find.byKey(
          const Key('nix_snack_bar_slide'),
        );
        expect(slideTransitionFinder, findsOneWidget);

        // Beginning of animation: slide is positioned above resting position (offset Y < 0)
        SlideTransition slideWidget = tester.widget<SlideTransition>(
          slideTransitionFinder,
        );
        expect(slideWidget.position.value.dy, lessThan(-1.0));

        // Settle animation: resting position is Offset.zero
        await tester.pump(const Duration(milliseconds: 350));
        slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
        expect(slideWidget.position.value, equals(Offset.zero));

        // Dismiss: slides up (offset Y becomes negative)
        NixSnackBar.dismiss();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
        expect(slideWidget.position.value.dy, lessThan(0.0));

        await tester.pumpAndSettle();
        expect(find.text('Top Floating Pill'), findsNothing);
      },
    );

    testWidgets('triggers onAction callback and dismisses on action click', (
      tester,
    ) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    NixSnackBar.show(
                      context,
                      message: 'Action Message',
                      actionLabel: 'Undo',
                      onAction: () => actionTriggered = true,
                    );
                  },
                  child: const Text('Show Action'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
      expect(find.text('Action Message'), findsNothing);
    });

    testWidgets(
      'dynamically inherits theme colors from ThemeData and NixThemeData',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      NixSnackBar.show(context, message: 'Themed Toast');
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        final materialWidget = tester.widget<Material>(
          find.byKey(const Key('nix_snack_bar_pill')),
        );

        // Verify that color is dynamically derived from teal ColorScheme.inverseSurface
        final expectedInverseSurface = ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ).inverseSurface;
        expect(materialWidget.color, equals(expectedInverseSurface));

        NixSnackBar.dismiss();
        await tester.pumpAndSettle();
      },
    );
  });

  group('NixDialog', () {
    testWidgets(
      'renders long content without RenderFlex overflow and scrolls smoothly',
      (tester) async {
        tester.view.physicalSize = const Size(360, 500);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showNixDialog<void>(
                        context: context,
                        builder: (ctx) => NixDialog(
                          icon: const Icon(Icons.info),
                          title: const Text('Long Dialog Title'),
                          content: const Text(
                            'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10\n'
                            'Line 11\nLine 12\nLine 13\nLine 14\nLine 15\nLine 16\nLine 17\nLine 18\nLine 19\nLine 20\n'
                            'Line 21\nLine 22\nLine 23\nLine 24\nLine 25\nLine 26\nLine 27\nLine 28\nLine 29\nLine 30',
                          ),
                          actions: [
                            NixButton.text(
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
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(NixDialog), findsOneWidget);
        expect(find.text('Long Dialog Title'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(find.byType(NixDialog), findsNothing);
      },
    );
  });
}
