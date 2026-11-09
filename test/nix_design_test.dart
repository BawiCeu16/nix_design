import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixTheme & Tokens', () {
    testWidgets('resolves colors automatically from MaterialApp ThemeData', (tester) async {
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

      final expectedPrimary = ColorScheme.fromSeed(seedColor: customSeed).primary;
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
    testWidgets('renders filled pill button and responds to tap', (tester) async {
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

    testWidgets('renders loading state without calling onPressed', (tester) async {
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

    testWidgets('respects app theme primary color for filled variant', (tester) async {
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

      final expectedPrimary = ColorScheme.fromSeed(seedColor: seedColor).primary;
      final buttonMaterial = find.descendant(
        of: find.byType(NixButton),
        matching: find.byType(Material),
      );
      final material = tester.widget<Material>(buttonMaterial);
      expect(material.color, equals(expectedPrimary));
    });

    testWidgets('isExpanded safely handles both bounded and unconstrained layouts', (tester) async {
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
    });

    testWidgets('morphs shape on press and hold like Material 3 Expressive', (tester) async {
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
      final materialFinder = find.descendant(of: buttonFinder, matching: find.byType(Material));

      // Resting state: StadiumBorder
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());

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
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());
    });

    testWidgets('morphs shape on hover like Material 3 Expressive', (tester) async {
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
      final materialFinder = find.descendant(of: buttonFinder, matching: find.byType(Material));

      // Resting state: StadiumBorder
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());

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
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());
    });
  });

  group('NixIconButton', () {
    testWidgets('renders stadium/circle icon button and triggers tap', (tester) async {
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
      final materialFinder = find.descendant(of: buttonFinder, matching: find.byType(Material));

      // Resting state: StadiumBorder
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());

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
      expect(tester.widget<Material>(materialFinder).shape, isA<StadiumBorder>());
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
  });

  group('NixChip & NixFilterChip', () {
    testWidgets('NixChip renders with stadium shape and calls onDeleted', (tester) async {
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
    testWidgets('renders floating pill with dynamic width items, text, icon, and custom child', (tester) async {
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
    });

    testWidgets('slides indicator via hand gestures across items', (tester) async {
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
                    NixBottomBarItem(icon: Icon(Icons.settings), label: 'Third'),
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

      await tester.drag(firstFinder, Offset(tester.getCenter(thirdFinder).dx - tester.getCenter(firstFinder).dx, 0));
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(2));
    });

    testWidgets('scrolls to hide and shrink with ScrollController', (tester) async {
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

    testWidgets('supports label under icon, only icon, only text, and separate action on left or right', (tester) async {
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
      final homeColumn = find.ancestor(of: find.text('Home'), matching: find.byType(Column));
      expect(homeColumn, findsOneWidget);

      // Check only icon exists
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Check only text exists without a column
      final exploreFinder = find.text('Explore');
      expect(exploreFinder, findsOneWidget);
      final exploreColumn = find.ancestor(of: exploreFinder, matching: find.byType(Column));
      expect(exploreColumn, findsNothing);

      // Check separate action is placed on the left
      final actionFinder = find.byKey(const Key('separate_action'));
      expect(actionFinder, findsOneWidget);

      final actionOffset = tester.getCenter(actionFinder);
      final homeOffset = tester.getCenter(find.text('Home'));
      expect(actionOffset.dx, lessThan(homeOffset.dx));
    });

    testWidgets('all items have equal dynamic width regardless of individual content lengths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NixBottomBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                NixBottomBarItem(icon: Icon(Icons.home), label: 'A'),
                NixBottomBarItem(icon: Icon(Icons.widgets), label: 'Medium Title'),
                NixBottomBarItem(icon: Icon(Icons.notifications), label: 'Very Long Label Notifications'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final aSubtree = find.ancestor(of: find.text('A'), matching: find.byType(KeyedSubtree));
      final medSubtree = find.ancestor(of: find.text('Medium Title'), matching: find.byType(KeyedSubtree));
      final longSubtree = find.ancestor(of: find.text('Very Long Label Notifications'), matching: find.byType(KeyedSubtree));

      final sizeA = tester.getSize(aSubtree);
      final sizeMed = tester.getSize(medSubtree);
      final sizeLong = tester.getSize(longSubtree);

      // All items must have exact equal width
      expect(sizeA.width, equals(sizeMed.width));
      expect(sizeMed.width, equals(sizeLong.width));
      // And the dynamic width must be large enough to comfortably fit the widest content
      expect(sizeA.width, greaterThanOrEqualTo(tester.getSize(find.text('Very Long Label Notifications')).width));
    });

    testWidgets('supports onLongPress on items and bar to trigger dialogs or popups', (tester) async {
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
    });

    testWidgets('renders solid theme surface container background with no border by default', (tester) async {
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
        find.descendant(of: find.byType(NixBottomBar), matching: find.byType(Material)).first,
      );

      // Verify no border by default
      final stadiumShape = pillMaterial.shape as StadiumBorder;
      expect(stadiumShape.side, equals(BorderSide.none));

      // Verify background is opaque surfaceContainer
      expect(pillMaterial.color, isNot(equals(Colors.transparent)));
      expect(pillMaterial.color?.a, equals(1.0));
    });

    testWidgets('dynamically adjusts whole bar width and keeps indicator precisely aligned on screen size changes', (tester) async {
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
                  currentIndex: selectedIndex,
                  onTap: (idx) => setState(() => selectedIndex = idx),
                  items: const [
                    NixBottomBarItem(icon: Icon(Icons.home), label: 'First'),
                    NixBottomBarItem(icon: Icon(Icons.star), label: 'Second'),
                    NixBottomBarItem(icon: Icon(Icons.settings), label: 'Third'),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Material floating pill
      final pillFinder = find.descendant(of: find.byType(NixBottomBar), matching: find.byType(Material)).first;
      final phonePillSize = tester.getSize(pillFinder);

      // On 400px screen with 16px left + 16px right margins: pill width is exactly 368px
      expect(phonePillSize.width, equals(368.0));

      final phoneItemFinder = find.ancestor(of: find.text('Second'), matching: find.byType(KeyedSubtree));
      final phoneItemSize = tester.getSize(phoneItemFinder);
      final expectedPhoneItemWidth = (368.0 - 8.0) / 3; // padding 4.0 horizontal on both sides
      expect(phoneItemSize.width, closeTo(expectedPhoneItemWidth, 0.1));

      // Now rotate / resize screen to wide screen (e.g. tablet / landscape: 1000 x 700)
      tester.view.physicalSize = const Size(1000, 700);
      await tester.pumpAndSettle();

      final widePillSize = tester.getSize(pillFinder);
      // Polished constraint: caps at maxWidth (560.0) so it doesn't stretch awkwardly across wide screens
      expect(widePillSize.width, equals(560.0));

      final wideItemFinder = find.ancestor(of: find.text('Second'), matching: find.byType(KeyedSubtree));
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
    });

    testWidgets('unshrinks when pressed, reduces margin on shrink, and applies subtle shrink scale', (tester) async {
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
                    NixBottomBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
      final scaleFinder = find.descendant(
        of: find.byType(NixBottomBar),
        matching: find.byType(Transform),
      ).last;

      // Initially scale is 1.0 (unshrunk)
      expect(tester.widget<Transform>(scaleFinder).transform.storage[0], equals(1.0));

      // Scroll down by dragging
      final gesture = await tester.startGesture(tester.getCenter(find.text('Item 2')));
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify subtle shrink scale (0.92, not aggressive 0.8)
      expect(tester.widget<Transform>(scaleFinder).transform.storage[0], closeTo(0.92, 0.01));

      // Verify reduced margin when shrunk
      final paddingFinder = find.descendant(
        of: find.byType(Align),
        matching: find.byType(Padding),
      ).first;
      final shrunkMargin = tester.widget<Padding>(paddingFinder).padding as EdgeInsets;
      expect(shrunkMargin.bottom, closeTo(16.0 * 0.65, 0.1));

      // Release drag gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Tap on the shrunk bar to unshrink it
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Bar has un-shrunk back to 1.0 scale and full margin!
      expect(tester.widget<Transform>(scaleFinder).transform.storage[0], equals(1.0));
      final unshrunkMargin = tester.widget<Padding>(paddingFinder).padding as EdgeInsets;
      expect(unshrunkMargin.bottom, equals(16.0));
      expect(selectedIndex, equals(1));
    });
  });

  group('NixSnackBar', () {
    testWidgets('floats over all layers with stadium pill shape and dynamic width', (tester) async {
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
        find.descendant(
          of: find.byKey(const Key('nix_snack_bar_pill')),
          matching: find.byType(Row),
        ).first,
      );
      expect(rowWidget.mainAxisSize, equals(MainAxisSize.min));

      // Dismiss smoothly
      NixSnackBar.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('Dynamic Width Message'), findsNothing);
    });

    testWidgets('supports NixSnackBarPosition.bottom with slide-up entrance and slide-down exit', (tester) async {
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

      final slideTransitionFinder = find.byKey(const Key('nix_snack_bar_slide'));
      expect(slideTransitionFinder, findsOneWidget);

      // Beginning of animation: slide is positioned below resting position (offset Y > 0)
      SlideTransition slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
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
    });

    testWidgets('supports NixSnackBarPosition.top with slide-down entrance and slide-up exit', (tester) async {
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

      final slideTransitionFinder = find.byKey(const Key('nix_snack_bar_slide'));
      expect(slideTransitionFinder, findsOneWidget);

      // Beginning of animation: slide is positioned above resting position (offset Y < 0)
      SlideTransition slideWidget = tester.widget<SlideTransition>(slideTransitionFinder);
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
    });

    testWidgets('triggers onAction callback and dismisses on action click', (tester) async {
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

    testWidgets('dynamically inherits theme colors from ThemeData and NixThemeData', (tester) async {
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
                    NixSnackBar.show(
                      context,
                      message: 'Themed Toast',
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

      final materialWidget = tester.widget<Material>(
        find.byKey(const Key('nix_snack_bar_pill')),
      );

      // Verify that color is dynamically derived from teal ColorScheme.inverseSurface
      final expectedInverseSurface = ColorScheme.fromSeed(seedColor: Colors.teal).inverseSurface;
      expect(materialWidget.color, equals(expectedInverseSurface));

      NixSnackBar.dismiss();
      await tester.pumpAndSettle();
    });
  });
}
