import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated equalizer wave indicator designed for active/playing media items.
///
/// Features oscillating stadium pill bars that rhythmically pulse when [isPlaying]
/// is true, and settle to a subtle resting height when paused.
class NixMusicEqualizer extends StatefulWidget {
  /// Creates a [NixMusicEqualizer].
  const NixMusicEqualizer({
    super.key,
    this.isPlaying = true,
    this.color,
    this.barCount = 3,
    this.width = 18.0,
    this.height = 16.0,
    this.barWidth = 3.0,
    this.barSpacing = 2.0,
  }) : assert(barCount >= 2 && barCount <= 6, 'barCount must be between 2 and 6');

  /// Whether the equalizer bars are animating.
  final bool isPlaying;

  /// The color of the equalizer bars. Defaults to [ColorScheme.primary].
  final Color? color;

  /// The number of vertical equalizer bars (default 3).
  final int barCount;

  /// Total width of the equalizer widget.
  final double width;

  /// Total height of the equalizer widget.
  final double height;

  /// Width of each individual pill bar.
  final double barWidth;

  /// Gap between adjacent bars.
  final double barSpacing;

  @override
  State<NixMusicEqualizer> createState() => _NixMusicEqualizerState();
}

class _NixMusicEqualizerState extends State<NixMusicEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant NixMusicEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value * 2 * math.pi;

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (index) {
              double heightFactor;
              if (widget.isPlaying) {
                // Staggered sinusoids for organic equalizer dance
                final phase = index * (math.pi / (widget.barCount / 1.5));
                final speed = 1.0 + (index * 0.4);
                final wave = (math.sin(t * speed + phase) + 1.0) / 2.0;
                heightFactor = 0.25 + (wave * 0.75);
              } else {
                heightFactor = 0.25;
              }

              final barHeight = (widget.height * heightFactor).clamp(
                widget.barWidth,
                widget.height,
              );

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.barSpacing / 2.0,
                ),
                child: Container(
                  width: widget.barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(widget.barWidth / 2.0),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

