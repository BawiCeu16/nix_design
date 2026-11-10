import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixListPhysics & Dynamic Segmented Corner Radii', () {
    test('Rule: Single item has 12px on all 4 corners', () {
      final radius = NixListPhysics.computeSegmentedRadius(
        index: 0,
        totalCount: 1,
      );

      expect(radius.topLeft, const Radius.circular(12.0));
      expect(radius.topRight, const Radius.circular(12.0));
      expect(radius.bottomLeft, const Radius.circular(12.0));
      expect(radius.bottomRight, const Radius.circular(12.0));
    });

    test('Rule: 3 items - first has top 12px / bottom 6px, middle all 6px, last top 6px / bottom 12px', () {
      final first = NixListPhysics.computeSegmentedRadius(
        index: 0,
        totalCount: 3,
      );
      expect(first.topLeft, const Radius.circular(12.0));
      expect(first.topRight, const Radius.circular(12.0));
      expect(first.bottomLeft, const Radius.circular(6.0));
      expect(first.bottomRight, const Radius.circular(6.0));

      final middle = NixListPhysics.computeSegmentedRadius(
        index: 1,
        totalCount: 3,
      );
      expect(middle.topLeft, const Radius.circular(6.0));
      expect(middle.topRight, const Radius.circular(6.0));
      expect(middle.bottomLeft, const Radius.circular(6.0));
      expect(middle.bottomRight, const Radius.circular(6.0));

      final last = NixListPhysics.computeSegmentedRadius(
        index: 2,
        totalCount: 3,
      );
      expect(last.topLeft, const Radius.circular(6.0));
      expect(last.topRight, const Radius.circular(6.0));
      expect(last.bottomLeft, const Radius.circular(12.0));
      expect(last.bottomRight, const Radius.circular(12.0));
    });

    test('Rule: Dynamic neighbor sealing when adjacent card is selected or playing', () {
      // Suppose index 1 is selected/playing (detached):
      // Index 0 (first) should have its bottom seal with 12px radius!
      final item0 = NixListPhysics.computeSegmentedRadius(
        index: 0,
        totalCount: 3,
        nextDetached: true,
      );
      expect(item0.topLeft, const Radius.circular(12.0));
      expect(item0.bottomLeft, const Radius.circular(12.0));

      // Index 1 (detached) has 14px on all corners
      final item1 = NixListPhysics.computeSegmentedRadius(
        index: 1,
        totalCount: 3,
        isSelected: true,
      );
      expect(item1.topLeft, const Radius.circular(14.0));
      expect(item1.topRight, const Radius.circular(14.0));
      expect(item1.bottomLeft, const Radius.circular(14.0));
      expect(item1.bottomRight, const Radius.circular(14.0));

      // Index 2 (last) should have its top seal with 12px radius!
      final item2 = NixListPhysics.computeSegmentedRadius(
        index: 2,
        totalCount: 3,
        prevDetached: true,
      );
      expect(item2.topLeft, const Radius.circular(12.0));
      expect(item2.bottomLeft, const Radius.circular(12.0));
    });

    test('Neighbour reach and shape changes under squish compression', () {
      // Middle item with top squish reach
      final squished = NixListPhysics.computeSegmentedRadius(
        index: 1,
        totalCount: 3,
        squishTopReach: 0.5,
      );
      // Base top was 6.0, squishTopReach 0.5 * 3.0 = 1.5 => 4.5
      expect(squished.topLeft.x, closeTo(4.5, 0.01));
      expect(squished.topRight.x, closeTo(4.5, 0.01));
      expect(squished.bottomLeft.x, 6.0);
    });

    test('Neighbour Squish Physics: volume-preserving squash & stretch', () {
      final squish = NixListPhysics.computeSquishScale(reachFactor: 1.0);
      expect(squish.scaleY, closeTo(0.93, 0.001)); // compressed vertically
      expect(squish.scaleX, closeTo(1.035, 0.001)); // expanded horizontally

      final reach = NixListPhysics.computeReachFactor(
        dragCenterY: 100.0,
        neighborCenterY: 120.0,
        reachDistance: 80.0,
      );
      expect(reach, closeTo(0.75, 0.01));

      final disp = NixListPhysics.computeDisplacementOffset(
        reachFactor: reach,
        isDraggedAbove: true,
        maxDisplacement: 10.0,
      );
      expect(disp, closeTo(7.5, 0.01));
    });

    test('Neighbour horizontal pull offset and vertical compression on swipe', () {
      final pull = NixListPhysics.computeSwipeNeighborPull(
        swipeOffset: 150.0,
        itemWidth: 300.0,
        isNeighborAbove: true,
      );
      expect(pull.offsetX, closeTo(3.0, 0.01));
      expect(pull.offsetY, closeTo(1.5, 0.01));
      expect(pull.scaleY, lessThan(1.0));
    });
  });

  group('NixListView & NixListItem Rendering & Container', () {
    testWidgets('Renders 16px container with surfaceContainer background and segmented items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: NixListView(
              children: const [
                NixListItem(title: Text('Track 1'), subtitle: Text('Artist 1')),
                NixListItem(title: Text('Track 2'), subtitle: Text('Artist 2')),
                NixListItem(title: Text('Track 3'), subtitle: Text('Artist 3')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Track 1'), findsOneWidget);
      expect(find.text('Track 2'), findsOneWidget);
      expect(find.text('Track 3'), findsOneWidget);

      // Verify container decoration has 16px radius
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16.0));
    });

    testWidgets('Lazily builds with NixListView.builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: NixListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return NixListItem(
                  title: Text('Item #$index'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item #0'), findsOneWidget);
      expect(find.text('Item #1'), findsOneWidget);
    });
  });

  group('Selection & Active/Playing States', () {
    testWidgets('Multi-selection mode toggles items and invokes onSelectionChanged', (tester) async {
      Set<int> selected = {};

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NixListView(
                  selectionMode: NixSelectionMode.multi,
                  selectedIndices: selected,
                  onSelectionChanged: (indices) {
                    setState(() => selected = indices);
                  },
                  children: const [
                    NixListItem(title: Text('Option 0')),
                    NixListItem(title: Text('Option 1')),
                    NixListItem(title: Text('Option 2')),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first item to select
      await tester.tap(find.text('Option 0'));
      await tester.pumpAndSettle();

      expect(selected.contains(0), isTrue);

      // Tap second item to select
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      expect(selected.contains(0), isTrue);
      expect(selected.contains(1), isTrue);

      // Tap first item again to deselect
      await tester.tap(find.text('Option 0'));
      await tester.pumpAndSettle();

      expect(selected.contains(0), isFalse);
      expect(selected.contains(1), isTrue);
    });

    testWidgets('Playing / Active item renders NixMusicEqualizer and morphs into isolated card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: NixListView(
              playingIndex: 1,
              children: const [
                NixListItem(title: Text('Song 1')),
                NixListItem(title: Text('Song 2')),
                NixListItem(title: Text('Song 3')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NixMusicEqualizer), findsOneWidget);
    });
  });

  group('Independent Dismiss Left / Right Actions', () {
    testWidgets('Swipe Right triggers leftAction and dismisses item', (tester) async {
      bool leftActionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                children: [
                  NixListItem(
                    title: const Text('Swipeable Item'),
                    leftAction: NixSwipeAction(
                      icon: const Icon(Icons.archive),
                      label: const Text('Archive'),
                      actionType: NixSwipeActionType.dismiss,
                      onTriggered: () {
                        leftActionFired = true;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swipeable Item'), findsOneWidget);

      // Drag to the right across threshold
      await tester.drag(find.text('Swipeable Item'), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();

      expect(leftActionFired, isTrue);
      expect(find.text('Swipeable Item'), findsNothing);
    });

    testWidgets('Swipe Left triggers rightAction without dismiss when actionType is action', (tester) async {
      bool rightActionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                children: [
                  NixListItem(
                    title: const Text('Action Item'),
                    rightAction: NixSwipeAction(
                      icon: const Icon(Icons.favorite),
                      label: const Text('Favorite'),
                      actionType: NixSwipeActionType.action,
                      onTriggered: () {
                        rightActionFired = true;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag to the left across threshold
      await tester.drag(find.text('Action Item'), const Offset(-200.0, 0.0));
      await tester.pumpAndSettle();

      expect(rightActionFired, isTrue);
      // Item springs back and remains visible
      expect(find.text('Action Item'), findsOneWidget);
    });
  });

  group('Reordering & NixReorderHandle', () {
    testWidgets('Reorder handle triggers reorder drag and invokes onReorder', (tester) async {
      int? reorderedFrom;
      int? reorderedTo;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: NixListView(
                reorderable: true,
                onReorder: (oldIdx, newIdx) {
                  reorderedFrom = oldIdx;
                  reorderedTo = newIdx;
                },
                children: const [
                  NixListItem(
                    title: Text('Row 0'),
                    reorderHandle: NixReorderHandle(),
                  ),
                  NixListItem(
                    title: Text('Row 1'),
                    reorderHandle: NixReorderHandle(),
                  ),
                  NixListItem(
                    title: Text('Row 2'),
                    reorderHandle: NixReorderHandle(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handleFinder = find.byType(NixReorderHandle).first;
      expect(handleFinder, findsOneWidget);

      // Drag handle down past slot 1
      final gesture = await tester.startGesture(tester.getCenter(handleFinder));
      await tester.pump();
      await gesture.moveBy(const Offset(0.0, 55.0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(reorderedFrom, equals(0));
      expect(reorderedTo, equals(1));
    });
  });
}
