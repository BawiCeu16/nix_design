import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('Dynamic Segmented Corner Radius Rules', () {
    test('Rule: Single item has 12px radius on all corners', () {
      final radius = NixPopupMenu.computeItemRadius(0, 1);
      expect(radius.topLeft, const Radius.circular(12.0));
      expect(radius.topRight, const Radius.circular(12.0));
      expect(radius.bottomLeft, const Radius.circular(12.0));
      expect(radius.bottomRight, const Radius.circular(12.0));
    });

    test('Rule: Two items - first has top 12px / bottom 6px; last has top 6px / bottom 12px', () {
      final first = NixPopupMenu.computeItemRadius(0, 2);
      expect(first.topLeft, const Radius.circular(12.0));
      expect(first.topRight, const Radius.circular(12.0));
      expect(first.bottomLeft, const Radius.circular(6.0));
      expect(first.bottomRight, const Radius.circular(6.0));

      final last = NixPopupMenu.computeItemRadius(1, 2);
      expect(last.topLeft, const Radius.circular(6.0));
      expect(last.topRight, const Radius.circular(6.0));
      expect(last.bottomLeft, const Radius.circular(12.0));
      expect(last.bottomRight, const Radius.circular(12.0));
    });

    test('Rule: Three or more items - first top 12/bottom 6, middle all 6, last top 6/bottom 12', () {
      final first = NixPopupMenu.computeItemRadius(0, 4);
      expect(first.topLeft, const Radius.circular(12.0));
      expect(first.topRight, const Radius.circular(12.0));
      expect(first.bottomLeft, const Radius.circular(6.0));
      expect(first.bottomRight, const Radius.circular(6.0));

      final middle1 = NixPopupMenu.computeItemRadius(1, 4);
      expect(middle1.topLeft, const Radius.circular(6.0));
      expect(middle1.topRight, const Radius.circular(6.0));
      expect(middle1.bottomLeft, const Radius.circular(6.0));
      expect(middle1.bottomRight, const Radius.circular(6.0));

      final middle2 = NixPopupMenu.computeItemRadius(2, 4);
      expect(middle2.topLeft, const Radius.circular(6.0));
      expect(middle2.topRight, const Radius.circular(6.0));
      expect(middle2.bottomLeft, const Radius.circular(6.0));
      expect(middle2.bottomRight, const Radius.circular(6.0));

      final last = NixPopupMenu.computeItemRadius(3, 4);
      expect(last.topLeft, const Radius.circular(6.0));
      expect(last.topRight, const Radius.circular(6.0));
      expect(last.bottomLeft, const Radius.circular(12.0));
      expect(last.bottomRight, const Radius.circular(12.0));
    });
  });

  group('NixPopupMenu Container & Item Rendering', () {
    testWidgets('Container has 16px border radius, 4px padding, and 2px vertical gap between items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                items: const [
                  NixPopupMenuItem(value: '1', label: Text('First')),
                  NixPopupMenuItem(value: '2', label: Text('Second')),
                  NixPopupMenuItem(value: '3', label: Text('Third')),
                ],
                child: const Text('Open Menu'),
              ),
            ),
          ),
        ),
      );

      // Tap to open
      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      // Find the menu container (it wraps the Column of items)
      final columnFinder = find.byType(Column).last;
      expect(columnFinder, findsOneWidget);

      final column = tester.widget<Column>(columnFinder);
      // 3 items + 2 gap widgets = 5 children
      expect(column.children.length, 5);

      // Verify gaps are 2px SizedBoxes
      expect(column.children[1], isA<SizedBox>());
      expect((column.children[1] as SizedBox).height, 2.0);
      expect(column.children[3], isA<SizedBox>());
      expect((column.children[3] as SizedBox).height, 2.0);

      // Find the Container wrapping the column
      final containerFinder = find.ancestor(
        of: columnFinder,
        matching: find.byType(Container),
      ).first;

      final container = tester.widget<Container>(containerFinder);
      expect(container.padding, const EdgeInsets.all(4.0));

      final decoration = container.decoration as ShapeDecoration;
      final shape = decoration.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16.0));
    });
  });

  group('Dual Gesture Support', () {
    testWidgets('Tap: Opens the popup menu via tapping and item selects it', (tester) async {
      String? selectedValue;
      bool canceled = false;
      bool itemTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onSelected: (val) => selectedValue = val,
                onCanceled: () => canceled = true,
                items: [
                  NixPopupMenuItem(
                    value: 'edit',
                    label: const Text('Edit'),
                    icon: const Icon(Icons.edit),
                    onTap: () => itemTapped = true,
                  ),
                  const NixPopupMenuItem(
                    value: 'share',
                    label: Text('Share'),
                    icon: Icon(Icons.share),
                  ),
                  const NixPopupMenuItem.destructive(
                    value: 'delete',
                    label: Text('Delete'),
                    icon: Icon(Icons.delete),
                  ),
                ],
                child: const NixButton(
                  label: Text('Options'),
                  onPressed: null,
                ),
              ),
            ),
          ),
        ),
      );

      // Menu is initially not visible
      expect(find.text('Edit'), findsNothing);

      // Quick Tap on Options button
      await tester.tap(find.text('Options'));
      await tester.pumpAndSettle();

      // Menu items are now visible
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap on 'Edit' item
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Menu is closed, callback fired
      expect(selectedValue, 'edit');
      expect(itemTapped, true);
      expect(canceled, false);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('Tap outside barrier dismisses menu and triggers onCanceled', (tester) async {
      bool canceled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: NixPopupMenu<String>(
                onCanceled: () => canceled = true,
                items: const [
                  NixPopupMenuItem(value: 'a', label: Text('Option A')),
                ],
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Option A'), findsOneWidget);

      // Tap far away on barrier (bottom right)
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();

      expect(canceled, true);
      expect(find.text('Option A'), findsNothing);
    });

    testWidgets('Hold, Drag & Release: holding reveals menu, dragging highlights, release selects item', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onSelected: (val) => selectedValue = val,
                holdDelay: const Duration(milliseconds: 200),
                items: const [
                  NixPopupMenuItem(value: 'first', label: Text('First Choice')),
                  NixPopupMenuItem(value: 'second', label: Text('Second Choice')),
                  NixPopupMenuItem(value: 'third', label: Text('Third Choice')),
                ],
                child: const NixCard(
                  child: Text('Hold Me'),
                ),
              ),
            ),
          ),
        ),
      );

      final triggerLocation = tester.getCenter(find.text('Hold Me'));

      // 1. Pointer Down on trigger
      final gesture = await tester.startGesture(triggerLocation);
      await tester.pump();

      // Menu not open yet before holdDelay
      expect(find.text('Second Choice'), findsNothing);

      // 2. Hold down past holdDelay (250ms)
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 200));

      // Menu has now opened while finger is still held down!
      expect(find.text('Second Choice'), findsOneWidget);

      // 3. Drag pointer down to the 'Second Choice' item
      final secondItemLocation = tester.getCenter(find.text('Second Choice'));
      await gesture.moveTo(secondItemLocation);
      await tester.pump();

      // 4. Release finger over the 'Second Choice' item
      await gesture.up();
      await tester.pumpAndSettle();

      // Selected value should be 'second' and menu dismissed
      expect(selectedValue, 'second');
      expect(find.text('Second Choice'), findsNothing);
    });

    testWidgets('Hold and release on trigger keeps menu open in tap mode', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onSelected: (val) => selectedValue = val,
                holdDelay: const Duration(milliseconds: 200),
                items: const [
                  NixPopupMenuItem(value: 'action', label: Text('Action Item')),
                ],
                child: const Text('Hold Trigger'),
              ),
            ),
          ),
        ),
      );

      final triggerLocation = tester.getCenter(find.text('Hold Trigger'));
      final gesture = await tester.startGesture(triggerLocation);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Action Item'), findsOneWidget);

      // Release finger on the trigger itself without moving to an item
      await gesture.up();
      await tester.pumpAndSettle();

      // Menu remains open in tap mode!
      expect(find.text('Action Item'), findsOneWidget);

      // Now tap the item to select
      await tester.tap(find.text('Action Item'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'action');
      expect(find.text('Action Item'), findsNothing);
    });

    testWidgets('Hold, drag outside and release cancels and dismisses menu', (tester) async {
      bool canceled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onCanceled: () => canceled = true,
                holdDelay: const Duration(milliseconds: 200),
                items: const [
                  NixPopupMenuItem(value: 'a', label: Text('Item A')),
                ],
                child: const Text('Hold Drag Cancel'),
              ),
            ),
          ),
        ),
      );

      final triggerLocation = tester.getCenter(find.text('Hold Drag Cancel'));
      final gesture = await tester.startGesture(triggerLocation);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Item A'), findsOneWidget);

      // Drag far away into empty space
      await gesture.moveTo(const Offset(20, 20));
      await tester.pump();

      // Release outside
      await gesture.up();
      await tester.pumpAndSettle();

      expect(canceled, true);
      expect(find.text('Item A'), findsNothing);
    });
  });

  group('Universal Widget & Feature Support', () {
    testWidgets('Works seamlessly with any widget type (Icon, Container, NixIconButton, NixChip)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NixPopupMenu<int>(
                  items: const [NixPopupMenuItem(value: 1, label: Text('One'))],
                  child: const Icon(Icons.more_horiz),
                ),
                NixPopupMenu<int>(
                  items: const [NixPopupMenuItem(value: 2, label: Text('Two'))],
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                  ),
                ),
                NixPopupMenu<int>(
                  items: const [NixPopupMenuItem(value: 3, label: Text('Three'))],
                  child: const NixIconButton.filled(
                    icon: Icon(Icons.settings),
                    onPressed: null,
                  ),
                ),
                NixPopupMenu<int>(
                  items: const [NixPopupMenuItem(value: 4, label: Text('Four'))],
                  child: const NixChip(label: Text('Chip Trigger')),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap Icon trigger
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      // Tap Container trigger
      await tester.tap(find.byType(Container).first);
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsOneWidget);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      // Tap Chip trigger
      await tester.tap(find.text('Chip Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Four'), findsOneWidget);
      await tester.tap(find.text('Four'));
      await tester.pumpAndSettle();
    });

    testWidgets('Disabled items cannot be selected', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onSelected: (val) => selectedValue = val,
                items: const [
                  NixPopupMenuItem(
                    value: 'disabled_item',
                    label: Text('Unavailable'),
                    enabled: false,
                  ),
                ],
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unavailable'));
      await tester.pumpAndSettle();

      // Should not have selected disabled item, menu remains open
      expect(selectedValue, isNull);
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('Imperative showNixPopupMenu helper opens and returns selected value', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await showNixPopupMenu<String>(
                    context: ctx,
                    position: const Offset(100, 100),
                    items: const [
                      NixPopupMenuItem(value: 'alpha', label: Text('Alpha')),
                      NixPopupMenuItem(value: 'beta', label: Text('Beta')),
                    ],
                  );
                },
                child: const Text('Show Menu'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(result, 'beta');
      expect(find.text('Beta'), findsNothing);
    });

    testWidgets('NixCustomPopup type alias works identically to NixPopupMenu', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixCustomPopup<String>(
                onSelected: (val) => result = val,
                items: const [
                  NixCustomPopupItem(value: 'custom', label: Text('Custom Item')),
                ],
                child: const Text('Custom Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Custom Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Item'), findsOneWidget);

      await tester.tap(find.text('Custom Item'));
      await tester.pumpAndSettle();

      expect(result, 'custom');
    });

    testWidgets('NixPopupMenu remains clickable and unobstructed when NixSnackBarPosition.top is showing', (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? selectedVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Title'),
              actions: [
                NixPopupMenu<String>(
                  onSelected: (val) => selectedVal = val,
                  items: const [
                    NixPopupMenuItem(value: 'profile', label: Text('Profile')),
                  ],
                  child: const NixIconButton.tonal(
                    icon: Icon(Icons.more_vert_rounded),
                    onPressed: null,
                  ),
                ),
              ],
            ),
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    NixSnackBar.show(
                      context,
                      position: NixSnackBarPosition.top,
                      maxWidth: 280,
                      message: 'Top notification pill',
                      actionLabel: 'OK',
                      onAction: () {},
                    );
                  },
                  child: const Text('Show Top'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show top snackbar
      await tester.tap(find.text('Show Top'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Top notification pill'), findsOneWidget);

      final slideFinder = find.byKey(const Key('nix_snack_bar_slide'));
      expect(tester.widget<SlideTransition>(slideFinder).position.value, equals(Offset.zero));

      // Tap popup menu in AppBar - overlay rebuilds to insert popup menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pump();

      // Crucial: NixSnackBar must NOT restart its entrance animation on overlay rebuild!
      expect(tester.widget<SlideTransition>(slideFinder).position.value, equals(Offset.zero));

      await tester.pumpAndSettle();

      // Popup menu must have opened and be visible!
      expect(find.text('Profile'), findsOneWidget);

      // Select item
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(selectedVal, 'profile');
    });

    testWidgets('Scroll or drag outside barrier dismisses menu like native Flutter popup', (tester) async {
      bool canceled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                onCanceled: () => canceled = true,
                items: const [
                  NixPopupMenuItem(value: 'a', label: Text('Option A')),
                ],
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Option A'), findsOneWidget);

      // Simulate a scroll/pointer signal outside (e.g. mouse wheel scroll)
      final pointerSignal = PointerScrollEvent(
        position: const Offset(50, 50),
        scrollDelta: const Offset(0, 20),
      );
      tester.binding.handlePointerEvent(pointerSignal);
      await tester.pumpAndSettle();

      expect(canceled, true);
      expect(find.text('Option A'), findsNothing);
    });

    testWidgets('Origin-aware animation computes alignment relative to trigger location', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                NixPopupMenu<String>(
                  items: const [
                    NixPopupMenuItem(value: 'settings', label: Text('Settings')),
                  ],
                  child: const Text('Action Right'),
                ),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      // Tap trigger on top-right of screen
      await tester.tap(find.text('Action Right'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Check Transform widget scale and alignment
      final transformFinder = find.ancestor(
        of: find.text('Settings'),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      final transformWidget = tester.widget<Transform>(transformFinder.first);
      // Because trigger is in the AppBar on the right, transform alignment X should be > 0 (right-aligned origin)
      final align = transformWidget.alignment as Alignment;
      expect(align.x, greaterThan(0.0));
      expect(align.y, lessThan(0.0)); // Opening below the trigger -> top edge origin

      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Popup menu has no border as default, and renders border only when borderColor provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                items: const [
                  NixPopupMenuItem(value: '1', label: Text('Item 1')),
                ],
                child: const Text('No Border Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('No Border Trigger'));
      await tester.pumpAndSettle();

      final outerContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(outerContainerFinder);
      final shapeDeco = container.decoration as ShapeDecoration;
      final border = (shapeDeco.shape as RoundedRectangleBorder).side;
      expect(border, equals(BorderSide.none));

      // Dismiss menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Now with explicit borderColor
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                borderColor: Colors.red,
                items: const [
                  NixPopupMenuItem(value: '1', label: Text('Border Item')),
                ],
                child: const Text('With Border Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('With Border Trigger'));
      await tester.pumpAndSettle();

      final borderContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final borderContainer = tester.widget<Container>(borderContainerFinder);
      final borderShapeDeco = borderContainer.decoration as ShapeDecoration;
      final customBorder = (borderShapeDeco.shape as RoundedRectangleBorder).side;
      expect(customBorder.color, equals(Colors.red));
      expect(customBorder.width, equals(1.0));
    });

    testWidgets('Popup menu default maxWidth is 200, adapts to longer text, and stays 200 if ellipsis is specified', (tester) async {
      // 1. Short text -> default 200 width
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                items: const [
                  NixPopupMenuItem(value: 'short', label: Text('Short')),
                ],
                child: const Text('Short Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Short Trigger'));
      await tester.pumpAndSettle();

      final shortContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final shortBox = tester.renderObject<RenderBox>(shortContainerFinder);
      expect(shortBox.size.width, equals(200.0));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 2. Long text without ellipsis -> adapts width to fit text (> 200)
      const longText = 'This is an exceptionally long menu label that should cause the menu to adapt its width';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                items: const [
                  NixPopupMenuItem(value: 'long', label: Text(longText)),
                ],
                child: const Text('Long Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Long Trigger'));
      await tester.pumpAndSettle();

      final longContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final longBox = tester.renderObject<RenderBox>(longContainerFinder);
      expect(longBox.size.width, greaterThan(200.0));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 3. Long text WITH TextOverflow.ellipsis -> uses default maxWidth 200
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                items: const [
                  NixPopupMenuItem(
                    value: 'ellipsis',
                    label: Text(longText, overflow: TextOverflow.ellipsis),
                  ),
                ],
                child: const Text('Ellipsis Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ellipsis Trigger'));
      await tester.pumpAndSettle();

      final ellipsisContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final ellipsisBox = tester.renderObject<RenderBox>(ellipsisContainerFinder);
      expect(ellipsisBox.size.width, equals(200.0));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 4. Developer sets maxWidth manually -> strictly uses manual maxWidth
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NixPopupMenu<String>(
                maxWidth: 260.0,
                items: const [
                  NixPopupMenuItem(value: 'custom', label: Text('Custom Max Width')),
                ],
                child: const Text('Custom Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Custom Trigger'));
      await tester.pumpAndSettle();

      final customContainerFinder = find.descendant(
        of: find.byType(CustomSingleChildLayout),
        matching: find.byType(Container),
      ).first;
      final customBox = tester.renderObject<RenderBox>(customContainerFinder);
      expect(customBox.size.width, equals(260.0));
    });

    testWidgets('Fix: popup button inside body ListView does NOT trigger body scroll on press-hold and drag', (tester) async {
      final scrollController = ScrollController();
      String? selectedVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 100),
                NixPopupMenu<String>(
                  onSelected: (val) => selectedVal = val,
                  holdDelay: const Duration(milliseconds: 200),
                  items: const [
                    NixPopupMenuItem(value: 'item1', label: Text('List Item 1')),
                    NixPopupMenuItem(value: 'item2', label: Text('List Item 2')),
                  ],
                  child: Container(
                    height: 50,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text('Popup In Body ListView'),
                  ),
                ),
                // Lots of scrollable content below
                const SizedBox(height: 1500),
              ],
            ),
          ),
        ),
      );

      expect(scrollController.offset, equals(0.0));

      final triggerFinder = find.text('Popup In Body ListView');
      final triggerLocation = tester.getCenter(triggerFinder);

      // 1. Pointer Down on popup trigger inside ListView
      final gesture = await tester.startGesture(triggerLocation);
      await tester.pump();

      // Verify no scroll occurred
      expect(scrollController.offset, equals(0.0));

      // 2. Press & hold past holdDelay (200ms)
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200)); // settle opening animation

      // Popup menu is now open!
      expect(find.text('List Item 2'), findsOneWidget);
      // ListView still did NOT scroll!
      expect(scrollController.offset, equals(0.0));

      // 3. Drag vertically down to 'List Item 2'
      final item2Location = tester.getCenter(find.text('List Item 2'));
      await gesture.moveTo(item2Location);
      await tester.pump();

      // CRITICAL ASSERTION: The body ListView MUST NOT have scrolled while holding and dragging!
      expect(scrollController.offset, equals(0.0));

      // 4. Release over item 2
      await gesture.up();
      await tester.pumpAndSettle();

      // Selected value should be item2 and body offset remains 0
      expect(selectedVal, equals('item2'));
      expect(scrollController.offset, equals(0.0));
      expect(find.text('List Item 2'), findsNothing);
    });
  });
}
