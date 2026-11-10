import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  group('NixWaveSlider - Core Rendering & Defaults', () {
    testWidgets('Renders wave slider with default properties and active squiggly wave', (tester) async {
      double value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: NixWaveSlider(
                  value: value,
                  onChanged: (val) => value = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NixWaveSlider), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final slider = tester.widget<NixWaveSlider>(find.byType(NixWaveSlider));
      expect(slider.thumbWidth, greaterThan(0));
      expect(slider.thumbHeight, greaterThan(0));
      expect(slider.trackHeight, equals(3.0));
      expect(slider.waveAmplitude, equals(4.0));
      expect(slider.waveOrigin, equals(NixWaveOrigin.activePoint));
    });

    testWidgets('Supports waveOrigin activePoint and startPoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NixWaveSlider(
                  value: 0.5,
                  waveOrigin: NixWaveOrigin.activePoint,
                  onChanged: (_) {},
                ),
                NixWaveSlider(
                  value: 0.5,
                  waveOrigin: NixWaveOrigin.startPoint,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliders = tester.widgetList<NixWaveSlider>(find.byType(NixWaveSlider)).toList();
      expect(sliders[0].waveOrigin, equals(NixWaveOrigin.activePoint));
      expect(sliders[1].waveOrigin, equals(NixWaveOrigin.startPoint));
    });

    testWidgets('Tapping on track updates value smoothly', (tester) async {
      double value = 0.2;
      double? startedVal;
      double? endedVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  value: value,
                  onChangeStart: (val) => startedVal = val,
                  onChanged: (val) => value = val,
                  onChangeEnd: (val) => endedVal = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap near the 75% mark (x = 150 of 200)
      final sliderFinder = find.byType(NixWaveSlider);
      final topLeft = tester.getTopLeft(sliderFinder);
      await tester.tapAt(Offset(topLeft.dx + 150, topLeft.dy + 24));
      await tester.pumpAndSettle();

      expect(startedVal, isNotNull);
      expect(value, greaterThan(0.65));
      expect(value, lessThan(0.85));
      expect(endedVal, equals(value));
    });

    testWidgets('Dragging along track produces smooth continuous values', (tester) async {
      double value = 0.0;
      final valuesRecorded = <double>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  value: value,
                  onChanged: (val) {
                    value = val;
                    valuesRecorded.add(val);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(NixWaveSlider);
      final center = tester.getCenter(sliderFinder);

      // Drag from center to right
      await tester.dragFrom(center, const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(valuesRecorded.isNotEmpty, isTrue);
      expect(value, greaterThan(0.5));
    });

    testWidgets('Respects boundaries at min and max (0.0 to 1.0)', (tester) async {
      double value = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  value: value,
                  onChanged: (val) => value = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag far to the left past 0
      final sliderFinder = find.byType(NixWaveSlider);
      final center = tester.getCenter(sliderFinder);
      await tester.dragFrom(center, const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(value, equals(0.0));

      // Drag far to the right past 1.0
      await tester.dragFrom(center, const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(value, equals(1.0));
    });

    testWidgets('Disabled slider rejects gestures', (tester) async {
      double value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  enabled: false,
                  value: value,
                  onChanged: (val) => value = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(NixWaveSlider);
      final center = tester.getCenter(sliderFinder);
      await tester.dragFrom(center, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(value, equals(0.5));
    });

    testWidgets('Native keyboard navigation controls slider (ArrowRight, ArrowLeft, Home, End)', (tester) async {
      double value = 0.5;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return NixWaveSlider(
                      value: value,
                      focusNode: focusNode,
                      autofocus: true,
                      divisions: 10,
                      onChanged: (val) => setState(() => value = val),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure focused
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Send ArrowRight
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, equals(0.6));

      // Send ArrowLeft
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(value, equals(0.5));

      // Send End
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(value, equals(1.0));

      // Send Home
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(value, equals(0.0));
    });

    testWidgets('Hover changes cursor to click cursor when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  value: 0.5,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mouseRegionFinder = find.descendant(
        of: find.byType(NixWaveSlider),
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsWidgets);

      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder.first);
      expect(mouseRegion.cursor, equals(SystemMouseCursors.click));
    });

    testWidgets('Has no thumb border by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider(
                  value: 0.5,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final slider = tester.widget<NixWaveSlider>(find.byType(NixWaveSlider));
      expect(slider.thumbBorderColor, isNull);
    });

    testWidgets('Song end (value >= max) flattens wave and settles immediately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NixWaveSlider.music(
                  value: 100.0,
                  max: 100.0, // song ended
                  isPlaying: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NixWaveSlider), findsOneWidget);
    });
  });

  group('NixWaveSlider.music - Music Timestamps & Scrubber', () {
    testWidgets('Displays elapsed and total duration timestamps', (tester) async {
      double currentPos = 84.0; // 1:24
      const double totalDuration = 225.0; // 3:45

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: NixWaveSlider.music(
                  value: currentPos,
                  max: totalDuration,
                  onChanged: (val) => currentPos = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1:24'), findsOneWidget);
      expect(find.text('3:45'), findsOneWidget);
    });

    testWidgets('Semantics provides accessible slider information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: NixWaveSlider.music(
                  value: 65.0,
                  max: 180.0,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.slider == true,
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });
}

