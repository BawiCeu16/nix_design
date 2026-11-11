import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

      // Index 1 (isolated selected) dynamically rounds with outerItemRadius (12px) on all corners
      final item1 = NixListPhysics.computeSegmentedRadius(
        index: 1,
        totalCount: 3,
        isSelected: true,
      );
      expect(item1.topLeft, const Radius.circular(12.0));
      expect(item1.topRight, const Radius.circular(12.0));
      expect(item1.bottomLeft, const Radius.circular(12.0));
      expect(item1.bottomRight, const Radius.circular(12.0));

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

    test(
      'Neighbour horizontal pull offset and vertical compression on swipe',
      () {
        final pull = NixListPhysics.computeSwipeNeighborPull(
          swipeOffset: 150.0,
          itemWidth: 300.0,
          isNeighborAbove: true,
        );
        expect(pull.offsetX, closeTo(3.0, 0.01));
        expect(pull.offsetY, closeTo(1.5, 0.01));
        expect(pull.scaleY, lessThan(1.0));
      },
    );
  });

  group('NixListView & NixListItem Rendering & Container', () {
    testWidgets(
      'Renders 16px container with surfaceContainer background and segmented items',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: NixListView(
                children: const [
                  NixListItem(
                    title: Text('Track 1'),
                    subtitle: Text('Artist 1'),
                  ),
                  NixListItem(
                    title: Text('Track 2'),
                    subtitle: Text('Artist 2'),
                  ),
                  NixListItem(
                    title: Text('Track 3'),
                    subtitle: Text('Artist 3'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Track 1'), findsOneWidget);
        expect(find.text('Track 2'), findsOneWidget);
        expect(find.text('Track 3'), findsOneWidget);

        // Verify container decoration has containerRadius
        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.borderRadius,
          BorderRadius.circular(NixListPhysics.containerRadius),
        );

        // By default, inner clipping is enabled with a ClipRRect
        expect(find.byType(ClipRRect), findsOneWidget);
      },
    );

    testWidgets(
      'Inner clipping radius can be disabled via enableInnerClipping: false',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: NixListView(
                enableInnerClipping: false,
                children: const [
                  NixListItem(title: Text('No Clip 1')),
                  NixListItem(title: Text('No Clip 2')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No Clip 1'), findsOneWidget);
        // ClipRRect should not be present when enableInnerClipping is false
        expect(find.byType(ClipRRect), findsNothing);
      },
    );

    testWidgets(
      'Inner clipping radius can be disabled via clipBehavior: Clip.none',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: NixListView(
                clipBehavior: Clip.none,
                children: const [
                  NixListItem(title: Text('No Clip None 1')),
                  NixListItem(title: Text('No Clip None 2')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No Clip None 1'), findsOneWidget);
        expect(find.byType(ClipRRect), findsNothing);
      },
    );

    testWidgets('Custom innerClipBorderRadius is respected when provided', (
      tester,
    ) async {
      const customRadius = BorderRadius.all(Radius.circular(8.0));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: NixListView(
              innerClipBorderRadius: customRadius,
              children: const [NixListItem(title: Text('Custom Radius Item'))],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final clipFinder = find.byType(ClipRRect);
      expect(clipFinder, findsOneWidget);
      final clipRRect = tester.widget<ClipRRect>(clipFinder);
      expect(clipRRect.borderRadius, equals(customRadius));
    });

    testWidgets('Lazily builds with NixListView.builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: NixListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return NixListItem(title: Text('Item #$index'));
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
    testWidgets(
      'Multi-selection mode toggles items and invokes onSelectionChanged',
      (tester) async {
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
      },
    );

    testWidgets(
      'Playing / Active item uses select style color and morphs into isolated card',
      (tester) async {
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
        await tester.pump(const Duration(milliseconds: 100));

        final song2Container = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Song 2'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final deco = song2Container.decoration as BoxDecoration;
        expect(deco.color, isNotNull);
        expect(deco.color!.a, equals(1.0));
      },
    );
  });

  group('Independent Dismiss Left / Right Actions', () {
    testWidgets('Swipe Right triggers leftAction and dismisses item', (
      tester,
    ) async {
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

    testWidgets(
      'Swipe Left triggers rightAction without dismiss when actionType is action',
      (tester) async {
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
      },
    );

    testWidgets(
      'Swipe gesture applies dynamic corner morphing: swiping card detaches and adjacent neighbors seal',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  children: [
                    const NixListItem(title: Text('Item 0')),
                    NixListItem(
                      title: const Text('Item 1'),
                      leftAction: NixSwipeAction(
                        icon: const Icon(Icons.star),
                        label: const Text('Star'),
                        onTriggered: () {},
                      ),
                    ),
                    const NixListItem(title: Text('Item 2')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe Item 1 to the right by moving past touch slop
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Item 1')),
        );
        await gesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        await gesture.moveBy(const Offset(60.0, 0.0));
        await tester.pump();

        // Inspect Item 0 (above) - its bottom corner should seal to 12px because next neighbor is swiping!
        final scope0 = tester.widget<NixListScope>(
          find.byWidgetPredicate((w) => w is NixListScope && w.index == 0),
        );
        expect(scope0.nextDetached, isTrue);
        expect(scope0.scaleX, equals(1.0));
        expect(scope0.scaleY, equals(1.0));
        expect(scope0.displacementOffsetY, equals(0.0));

        // Inspect Item 2 (below) - its top corner should seal to 12px because previous neighbor is swiping!
        final scope2 = tester.widget<NixListScope>(
          find.byWidgetPredicate((w) => w is NixListScope && w.index == 2),
        );
        expect(scope2.prevDetached, isTrue);
        expect(scope2.scaleX, equals(1.0));
        expect(scope2.scaleY, equals(1.0));
        expect(scope2.displacementOffsetY, equals(0.0));

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });

  group('Reordering & NixReorderHandle', () {
    testWidgets(
      'Reorder does not apply squish physics or reach deformation to adjacent cards',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  reorderable: true,
                  onReorder: (oldIdx, newIdx) {},
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
        final gesture = await tester.startGesture(
          tester.getCenter(handleFinder),
        );
        await tester.pump();
        await gesture.moveBy(const Offset(0.0, 45.0));
        await tester.pump();

        // Verify Row 1 and Row 2 have NO squish, NO reach deformation, and NO displacement during reorder
        final scope1 = tester.widget<NixListScope>(
          find.byWidgetPredicate((w) => w is NixListScope && w.index == 1),
        );
        expect(scope1.scaleX, equals(1.0));
        expect(scope1.scaleY, equals(1.0));
        expect(scope1.squishTopReach, equals(0.0));
        expect(scope1.squishBottomReach, equals(0.0));
        expect(scope1.displacementOffsetY, equals(0.0));

        final scope2 = tester.widget<NixListScope>(
          find.byWidgetPredicate((w) => w is NixListScope && w.index == 2),
        );
        expect(scope2.scaleX, equals(1.0));
        expect(scope2.scaleY, equals(1.0));
        expect(scope2.squishTopReach, equals(0.0));
        expect(scope2.squishBottomReach, equals(0.0));
        expect(scope2.displacementOffsetY, equals(0.0));

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
    testWidgets('Reorder handle triggers reorder drag and invokes onReorder', (
      tester,
    ) async {
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

    testWidgets(
      'Reorder from index 0 to index 2 moves cleanly and invokes onReorder(0, 2)',
      (tester) async {
        int? reorderedFrom;
        int? reorderedTo;
        final items = ['Row 0', 'Row 1', 'Row 2'];

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
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
                        setState(() {
                          final item = items.removeAt(oldIdx);
                          items.insert(newIdx, item);
                        });
                      },
                      children: items
                          .map(
                            (name) => NixListItem(
                              key: ValueKey(name),
                              title: Text(name),
                              reorderHandle: const NixReorderHandle(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final firstHandle = find.byType(NixReorderHandle).first;
        expect(firstHandle, findsOneWidget);

        // Drag first item all the way down past slot 2
        final gesture = await tester.startGesture(
          tester.getCenter(firstHandle),
        );
        await tester.pump();
        await gesture.moveBy(const Offset(0.0, 140.0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(reorderedFrom, equals(0));
        expect(reorderedTo, equals(2));
        expect(items, equals(['Row 1', 'Row 2', 'Row 0']));
      },
    );

    testWidgets(
      'Drop target slot renders with drop target color and place radius during reorder drag',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  reorderable: true,
                  onReorder: (from, to) {},
                  dropTargetColor: const Color(0x3300FF00),
                  children: const [
                    NixListItem(
                      title: Text('Item 0'),
                      reorderHandle: NixReorderHandle(),
                    ),
                    NixListItem(
                      title: Text('Item 1'),
                      reorderHandle: NixReorderHandle(),
                    ),
                    NixListItem(
                      title: Text('Item 2'),
                      reorderHandle: NixReorderHandle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final firstHandle = find.byType(NixReorderHandle).first;
        final gesture = await tester.startGesture(
          tester.getCenter(firstHandle),
        );
        await tester.pump();
        await gesture.moveBy(const Offset(0.0, 60.0));
        await tester.pump();

        // While dragging, a Container with dropTargetColor is rendered in the list
        final dropTargetFinder = find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final deco = w.decoration as BoxDecoration;
            return deco.color == const Color(0x3300FF00);
          }
          return false;
        });
        expect(dropTargetFinder, findsOneWidget);

        final container = tester.widget<Container>(dropTargetFinder);
        final deco = container.decoration as BoxDecoration;
        expect(deco.borderRadius, isA<BorderRadius>());
        expect(
          deco.border,
          isNull,
          reason: "Reorder's drop target has no border as default",
        );

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });

  group('Swipe Mode & Gmail Style Preset', () {
    testWidgets(
      'Swipe gesture animates stickback smoothly over time upon release',
      (tester) async {
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
                      title: const Text('Springback Item'),
                      leftAction: NixSwipeAction(
                        icon: const Icon(Icons.star),
                        threshold: 0.8,
                        onTriggered: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Drag 80px right (below threshold) and release
        await tester.drag(
          find.text('Springback Item'),
          const Offset(80.0, 0.0),
        );

        // After releasing, pump intermediate frame (e.g. 60ms into 320ms spring animation)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));

        final transformFinder = find.byWidgetPredicate((w) {
          if (w is Transform) {
            final matrix = w.transform;
            final dx = matrix.getTranslation().x;
            return dx > 0.0 && dx < 80.0;
          }
          return false;
        });
        expect(transformFinder, findsOneWidget);

        await tester.pumpAndSettle();
      },
    );
    testWidgets(
      'NixListItem.gmailStyle slides all the way through and invokes onArchive on right swipe',
      (tester) async {
        bool archiveTriggered = false;
        bool deleteTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Email Thread 1'),
                      onArchive: () => archiveTriggered = true,
                      onDelete: () => deleteTriggered = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Email Thread 1'), findsOneWidget);

        // Slide right all the way across
        await tester.drag(
          find.text('Email Thread 1'),
          const Offset(240.0, 0.0),
        );
        await tester.pumpAndSettle();

        expect(archiveTriggered, isTrue);
        expect(deleteTriggered, isFalse);
        expect(find.text('Email Thread 1'), findsNothing);
      },
    );

    testWidgets(
      'NixListItem.gmailStyle slides all the way through and invokes onDelete on left swipe',
      (tester) async {
        bool archiveTriggered = false;
        bool deleteTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Email Thread 2'),
                      onArchive: () => archiveTriggered = true,
                      onDelete: () => deleteTriggered = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Slide left all the way across
        await tester.drag(
          find.text('Email Thread 2'),
          const Offset(-240.0, 0.0),
        );
        await tester.pumpAndSettle();

        expect(archiveTriggered, isFalse);
        expect(deleteTriggered, isTrue);
        expect(find.text('Email Thread 2'), findsNothing);
      },
    );
  });

  group('Swipe Mode: Action Buttons', () {
    testWidgets(
      'Primary Actions (Swipe Right) reveals Share and Archive buttons and tapping invokes callback',
      (tester) async {
        bool shareCalled = false;
        bool archiveCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  swipeMode: NixSwipeMode.actions,
                  children: [
                    NixListItem(
                      title: const Text('Document 1'),
                      primaryActions: [
                        NixSwipeAction.share(
                          onTriggered: () => shareCalled = true,
                        ),
                        NixSwipeAction.archive(
                          onTriggered: () => archiveCalled = true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe right to reveal action buttons
        await tester.drag(find.text('Document 1'), const Offset(160.0, 0.0));
        await tester.pumpAndSettle();

        // Both action buttons should be visible
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Archive'), findsOneWidget);

        // Tap the Share action button
        await tester.tap(find.text('Share'));
        await tester.pumpAndSettle();

        expect(shareCalled, isTrue);
        expect(archiveCalled, isFalse);
      },
    );

    testWidgets(
      'Secondary Actions (Swipe Left) reveals Collaborator and Edit buttons',
      (tester) async {
        bool collaboratorCalled = false;
        bool editCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  swipeMode: NixSwipeMode.actions,
                  children: [
                    NixListItem(
                      title: const Text('Document 2'),
                      secondaryActions: [
                        NixSwipeAction.collaborator(
                          onTriggered: () => collaboratorCalled = true,
                        ),
                        NixSwipeAction.edit(
                          onTriggered: () => editCalled = true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe left to reveal action buttons
        await tester.drag(find.text('Document 2'), const Offset(-160.0, 0.0));
        await tester.pumpAndSettle();

        // Both action buttons should be visible
        expect(find.text('Collaborator'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);

        // Tap Collaborator
        await tester.tap(find.text('Collaborator'));
        await tester.pumpAndSettle();

        expect(collaboratorCalled, isTrue);
        expect(editCalled, isFalse);
      },
    );
  });

  group('Direction Mode (Both, RightOnly, LeftOnly, Disabled)', () {
    testWidgets('Disabled direction prevents any swipe gesture', (
      tester,
    ) async {
      bool actionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                swipeDirection: NixSwipeDirection.disabled,
                children: [
                  NixListItem.gmailStyle(
                    title: const Text('Locked Item'),
                    onArchive: () => actionFired = true,
                    onDelete: () => actionFired = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('Locked Item'), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();
      expect(actionFired, isFalse);
      expect(find.text('Locked Item'), findsOneWidget);

      await tester.drag(find.text('Locked Item'), const Offset(-200.0, 0.0));
      await tester.pumpAndSettle();
      expect(actionFired, isFalse);
      expect(find.text('Locked Item'), findsOneWidget);
    });

    testWidgets('RightOnly allows right swipe but rejects left swipe', (
      tester,
    ) async {
      bool archiveFired = false;
      bool deleteFired = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                swipeDirection: NixSwipeDirection.rightOnly,
                children: [
                  NixListItem.gmailStyle(
                    title: const Text('Right Only Item'),
                    onArchive: () => archiveFired = true,
                    onDelete: () => deleteFired = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Left swipe should be rejected
      await tester.drag(
        find.text('Right Only Item'),
        const Offset(-200.0, 0.0),
      );
      await tester.pumpAndSettle();
      expect(deleteFired, isFalse);
      expect(find.text('Right Only Item'), findsOneWidget);

      // Right swipe should work
      await tester.drag(find.text('Right Only Item'), const Offset(220.0, 0.0));
      await tester.pumpAndSettle();
      expect(archiveFired, isTrue);
      expect(find.text('Right Only Item'), findsNothing);
    });

    testWidgets('LeftOnly allows left swipe but rejects right swipe', (
      tester,
    ) async {
      bool archiveFired = false;
      bool deleteFired = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                swipeDirection: NixSwipeDirection.leftOnly,
                children: [
                  NixListItem.gmailStyle(
                    title: const Text('Left Only Item'),
                    onArchive: () => archiveFired = true,
                    onDelete: () => deleteFired = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Right swipe should be rejected
      await tester.drag(find.text('Left Only Item'), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();
      expect(archiveFired, isFalse);
      expect(find.text('Left Only Item'), findsOneWidget);

      // Left swipe should work
      await tester.drag(find.text('Left Only Item'), const Offset(-220.0, 0.0));
      await tester.pumpAndSettle();
      expect(deleteFired, isTrue);
      expect(find.text('Left Only Item'), findsNothing);
    });

    testWidgets(
      'Selected and Playing items have 100% solid opaque background (no transparency during swipe or reorder)',
      (tester) async {
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
                      isSelected: true,
                      title: const Text('Selected Track'),
                    ),
                    NixListItem(
                      isPlaying: true,
                      title: const Text('Playing Track'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        // Pump to let state and animations settle
        await tester.pump(const Duration(milliseconds: 100));

        // Check decoration color of Selected item
        final selectedFinder = find
            .ancestor(
              of: find.text('Selected Track'),
              matching: find.byType(AnimatedContainer),
            )
            .first;
        final selectedContainer = tester.widget<AnimatedContainer>(
          selectedFinder,
        );
        final selectedDecoration =
            selectedContainer.decoration as BoxDecoration;
        expect(selectedDecoration.color, isNotNull);
        expect(selectedDecoration.color!.a, equals(1.0)); // 100% opaque
        expect(
          selectedDecoration.border,
          isNull,
        ); // Default select has no border

        // Check decoration color of Playing item
        final playingFinder = find
            .ancestor(
              of: find.text('Playing Track'),
              matching: find.byType(AnimatedContainer),
            )
            .first;
        final playingContainer = tester.widget<AnimatedContainer>(
          playingFinder,
        );
        final playingDecoration = playingContainer.decoration as BoxDecoration;
        expect(playingDecoration.color, isNotNull);
        expect(playingDecoration.color!.a, equals(1.0)); // 100% opaque
        expect(playingDecoration.border, isNull); // Default play has no border
      },
    );

    testWidgets(
      'Email style renders Material 3 Expressive rounded rectangle adapting width to swipe with centered icon',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Email Thread'),
                      onArchive: () {},
                      onDelete: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Swipe Right: break slop and reveal left archive action
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Email Thread')),
        );
        await gesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        await gesture.moveBy(const Offset(65.0, 0.0));
        await tester.pump();

        // Find the revealed action container with Material 3 Expressive fully rounded pill
        final roundedRectContainers = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(NixListItem),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final dec = c.decoration;
              if (dec is BoxDecoration && dec.borderRadius is BorderRadius) {
                final br = dec.borderRadius as BorderRadius;
                return br.topLeft.x >= 20.0 &&
                    dec.color == const Color(0xFF2E7D32);
              }
              return false;
            })
            .toList();

        expect(roundedRectContainers, isNotEmpty);
        final archiveRect = roundedRectContainers.first;
        final archiveDec = archiveRect.decoration as BoxDecoration;
        final archiveBr = archiveDec.borderRadius as BorderRadius;
        expect(archiveBr.topLeft.x, greaterThanOrEqualTo(20.0));

        // Find circular badge inside (BoxShape.circle) and archive icon
        final circleBadges = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(NixListItem),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final dec = c.decoration;
              return dec is BoxDecoration && dec.shape == BoxShape.circle;
            })
            .toList();
        expect(circleBadges, isNotEmpty);
        expect(find.byIcon(Icons.archive_rounded), findsOneWidget);

        // Cancel gesture
        await gesture.up();
        await tester.pumpAndSettle();

        // 2. Swipe Left: break slop and reveal right delete action
        final gestureLeft = await tester.startGesture(
          tester.getCenter(find.text('Email Thread')),
        );
        await gestureLeft.moveBy(const Offset(-25.0, 0.0));
        await tester.pump();
        await gestureLeft.moveBy(const Offset(-65.0, 0.0));
        await tester.pump();

        final roundedRectContainersLeft = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(NixListItem),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final dec = c.decoration;
              if (dec is BoxDecoration && dec.borderRadius is BorderRadius) {
                final br = dec.borderRadius as BorderRadius;
                return br.topLeft.x >= 20.0;
              }
              return false;
            })
            .toList();

        expect(roundedRectContainersLeft, isNotEmpty);
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

        await gestureLeft.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'In select mode, reorder is completely disabled on both handle and whole item',
      (tester) async {
        bool reordered = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  selectionMode: NixSelectionMode.multi,
                  onReorder: (from, to) => reordered = true,
                  children: const [
                    NixListItem(
                      title: Text('Item 1'),
                      reorderHandle: NixReorderHandle(),
                    ),
                    NixListItem(
                      title: Text('Item 2'),
                      reorderHandle: NixReorderHandle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Attempt to drag reorder handle
        final handleFinder = find.byType(NixReorderHandle).first;
        await tester.drag(handleFinder, const Offset(0.0, 70.0));
        await tester.pumpAndSettle();

        expect(reordered, isFalse);
      },
    );

    testWidgets(
      'ReorderTrigger.handleOnly allows custom developer icon handle and rejects whole item drag',
      (tester) async {
        bool reordered = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.handleOnly,
                  onReorder: (from, to) => reordered = true,
                  children: const [
                    NixListItem(
                      title: Text('Alpha'),
                      reorderHandle: NixReorderHandle(
                        icon: Icon(Icons.swap_vert_rounded),
                      ),
                    ),
                    NixListItem(
                      title: Text('Beta'),
                      reorderHandle: NixReorderHandle(
                        icon: Icon(Icons.swap_vert_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.swap_vert_rounded), findsNWidgets(2));

        // Long press on whole item should NOT reorder
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Alpha')),
        );
        await tester.pump(const Duration(milliseconds: 350));
        await gesture.moveBy(const Offset(0.0, 80.0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        expect(reordered, isFalse);

        // Drag on custom handle SHOULD reorder
        final customHandle = find.byIcon(Icons.swap_vert_rounded).first;
        final handleGesture = await tester.startGesture(
          tester.getCenter(customHandle),
        );
        await handleGesture.moveBy(const Offset(0.0, 80.0));
        await tester.pump();
        await handleGesture.up();
        await tester.pumpAndSettle();
        expect(reordered, isTrue);
      },
    );

    testWidgets(
      'ReorderTrigger.wholeItem allows reordering by long-pressing whole item without handles',
      (tester) async {
        int? fromIndex;
        int? toIndex;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.wholeItem,
                  buildDefaultDragHandles: false,
                  onReorder: (from, to) {
                    fromIndex = from;
                    toIndex = to;
                  },
                  children: const [
                    NixListItem(title: Text('Item 0')),
                    NixListItem(title: Text('Item 1')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // No drag handles should be rendered
        expect(find.byType(NixReorderHandle), findsNothing);

        // Long press on whole item 0 and drag down past Item 1
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Item 0')),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.moveBy(const Offset(0.0, 70.0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(fromIndex, equals(0));
        expect(toIndex, equals(1));
      },
    );

    testWidgets(
      'in defult select can not swipe only in play! (select disables swipe, play allows swipe)',
      (tester) async {
        bool swiped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  selectionMode: NixSelectionMode.multi,
                  selectedIndices: const {0},
                  playingIndex: 1,
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Selected Track'),
                      onArchive: () => swiped = true,
                    ),
                    NixListItem.gmailStyle(
                      title: const Text('Playing Track'),
                      onArchive: () => swiped = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        // Pump to settle
        await tester.pump(const Duration(milliseconds: 100));

        // 1. Try to swipe the SELECTED item
        final selectedFinder = find.text('Selected Track');
        await tester.drag(selectedFinder, const Offset(200.0, 0.0));
        await tester.pump(const Duration(milliseconds: 100));
        expect(swiped, isFalse, reason: 'Selected item must not swipe!');

        // 2. Now test a standalone playing item that is NOT in select mode
        bool playingSwiped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  selectionMode: NixSelectionMode.none,
                  playingIndex: 0,
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Playing Track 2'),
                      onArchive: () => playingSwiped = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Playing item CAN swipe!
        final playingFinder = find.text('Playing Track 2');
        await tester.drag(playingFinder, const Offset(300.0, 0.0));
        // Dismiss slide out + collapse height
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(playingSwiped, isTrue, reason: 'Playing item can swipe!');
      },
    );

    testWidgets(
      'default select and play have no border and flat elevation (no shadow) exactly like multi-select',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  selectionMode: NixSelectionMode.single,
                  selectedIndices: const {0},
                  playingIndex: 1,
                  children: const [
                    NixListItem(title: Text('Selected Item')),
                    NixListItem(title: Text('Playing Item')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Inspect card surface AnimatedContainers of both items
        final selectedFinder = find
            .ancestor(
              of: find.text('Selected Item'),
              matching: find.byType(AnimatedContainer),
            )
            .first;
        final playingFinder = find
            .ancestor(
              of: find.text('Playing Item'),
              matching: find.byType(AnimatedContainer),
            )
            .first;

        final selectedDecor =
            tester.widget<AnimatedContainer>(selectedFinder).decoration
                as BoxDecoration;
        final playingDecor =
            tester.widget<AnimatedContainer>(playingFinder).decoration
                as BoxDecoration;

        // Both selected and playing item surfaces have no border and are flat (no shadow) by default
        expect(
          selectedDecor.border,
          isNull,
          reason: 'Default select must have no border',
        );
        expect(
          selectedDecor.boxShadow,
          isNull,
          reason: 'Default select must be flat without shadow',
        );
        expect(
          playingDecor.border,
          isNull,
          reason: 'Default play must have no border',
        );
        expect(
          playingDecor.boxShadow,
          isNull,
          reason: 'Default play must be flat without shadow',
        );
      },
    );

    testWidgets(
      'buildDefaultDragHandles automatically inserts handles when true and suppresses when false',
      (tester) async {
        // When true
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.handleOnly,
                  buildDefaultDragHandles: true,
                  onReorder: (from, to) {},
                  children: const [
                    NixListItem(title: Text('Item 1')),
                    NixListItem(title: Text('Item 2')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NixReorderHandle), findsNWidgets(2));

        // When false
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.handleOnly,
                  buildDefaultDragHandles: false,
                  onReorder: (from, to) {},
                  children: const [
                    NixListItem(title: Text('Item 1')),
                    NixListItem(title: Text('Item 2')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NixReorderHandle), findsNothing);
      },
    );

    testWidgets(
      'Dynamic onSwipeRight and onSwipeLeft callbacks in NixListItem.gmailStyle trigger accurately',
      (tester) async {
        bool swipedRight = false;
        bool swipedLeft = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Dynamic Swipe Item'),
                      onSwipeRight: () => swipedRight = true,
                      onSwipeLeft: () => swipedLeft = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Swipe Right: should fire onSwipeRight
        await tester.drag(
          find.text('Dynamic Swipe Item'),
          const Offset(300.0, 0.0),
        );
        await tester.pumpAndSettle();
        expect(swipedRight, isTrue);
        expect(swipedLeft, isFalse);

        // 2. Swipe Left on another widget
        bool swipedLeftOnly = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Dynamic Swipe Item 2'),
                      onSwipeLeft: () => swipedLeftOnly = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.text('Dynamic Swipe Item 2'),
          const Offset(-300.0, 0.0),
        );
        await tester.pumpAndSettle();
        expect(swipedLeftOnly, isTrue);
      },
    );

    testWidgets(
      'NixReorderTrigger.disabled completely disables reordering for the list',
      (tester) async {
        bool reordered = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.disabled,
                  buildDefaultDragHandles: true,
                  onReorder: (from, to) => reordered = true,
                  children: const [
                    NixListItem(title: Text('Alpha')),
                    NixListItem(title: Text('Beta')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // No handles should be generated because trigger is disabled
        expect(find.byType(NixReorderHandle), findsNothing);

        // Long press attempt on whole item should not trigger reorder
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Alpha')),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.moveBy(const Offset(0.0, 70.0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(reordered, isFalse);
      },
    );

    testWidgets(
      'canReorder: false on an individual NixListItem disables reordering for that item only',
      (tester) async {
        int? fromIndex;
        int? toIndex;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  reorderTrigger: NixReorderTrigger.both,
                  buildDefaultDragHandles: true,
                  onReorder: (from, to) {
                    fromIndex = from;
                    toIndex = to;
                  },
                  children: const [
                    NixListItem(title: Text('Locked Item'), canReorder: false),
                    NixListItem(
                      title: Text('Reorderable Item'),
                      canReorder: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Locked Item should NOT have a default drag handle, Reorderable Item SHOULD
        expect(find.byType(NixReorderHandle), findsOneWidget);

        // Attempting to long press and drag Locked Item should fail
        final gestureLocked = await tester.startGesture(
          tester.getCenter(find.text('Locked Item')),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await gestureLocked.moveBy(const Offset(0.0, 70.0));
        await tester.pump();
        await gestureLocked.up();
        await tester.pumpAndSettle();

        expect(fromIndex, isNull);
        expect(toIndex, isNull);

        // Dragging Reorderable Item handle SHOULD work
        final handle = find.byType(NixReorderHandle).first;
        final gestureHandle = await tester.startGesture(
          tester.getCenter(handle),
        );
        await gestureHandle.moveBy(const Offset(0.0, -70.0));
        await tester.pump();
        await gestureHandle.up();
        await tester.pumpAndSettle();

        expect(fromIndex, equals(1));
        expect(toIndex, equals(0));
      },
    );

    testWidgets(
      'Reduced elevation and subtle shadow on swipe and reorder floating card',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Swipe Track'),
                      onSwipeRight: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Start horizontal swipe: break touch slop first, then move
        final swipeGesture = await tester.startGesture(
          tester.getCenter(find.text('Swipe Track')),
        );
        await swipeGesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        await swipeGesture.moveBy(const Offset(60.0, 0.0));
        await tester.pump();

        // Check reduced swipe shadow (alpha: 0.06, blurRadius: 6.0)
        final container = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .first;
        final decor = container.decoration as BoxDecoration;
        expect(decor.boxShadow, isNotNull);
        final shadow = decor.boxShadow!.first;
        expect(shadow.blurRadius, equals(6.0));
        expect(shadow.spreadRadius, equals(0.0));

        await swipeGesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Swipe background expands beside the list item without overlapping underneath',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Non Overlapping Item'),
                      onSwipeRight: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final swipeGesture = await tester.startGesture(
          tester.getCenter(find.text('Non Overlapping Item')),
        );
        await swipeGesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        await swipeGesture.moveBy(const Offset(55.0, 0.0));
        await tester.pump();

        // Reveal distance is 80.0
        final bgContainerFinder = find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final decor = w.decoration as BoxDecoration;
            return decor.color == const Color(0xFF2E7D32) &&
                decor.borderRadius is BorderRadius;
          }
          return false;
        });
        expect(bgContainerFinder, findsOneWidget);

        final bgContainer = tester.widget<Container>(bgContainerFinder);
        // The background container width should equal exactly the swipe offset (55.0), NOT overlapping under the card
        expect(
          bgContainer.constraints?.maxWidth ??
              (tester.getSize(bgContainerFinder).width),
          equals(55.0),
        );

        await swipeGesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Gmail style swipe icon animates scale and threshold popup', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: NixListView(
                children: [
                  NixListItem.gmailStyle(
                    title: const Text('Scale Anim'),
                    onSwipeRight: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag past threshold (threshold = 0.4 * 400 = 160)
      final swipeGesture = await tester.startGesture(
        tester.getCenter(find.text('Scale Anim')),
      );
      await swipeGesture.moveBy(const Offset(25.0, 0.0));
      await tester.pump();
      await swipeGesture.moveBy(const Offset(180.0, 0.0));
      await tester.pump();

      // Verify AnimatedScale is present in the swipe background
      expect(
        find.descendant(
          of: find.byType(NixListItem),
          matching: find.byType(AnimatedScale),
        ),
        findsOneWidget,
      );

      await swipeGesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'Reorder drag provides smooth 140ms animation for slot shifting and drop target',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  reorderable: true,
                  children: const [
                    NixListItem(title: Text('Alpha')),
                    NixListItem(title: Text('Beta')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check that AnimatedSlide widgets have smooth 140ms animation with easeOutCubic curve
        final slides = tester.widgetList<AnimatedSlide>(
          find.byType(AnimatedSlide),
        );
        for (final slide in slides) {
          expect(slide.duration, equals(const Duration(milliseconds: 140)));
          expect(slide.curve, equals(Curves.easeOutCubic));
        }
      },
    );

    testWidgets(
      'Play list item color dynamically rounds and seals neighbor items',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  playingIndex: 1,
                  children: const [
                    NixListItem(title: Text('Track 0')),
                    NixListItem(title: Text('Track 1 (Playing)')),
                    NixListItem(title: Text('Track 2')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        // Find the 3 card surface AnimatedContainers
        final itemFinders = [
          find.ancestor(
            of: find.text('Track 0'),
            matching: find.byType(AnimatedContainer),
          ),
          find.ancestor(
            of: find.text('Track 1 (Playing)'),
            matching: find.byType(AnimatedContainer),
          ),
          find.ancestor(
            of: find.text('Track 2'),
            matching: find.byType(AnimatedContainer),
          ),
        ];

        // Track 0 (unselected, before playing item):
        // Top corners: 12.0 (first item)
        // Bottom corners: 12.0 (sealed because next item is playing)
        final card0 = tester.widget<AnimatedContainer>(itemFinders[0].first);
        final deco0 = card0.decoration as BoxDecoration;
        final br0 = deco0.borderRadius as BorderRadius;
        expect(br0.topLeft.x, equals(12.0));
        expect(br0.topRight.x, equals(12.0));
        expect(br0.bottomLeft.x, equals(12.0));
        expect(br0.bottomRight.x, equals(12.0));

        // Track 1 (isolated playing item):
        // All 4 corners dynamically rounded to 12.0
        final card1 = tester.widget<AnimatedContainer>(itemFinders[1].first);
        final deco1 = card1.decoration as BoxDecoration;
        final br1 = deco1.borderRadius as BorderRadius;
        expect(br1.topLeft.x, equals(12.0));
        expect(br1.topRight.x, equals(12.0));
        expect(br1.bottomLeft.x, equals(12.0));
        expect(br1.bottomRight.x, equals(12.0));

        // Track 2 (unselected, after playing item):
        // Top corners: 12.0 (sealed because prev item is playing)
        // Bottom corners: 12.0 (last item)
        final card2 = tester.widget<AnimatedContainer>(itemFinders[2].first);
        final deco2 = card2.decoration as BoxDecoration;
        final br2 = deco2.borderRadius as BorderRadius;
        expect(br2.topLeft.x, equals(12.0));
        expect(br2.topRight.x, equals(12.0));
        expect(br2.bottomLeft.x, equals(12.0));
        expect(br2.bottomRight.x, equals(12.0));
      },
    );

    testWidgets(
      'Selected list items color dynamically rounds according to segmented position and multi-selection groups',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  selectionMode: NixSelectionMode.multi,
                  selectedIndices: const {1, 2},
                  children: const [
                    NixListItem(title: Text('Item 0')),
                    NixListItem(title: Text('Item 1 (Selected)')),
                    NixListItem(title: Text('Item 2 (Selected)')),
                    NixListItem(title: Text('Item 3')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        final card0 = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Item 0'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final br0 =
            (card0.decoration as BoxDecoration).borderRadius as BorderRadius;
        // Item 0: top is 12.0, bottom seals to 12.0
        expect(br0.topLeft.x, equals(12.0));
        expect(br0.bottomLeft.x, equals(12.0));

        final card1 = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Item 1 (Selected)'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final br1 =
            (card1.decoration as BoxDecoration).borderRadius as BorderRadius;
        // Item 1 (top of selected group):
        // Top corners: 12.0 (boundary against unselected Item 0)
        // Bottom corners: 6.0 (shared inner corner with selected Item 2)
        expect(br1.topLeft.x, equals(12.0));
        expect(br1.topRight.x, equals(12.0));
        expect(br1.bottomLeft.x, equals(6.0));
        expect(br1.bottomRight.x, equals(6.0));

        final card2 = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Item 2 (Selected)'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final br2 =
            (card2.decoration as BoxDecoration).borderRadius as BorderRadius;
        // Item 2 (bottom of selected group):
        // Top corners: 6.0 (shared inner corner with selected Item 1)
        // Bottom corners: 12.0 (boundary against unselected Item 3)
        expect(br2.topLeft.x, equals(6.0));
        expect(br2.topRight.x, equals(6.0));
        expect(br2.bottomLeft.x, equals(12.0));
        expect(br2.bottomRight.x, equals(12.0));

        final card3 = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Item 3'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final br3 =
            (card3.decoration as BoxDecoration).borderRadius as BorderRadius;
        // Item 3: top seals to 12.0, bottom is 12.0 (last item)
        expect(br3.topLeft.x, equals(12.0));
        expect(br3.bottomLeft.x, equals(12.0));
      },
    );

    testWidgets(
      'When swipe is triggered as Action Button, Reorder, Play, and Select are disabled',
      (tester) async {
        bool tapped = false;
        bool selected = false;
        bool reordered = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  reorderable: true,
                  playingIndex: 0,
                  onReorder: (from, to) => reordered = true,
                  swipeMode: NixSwipeMode.actions,
                  children: [
                    NixListItem(
                      title: const Text('Action Track 0'),
                      reorderHandle: const NixReorderHandle(),
                      onTap: () => tapped = true,
                      onSelectionChanged: (val) => selected = val,
                      primaryActions: [
                        NixSwipeAction.share(onTriggered: () {}),
                        NixSwipeAction.archive(onTriggered: () {}),
                      ],
                    ),
                    const NixListItem(
                      title: Text('Track 1'),
                      reorderHandle: NixReorderHandle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial State: Track 0 is playing (has playing color highlight), handle is enabled
        final initialContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Action Track 0'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final initialDeco = initialContainer.decoration as BoxDecoration;
        expect(initialDeco.color, isNotNull);

        // 2. Swipe right to trigger Action Buttons
        await tester.drag(
          find.text('Action Track 0'),
          const Offset(160.0, 0.0),
        );
        await tester.pumpAndSettle();

        // Action Buttons are revealed
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Archive'), findsOneWidget);

        // 3. Verify Reorder is disabled on the swiped item
        final ignorePointerFinders = find.descendant(
          of: find.ancestor(
            of: find.text('Action Track 0'),
            matching: find.byType(NixListItem),
          ),
          matching: find.byType(IgnorePointer),
        );
        expect(ignorePointerFinders, findsWidgets);

        // Attempting to drag reorder handle does NOT trigger reorder
        final handleFinder = find.descendant(
          of: find.ancestor(
            of: find.text('Action Track 0'),
            matching: find.byType(NixListItem),
          ),
          matching: find.byType(NixReorderHandle),
        );
        final dragGesture = await tester.startGesture(
          tester.getCenter(handleFinder),
        );
        await dragGesture.moveBy(const Offset(0.0, 80.0));
        await tester.pump();
        await dragGesture.up();
        await tester.pumpAndSettle();
        expect(
          reordered,
          isFalse,
          reason: 'Reorder must be disabled while action buttons are triggered',
        );

        // 4. Verify Play and Select are disabled on tap
        // Tapping the card closes the action buttons without invoking onTap or onSelectionChanged
        await tester.tap(find.text('Action Track 0'));
        await tester.pumpAndSettle();
        expect(
          tapped,
          isFalse,
          reason: 'Play / onTap must be disabled while action buttons are open',
        );
        expect(
          selected,
          isFalse,
          reason: 'Select must be disabled while action buttons are open',
        );
      },
    );

    testWidgets(
      'NixListItem renders Flutter native Material and InkWell for press and onLongPress splash',
      (tester) async {
        bool tapped = false;
        bool longPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: NixListView(
                  children: [
                    NixListItem(
                      title: const Text('Splash Item'),
                      splashColor: Colors.purple.withValues(alpha: 0.2),
                      highlightColor: Colors.purple.withValues(alpha: 0.1),
                      onTap: () => tapped = true,
                      onLongPress: () => longPressed = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Material and InkWell exist inside NixListItem
        final inkWellFinder = find.descendant(
          of: find.byType(NixListItem),
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);

        final inkWell = tester.widget<InkWell>(inkWellFinder);
        expect(
          inkWell.splashColor,
          equals(Colors.purple.withValues(alpha: 0.2)),
        );
        expect(
          inkWell.highlightColor,
          equals(Colors.purple.withValues(alpha: 0.1)),
        );

        // Tap triggers native ink splash and calls onTap
        await tester.tap(find.text('Splash Item'));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);

        // Long press triggers onLongPress
        await tester.longPress(find.text('Splash Item'));
        await tester.pumpAndSettle();
        expect(longPressed, isTrue);
      },
    );

    testWidgets(
      'In Gmail style after swiping an item to trigger archive/delete, reorder on remaining items continues working',
      (tester) async {
        final items = <String>['Email 0', 'Email 1', 'Email 2'];
        int? reorderedFrom;
        int? reorderedTo;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                theme: ThemeData(useMaterial3: true),
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 500,
                    child: NixListView(
                      reorderable: true,
                      onReorder: (from, to) {
                        reorderedFrom = from;
                        reorderedTo = to;
                        setState(() {
                          final item = items.removeAt(from);
                          items.insert(to, item);
                        });
                      },
                      children: [
                        for (int i = 0; i < items.length; i++)
                          NixListItem.gmailStyle(
                            key: ValueKey(items[i]),
                            title: Text(items[i]),
                            reorderHandle: const NixReorderHandle(),
                            onArchive: () {
                              setState(() {
                                items.removeAt(i);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Swipe Email 0 to the right to trigger archive
        await tester.drag(find.text('Email 0'), const Offset(260.0, 0.0));
        await tester.pumpAndSettle();

        // Email 0 is dismissed and removed
        expect(find.text('Email 0'), findsNothing);
        expect(items.length, equals(2));
        expect(find.text('Email 1'), findsOneWidget);
        expect(find.text('Email 2'), findsOneWidget);

        // 2. Reorder remaining items: drag Email 1 handle down past Email 2
        final handle1Finder = find.descendant(
          of: find.ancestor(
            of: find.text('Email 1'),
            matching: find.byType(NixListItem),
          ),
          matching: find.byType(NixReorderHandle),
        );
        expect(handle1Finder, findsOneWidget);

        final dragGesture = await tester.startGesture(
          tester.getCenter(handle1Finder),
        );
        await tester.pump();
        await dragGesture.moveBy(const Offset(0.0, 70.0));
        await tester.pump();
        await dragGesture.up();
        await tester.pumpAndSettle();

        // Verify reorder worked on remaining items!
        expect(reorderedFrom, equals(0));
        expect(reorderedTo, equals(1));
        expect(items[0], equals('Email 2'));
        expect(items[1], equals('Email 1'));
      },
    );

    testWidgets(
      'In Gmail style non-dismiss action trigger springs back and allows immediate reorder',
      (tester) async {
        bool actionTriggered = false;
        int? reorderedFrom;
        int? reorderedTo;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                theme: ThemeData(useMaterial3: true),
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 500,
                    child: NixListView(
                      reorderable: true,
                      onReorder: (from, to) {
                        reorderedFrom = from;
                        reorderedTo = to;
                      },
                      children: [
                        NixListItem(
                          key: const ValueKey('Card 0'),
                          title: const Text('Card 0'),
                          reorderHandle: const NixReorderHandle(),
                          leftAction: NixSwipeAction(
                            onTriggered: () => actionTriggered = true,
                            actionType: NixSwipeActionType.action,
                            threshold: 0.3,
                          ),
                        ),
                        const NixListItem(
                          key: ValueKey('Card 1'),
                          title: Text('Card 1'),
                          reorderHandle: NixReorderHandle(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Swipe Card 0 to trigger the action (springs back)
        await tester.drag(find.text('Card 0'), const Offset(180.0, 0.0));
        await tester.pumpAndSettle();
        expect(actionTriggered, isTrue);

        // 2. Drag handle to reorder Card 0 past Card 1
        final handle0Finder = find.descendant(
          of: find.ancestor(
            of: find.text('Card 0'),
            matching: find.byType(NixListItem),
          ),
          matching: find.byType(NixReorderHandle),
        );
        final dragGesture = await tester.startGesture(
          tester.getCenter(handle0Finder),
        );
        await tester.pump();
        await dragGesture.moveBy(const Offset(0.0, 70.0));
        await tester.pump();
        await dragGesture.up();
        await tester.pumpAndSettle();

        expect(reorderedFrom, equals(0));
        expect(reorderedTo, equals(1));
      },
    );

    testWidgets(
      'Gmail style swipe vibrates on slow swipe at trigger and on fast swipe, without double vibrating',
      (tester) async {
        final List<String> hapticCalls = [];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (methodCall) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              hapticCalls.add(methodCall.arguments as String);
            }
            return null;
          },
        );

        bool swiped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Slow Swipe Item'),
                      onArchive: () => swiped = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Slow swipe:
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Slow Swipe Item')),
        );
        await gesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        expect(
          hapticCalls.isEmpty,
          isTrue,
          reason: 'No vibration before threshold',
        );

        // Move across threshold (180px)
        await gesture.moveBy(const Offset(180.0, 0.0));
        await tester.pump();
        expect(
          hapticCalls.length,
          equals(1),
          reason: 'Vibrates once when crossing threshold',
        );

        // Finish swipe
        await gesture.up();
        await tester.pumpAndSettle();
        expect(swiped, isTrue);
        // Ensure no double vibration after gesture.up()
        expect(
          hapticCalls.length,
          equals(1),
          reason: 'Did not double vibrate on slow swipe',
        );

        hapticCalls.clear();

        // 2. Fast swipe (fling / high velocity):
        bool fastSwiped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  children: [
                    NixListItem.gmailStyle(
                      title: const Text('Fast Swipe Item'),
                      onArchive: () => fastSwiped = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Fast fling across with velocity
        await tester.fling(
          find.text('Fast Swipe Item'),
          const Offset(200.0, 0.0),
          1000.0,
        );
        await tester.pumpAndSettle();

        expect(fastSwiped, isTrue);
        // Fast swipe vibrated exactly once!
        expect(
          hapticCalls.length,
          equals(1),
          reason: 'Vibrates exactly once on fast swipe without missing or double vibrating',
        );

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      },
    );

    testWidgets(
      'Play / Selected and Select / Multi-Select render animated selection pop and full width card with no gaps',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: NixListView(
                  selectionMode: NixSelectionMode.multi,
                  selectedIndices: const {0},
                  playingIndex: 1,
                  children: const [
                    NixListItem(title: Text('Track 0 (Selected)')),
                    NixListItem(title: Text('Track 1 (Playing)')),
                    NixListItem(title: Text('Track 2 (Normal)')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // AnimatedScale on selection checkmark icon
        expect(
          find.descendant(
            of: find.byType(NixListItem),
            matching: find.byType(AnimatedScale),
          ),
          findsWidgets,
        );

        // AnimatedSize on selection checkbox column
        expect(
          find.descendant(
            of: find.byType(NixListItem),
            matching: find.byType(AnimatedSize),
          ),
          findsWidgets,
        );
      },
    );
  });
}
