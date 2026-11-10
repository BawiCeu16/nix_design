import 'dart:math' as math;
import 'dart:ui' show FontFeature, lerpDouble;

import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/nix_theme_data.dart';

/// The anchor origin from which the squiggly wave radiates and flows.
enum NixWaveOrigin {
  /// The wave originates and is anchored at the active point (thumb scrubber),
  /// radiating backwards toward the start point.
  activePoint,

  /// The wave originates and is anchored at the start point (left end),
  /// radiating forward toward the active point.
  startPoint,
}

/// A signature squiggly wave slider designed for music playback and scrub bars.
///
/// Features:
/// - **Squiggly Wave Only on Active**: The active track (played audio) renders as a
///   sinusoidal squiggly wave with a smooth cosine taper envelope, while the inactive
///   track is a straight, clean line.
/// - **Fixed Wave Coordinates**: The wave crests and troughs are anchored to fixed
///   track coordinates along the spatial horizontal axis, so seeking or advancing
///   smoothly uncovers/covers the wave rather than sliding it across the screen.
/// - **Pause & Song End Animation**: When playback is paused or when the song reaches
///   the end (`value >= max`), the squiggly wave smoothly flattens out into a straight
///   line by animation.
/// - **Scrubber Thumb**: Features a clean pill scrubber thumb (`height: 20.0px`,
///   `width: 5.0px` by default) with no elevation or shadows, no border outline,
///   and transparent splash/indicator. On press and hold, the width smoothly animates
///   `+1.0px` wider while the height smoothly compresses `-1.0px`.
/// - **Native Flutter Capabilities**: Supports full mouse hover cursor, mouse wheel
///   scrubbing, keyboard control (Arrow Left/Right/Up/Down, PageUp/Down, Home/End),
///   focus states, and accessible slider semantics.
class NixWaveSlider extends StatefulWidget {
  /// Creates a standard [NixWaveSlider].
  const NixWaveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.isPlaying = false,
    this.animateWave = true,
    this.waveSpeed = const Duration(milliseconds: 1000),
    this.waveAmplitude = 4.0,
    this.wavelength = 28.0,
    this.waveOrigin = NixWaveOrigin.activePoint,
    this.trackHeight = 3.0,
    this.inactiveTrackHeight,
    this.thumbWidth = 4.0,
    this.thumbHeight = 18.0,
    this.thumbRadius,
    this.thumbBorderColor,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.height = 48.0,
    this.padding = EdgeInsets.zero,
    this.enabled = true,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(max > min, 'max must be strictly greater than min'),
       assert(
         value >= min && value <= max,
         'value must be between min and max',
       ),
       showTimestamps = false,
       timestampStyle = null,
       formatDuration = null;

  /// Creates a [NixWaveSlider] tailored for music playback, including integrated
  /// elapsed and remaining/total duration timestamps.
  const NixWaveSlider.music({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    required this.max,
    this.divisions,
    this.isPlaying = false,
    this.animateWave = true,
    this.waveSpeed = const Duration(milliseconds: 1200),
    this.waveAmplitude = 4.0,
    this.wavelength = 24.0,
    this.waveOrigin = NixWaveOrigin.activePoint,
    this.trackHeight = 3.0,
    this.inactiveTrackHeight,
    this.thumbWidth = 4.0,
    this.thumbHeight = 18.0,
    this.thumbRadius,
    this.thumbBorderColor,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.height = 38.0,
    this.padding = EdgeInsets.zero,
    this.enabled = true,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.showTimestamps = true,
    this.timestampStyle,
    this.formatDuration,
  }) : assert(max > min, 'max must be strictly greater than min'),
       assert(
         value >= min && value <= max,
         'value must be between min and max',
       );

  /// The currently selected value on this slider.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts selecting a new value for the slider.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value the user can select. Defaults to `0.0`.
  final double min;

  /// The maximum value the user can select. Defaults to `1.0`.
  final double max;

  /// The number of discrete divisions. If null, the slider is continuous.
  final int? divisions;

  /// Whether the music/audio is currently playing.
  ///
  /// When `true` and [animateWave] is `true`, the squiggly wave undulates forward in real time.
  /// When `false` or when [value] reaches [max], the wave flattens into a straight line.
  final bool isPlaying;

  /// Whether to animate the squiggly wave when audio is playing. Defaults to `true`.
  final bool animateWave;

  /// The duration of one complete wave cycle animation. Defaults to `1200ms`.
  final Duration waveSpeed;

  /// The peak amplitude (crest height from centerline) of the squiggly wave in logical pixels.
  /// Defaults to `4.0px`.
  final double waveAmplitude;

  /// The horizontal wavelength of one complete wave cycle in logical pixels. Defaults to `28.0px`.
  final double wavelength;

  /// The anchor origin from which the squiggly wave radiates. Defaults to [NixWaveOrigin.activePoint].
  final NixWaveOrigin waveOrigin;

  /// The stroke thickness of the active squiggly wave track. Defaults to `3.0px`.
  final double trackHeight;

  /// The stroke thickness of the inactive straight track line.
  /// If null, defaults to [trackHeight].
  final double? inactiveTrackHeight;

  /// The width of the scrubber thumb at rest. Defaults to `5.0px`.
  final double thumbWidth;

  /// The height of the scrubber thumb at rest. Defaults to `20.0px`.
  final double thumbHeight;

  /// The border radius of the scrubber thumb. Defaults to full pill curvature.
  final BorderRadius? thumbRadius;

  /// Optional border color for the thumb. Defaults to null (no border).
  final Color? thumbBorderColor;

  /// The color of the active squiggly wave track.
  /// Defaults to [NixThemeData.primary] or [ColorScheme.primary].
  final Color? activeColor;

  /// The color of the inactive straight track.
  /// Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? inactiveColor;

  /// The color of the scrubber thumb.
  /// Defaults to [activeColor].
  final Color? thumbColor;

  /// The height of the interactive touch target. Defaults to `48.0px`.
  final double height;

  /// Additional padding around the slider.
  final EdgeInsetsGeometry padding;

  /// Whether the slider is interactive. Defaults to `true`.
  final bool enabled;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// An optional focus node to use for keyboard interactions.
  final FocusNode? focusNode;

  /// Whether this slider should automatically focus itself. Defaults to `false`.
  final bool autofocus;

  /// Whether to display elapsed and remaining/total duration timestamps below the slider.
  final bool showTimestamps;

  /// Optional text style for duration timestamps.
  final TextStyle? timestampStyle;

  /// Custom duration formatting callback.
  /// If null, formats as `m:ss` (e.g. `1:24`, `3:45`).
  final String Function(Duration duration)? formatDuration;

  @override
  State<NixWaveSlider> createState() => _NixWaveSliderState();
}

/// Type alias for [NixWaveSlider].
typedef NixSquigglySlider = NixWaveSlider;

class _NixWaveSliderState extends State<NixWaveSlider>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _amplitudeController;
  late final AnimationController _scrubController;
  late final AnimationController _seekController;

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  double? _dragValue;
  double? _animatedSeekValue;
  bool _isDragging = false;

  bool get _isSongEnded => widget.value >= widget.max;
  bool get _shouldBeWavy => widget.isPlaying && !_isSongEnded;

  @override
  void initState() {
    super.initState();
    // 1. Continuous wave phase animation
    _waveController = AnimationController(
      vsync: this,
      duration: widget.waveSpeed,
    );
    if (_shouldBeWavy && widget.animateWave) {
      _waveController.repeat();
    }

    // 2. Wave amplitude transition (flattens during drag/pause/end, springs on play)
    _amplitudeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: _shouldBeWavy ? 1.0 : 0.0,
    );

    // 3. Thumb width expansion controller (+1px on press/hold)
    _scrubController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      value: 0.0,
    );

    // 4. Tap-to-seek smooth animation controller
    _seekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void didUpdateWidget(covariant NixWaveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.waveSpeed != oldWidget.waveSpeed) {
      _waveController.duration = widget.waveSpeed;
    }

    final wavy = _shouldBeWavy;
    if (wavy) {
      if (widget.animateWave && !_waveController.isAnimating) {
        _waveController.repeat();
      }
      if (!_isDragging) {
        _amplitudeController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    } else {
      // On pause or song end, the squiggly wave is done too (flattens into straight line)
      _amplitudeController
          .animateTo(
            0.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (!_shouldBeWavy && _waveController.isAnimating) {
              _waveController.stop();
            }
          });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _amplitudeController.dispose();
    _scrubController.dispose();
    _seekController.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  double get _currentValue {
    if (_isDragging) return _dragValue ?? widget.value;
    if (_seekController.isAnimating && _animatedSeekValue != null) {
      return _animatedSeekValue!;
    }
    return widget.value;
  }

  double _clampAndDiscretize(double rawValue) {
    var val = rawValue.clamp(widget.min, widget.max);
    if (widget.divisions != null && widget.divisions! > 0) {
      final range = widget.max - widget.min;
      final step = range / widget.divisions!;
      val = widget.min + ((val - widget.min) / step).round() * step;
      val = double.parse(val.toStringAsFixed(6));
    }
    return val;
  }

  double _valueFromPosition(Offset localPosition, double totalWidth) {
    final padding = math.max(widget.thumbWidth / 2.0, widget.trackHeight / 2.0);
    final usableWidth = totalWidth - 2 * padding;
    if (usableWidth <= 0) return widget.min;

    final t = ((localPosition.dx - padding) / usableWidth).clamp(0.0, 1.0);
    return _clampAndDiscretize(widget.min + t * (widget.max - widget.min));
  }

  void _stepValue(double delta) {
    final nextVal = _clampAndDiscretize(_currentValue + delta);
    if (nextVal != _currentValue) {
      HapticFeedback.selectionClick();
      widget.onChangeStart?.call(_currentValue);
      widget.onChanged?.call(nextVal);
      widget.onChangeEnd?.call(nextVal);
    }
  }

  double get _keyboardStep {
    if (widget.divisions != null && widget.divisions! > 0) {
      return (widget.max - widget.min) / widget.divisions!;
    }
    final range = widget.max - widget.min;
    return math.max(range * 0.01, 1.0); // 1% or 1 second step
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final step = _keyboardStep;
    final range = widget.max - widget.min;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _stepValue(-step);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _stepValue(step);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _stepValue(-range * 0.10);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _stepValue(range * 0.10);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _stepValue(widget.min - _currentValue);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _stepValue(widget.max - _currentValue);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent &&
        widget.enabled &&
        widget.onChanged != null) {
      final delta = event.scrollDelta.dy > 0 ? -_keyboardStep : _keyboardStep;
      _stepValue(delta);
    }
  }

  void _handleTapDown(Offset localPosition, double totalWidth) {
    if (!widget.enabled || widget.onChanged == null) return;
    _effectiveFocusNode.requestFocus();
    _scrubController.forward();

    final targetValue = _valueFromPosition(localPosition, totalWidth);
    final startValue = _currentValue;

    // Smooth tap-to-seek animation
    _seekController.stop();
    _animatedSeekValue = startValue;

    final seekTween = Tween<double>(begin: startValue, end: targetValue);
    final curved = CurvedAnimation(
      parent: _seekController,
      curve: Curves.easeOutCubic,
    );

    void onTick() {
      setState(() {
        _animatedSeekValue = seekTween.evaluate(curved);
      });
      widget.onChanged?.call(_animatedSeekValue!);
    }

    _seekController.addListener(onTick);

    HapticFeedback.selectionClick();
    widget.onChangeStart?.call(startValue);

    _seekController.forward(from: 0.0).whenComplete(() {
      _seekController.removeListener(onTick);
      _animatedSeekValue = null;
      widget.onChangeEnd?.call(targetValue);
      if (!_isDragging) {
        _scrubController.reverse();
      }
    });
  }

  void _handleDragStart(Offset localPosition, double totalWidth) {
    if (!widget.enabled || widget.onChanged == null) return;
    _effectiveFocusNode.requestFocus();
    _isDragging = true;
    _seekController.stop();
    _animatedSeekValue = null;

    final nextValue = _valueFromPosition(localPosition, totalWidth);
    setState(() => _dragValue = nextValue);

    // Tactile width expansion (+1px) & wave flatten
    _scrubController.forward();
    _amplitudeController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
    );

    HapticFeedback.selectionClick();
    widget.onChangeStart?.call(nextValue);
    widget.onChanged?.call(nextValue);
  }

  void _handleDragUpdate(Offset localPosition, double totalWidth) {
    if (!widget.enabled || widget.onChanged == null || !_isDragging) return;
    final nextValue = _valueFromPosition(localPosition, totalWidth);

    if (_dragValue != nextValue) {
      setState(() => _dragValue = nextValue);
      widget.onChanged?.call(nextValue);
    }
  }

  void _handleDragEnd() {
    if (!_isDragging) return;
    _isDragging = false;
    final endVal = _currentValue;

    // Tactile width collapse & wave spring back if playing and not at end
    _scrubController.reverse();
    if (widget.isPlaying && endVal < widget.max) {
      _amplitudeController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _amplitudeController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    }

    setState(() => _dragValue = null);
    widget.onChangeEnd?.call(endVal);
  }

  String _formatTimestamp(double seconds) {
    final dur = Duration(milliseconds: (seconds * 1000).round());
    if (widget.formatDuration != null) {
      return widget.formatDuration!(dur);
    }
    final mins = dur.inMinutes;
    final secs = dur.inSeconds.remainder(60);
    final secsStr = secs < 10 ? '0$secs' : '$secs';
    return '$mins:$secsStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nixTheme = NixThemeData.of(context);
    final colors = theme.colorScheme;

    final effectiveActiveColor = widget.enabled
        ? (widget.activeColor ?? nixTheme.primary ?? colors.primary)
        : (widget.activeColor ?? nixTheme.primary ?? colors.primary).withValues(
            alpha: 0.38,
          );

    final effectiveInactiveColor = widget.enabled
        ? (widget.inactiveColor ?? colors.surfaceContainerHighest)
        : (widget.inactiveColor ?? colors.surfaceContainerHighest).withValues(
            alpha: 0.24,
          );

    final effectiveThumbColor = widget.enabled
        ? (widget.thumbColor ?? effectiveActiveColor)
        : effectiveActiveColor;

    // By default, no border outline is rendered for the thumb
    final effectiveThumbBorderColor = widget.thumbBorderColor;

    Widget slider = LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) =>
              _handleDragStart(details.localPosition, totalWidth),
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details.localPosition, totalWidth),
          onHorizontalDragEnd: (_) => _handleDragEnd(),
          onHorizontalDragCancel: () => _handleDragEnd(),
          onTapDown: (details) =>
              _handleTapDown(details.localPosition, totalWidth),
          onTapUp: (_) {
            if (!_isDragging) {
              _scrubController.reverse();
            }
          },
          onTapCancel: () {
            if (!_isDragging) {
              _scrubController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _waveController,
              _amplitudeController,
              _scrubController,
              _seekController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(totalWidth, widget.height),
                painter: _SquigglyWavePainter(
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  phase: _waveController.value,
                  waveAmplitude:
                      widget.waveAmplitude * _amplitudeController.value,
                  wavelength: widget.wavelength,
                  waveOrigin: widget.waveOrigin,
                  trackHeight: widget.trackHeight,
                  inactiveTrackHeight:
                      widget.inactiveTrackHeight ?? widget.trackHeight,
                  thumbWidth: widget.thumbWidth,
                  thumbHeight: widget.thumbHeight,
                  scrubProgress: _scrubController.value,
                  thumbRadius: widget.thumbRadius,
                  activeColor: effectiveActiveColor,
                  inactiveColor: effectiveInactiveColor,
                  thumbColor: effectiveThumbColor,
                  thumbBorderColor: effectiveThumbBorderColor,
                ),
              );
            },
          ),
        );
      },
    );

    if (widget.showTimestamps) {
      final style =
          widget.timestampStyle ??
          (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11))
              .copyWith(
                color: widget.enabled
                    ? colors.onSurfaceVariant
                    : colors.onSurfaceVariant.withValues(alpha: 0.38),
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              );

      slider = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          slider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTimestamp(_currentValue), style: style),
                Text(_formatTimestamp(widget.max), style: style),
              ],
            ),
          ),
        ],
      );
    }

    final step = _keyboardStep;
    Widget result = Semantics(
      slider: true,
      enabled: widget.enabled,
      label: widget.semanticLabel ?? 'Music playback scrubber',
      value: _formatTimestamp(_currentValue),
      increasedValue: _formatTimestamp(
        _clampAndDiscretize(_currentValue + step),
      ),
      decreasedValue: _formatTimestamp(
        _clampAndDiscretize(_currentValue - step),
      ),
      onIncrease: widget.enabled && widget.onChanged != null
          ? () => _stepValue(step)
          : null,
      onDecrease: widget.enabled && widget.onChanged != null
          ? () => _stepValue(-step)
          : null,
      child: slider,
    );

    return Padding(
      padding: widget.padding,
      child: Focus(
        focusNode: _effectiveFocusNode,
        autofocus: widget.autofocus,
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Listener(onPointerSignal: _handlePointerSignal, child: result),
        ),
      ),
    );
  }
}

class _SquigglyWavePainter extends CustomPainter {
  const _SquigglyWavePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.phase,
    required this.waveAmplitude,
    required this.wavelength,
    required this.waveOrigin,
    required this.trackHeight,
    required this.inactiveTrackHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.scrubProgress,
    required this.thumbRadius,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.thumbBorderColor,
  });

  final double value;
  final double min;
  final double max;
  final double phase;
  final double waveAmplitude;
  final double wavelength;
  final NixWaveOrigin waveOrigin;
  final double trackHeight;
  final double inactiveTrackHeight;
  final double thumbWidth;
  final double thumbHeight;
  final double scrubProgress;
  final BorderRadius? thumbRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Color? thumbBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2.0;

    // Margins ensuring rounded caps and thumb do not bleed outside bounds
    final halfThumb = (thumbWidth + 1.0) / 2.0;
    final halfTrack = math.max(trackHeight, inactiveTrackHeight) / 2.0;
    final padding = math.max(halfThumb, halfTrack);

    final usableWidth = size.width - 2 * padding;
    if (usableWidth <= 0) return;

    final t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final thumbX = padding + t * usableWidth;

    // 1. Inactive Track (Straight line with rounded end cap from thumbX to end)
    if (thumbX < size.width - padding) {
      final inactivePaint = Paint()
        ..color = inactiveColor
        ..strokeWidth = inactiveTrackHeight
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(thumbX, centerY),
        Offset(size.width - padding, centerY),
        inactivePaint,
      );
    }

    // 2. Active Track (Squiggly wave on active portion from start to thumbX)
    final activeLength = thumbX - padding;
    if (activeLength > 0.5) {
      final activePaint = Paint()
        ..color = activeColor
        ..strokeWidth = trackHeight
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(padding, centerY);

      final omega = 2 * math.pi / wavelength;
      final phi = phase * 2 * math.pi;

      // Smooth cosine taper envelope at start and end
      final transitionLength = math.min(16.0, activeLength / 2.0);

      const step = 1.2;
      for (double x = padding + step; x < thumbX; x += step) {
        final u = x - padding;
        final v = thumbX - x;

        final double fIn = u < transitionLength
            ? 0.5 * (1.0 - math.cos(math.pi * u / transitionLength))
            : 1.0;

        final double fOut = v < transitionLength
            ? 0.5 * (1.0 - math.cos(math.pi * v / transitionLength))
            : 1.0;

        final double currentAmplitude = waveAmplitude * fIn * fOut;

        // The squiggly wave place is FIXED to the track's spatial coordinates:
        // Seeking or moving the thumb does not translate wave coordinates horizontally.
        final double spatialX = x - padding;
        final double phaseOffset = waveOrigin == NixWaveOrigin.activePoint
            ? phi
            : -phi;
        final double y =
            centerY +
            currentAmplitude * math.sin(omega * spatialX + phaseOffset);

        path.lineTo(x, y);
      }

      path.lineTo(thumbX, centerY);
      canvas.drawPath(path, activePaint);
    } else {
      // Very start: draw rounded dot at origin
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(padding, centerY),
        trackHeight / 2.0,
        activePaint,
      );
    }

    // 3. Thumb Scrubber
    // Press and hold animation: width +1.0px, height -1.0px.
    // Zero elevation / shadows, transparent splash / focus indicator.
    final currentWidth =
        lerpDouble(thumbWidth, thumbWidth + 1.0, scrubProgress) ?? thumbWidth;
    final currentHeight =
        lerpDouble(thumbHeight, thumbHeight - 1.0, scrubProgress) ?? thumbHeight;

    final thumbRect = Rect.fromCenter(
      center: Offset(thumbX, centerY),
      width: currentWidth,
      height: currentHeight,
    );

    final effectiveRadius =
        thumbRadius ??
        BorderRadius.circular(math.min(currentWidth, currentHeight) / 2.0);
    final thumbRRect = effectiveRadius.toRRect(thumbRect);

    // Thumb Core Fill (No elevation/shadows, no splash/focus halo)
    canvas.drawRRect(
      thumbRRect,
      Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill,
    );

    // Thumb Border: Only drawn if developer explicitly specified a non-null border color
    if (thumbBorderColor != null && thumbBorderColor != Colors.transparent) {
      canvas.drawRRect(
        thumbRRect,
        Paint()
          ..color = thumbBorderColor!
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SquigglyWavePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.phase != phase ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.thumbBorderColor != thumbBorderColor ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.wavelength != wavelength ||
        oldDelegate.waveOrigin != waveOrigin ||
        oldDelegate.trackHeight != trackHeight ||
        oldDelegate.thumbWidth != thumbWidth ||
        oldDelegate.thumbHeight != thumbHeight ||
        oldDelegate.scrubProgress != scrubProgress;
  }
}
