import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A premium, aesthetic Sound Wave Loader with 11 animated vertical bars,
/// smooth staggered sinusoidal wave physics, electric-blue to vibrant cyan
/// gradient coloration, and subtle neon glow effects.
///
/// Designed to provide a modern, rhythmic waveform loading indicator
/// that integrates seamlessly into splash screens and loading states.
class SoundWaveLoader extends StatefulWidget {
  /// Maximum height of the waveform at its highest peak.
  final double height;

  /// Width of each vertical bar.
  final double barWidth;

  /// Horizontal spacing between adjacent bars.
  final double spacing;

  /// Duration of one complete wave cycle.
  final Duration cycleDuration;

  /// Whether to render soft neon glow shadows around the bars.
  final bool enableGlow;

  /// Optional custom primary electric blue color override.
  final Color? primaryColor;

  /// Optional custom cyan accent color override.
  final Color? accentColor;

  const SoundWaveLoader({
    super.key,
    this.height = 40.0,
    this.barWidth = 4.0,
    this.spacing = 3.5,
    this.cycleDuration = const Duration(milliseconds: 1400),
    this.enableGlow = true,
    this.primaryColor,
    this.accentColor,
  });

  @override
  State<SoundWaveLoader> createState() => _SoundWaveLoaderState();
}

class _SoundWaveLoaderState extends State<SoundWaveLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // 11 bars matching the reference waveform composition
  static const int _barCount = 11;

  // Relative peak height factors matching the reference image's balanced waveform
  static const List<double> _peakFactors = [
    0.28, // Bar 0: Outer left short
    0.50, // Bar 1: Medium rising
    0.82, // Bar 2: Left peak
    0.64, // Bar 3: Medium-tall
    0.46, // Bar 4: Center-left valley
    0.68, // Bar 5: Rising toward main peak
    1.00, // Bar 6: Main tall center-right peak
    0.82, // Bar 7: Right high shoulder
    0.62, // Bar 8: Medium descending
    0.46, // Bar 9: Medium-short
    0.30, // Bar 10: Outer right short
  ];

  // Base minimum height factor so bars never shrink below a pill shape
  static const double _minHeightFactor = 0.20;

  // Top gradient colors across the 11 bars:
  // Smoothly transitioning: Royal Blue (#315CF5) -> Electric Blue (#0878F9) -> Cyan (#00D9E8) -> Electric Blue (#0878F9) -> Royal Blue (#315CF5)
  static const List<Color> _defaultTopColors = [
    Color(0xFF315CF5), // Bar 0: Royal Blue
    Color(0xFF2365F6), // Bar 1: Royal Blue -> Electric Blue
    Color(0xFF156EF7), // Bar 2: Royal Blue -> Electric Blue
    Color(0xFF0878F9), // Bar 3: Electric Blue
    Color(0xFF0598F3), // Bar 4: Electric Blue -> Cyan
    Color(0xFF02B8ED), // Bar 5: Electric Blue -> Cyan
    Color(0xFF00D9E8), // Bar 6: Cyan (tallest peak)
    Color(0xFF04A8F0), // Bar 7: Cyan -> Electric Blue
    Color(0xFF0878F9), // Bar 8: Electric Blue
    Color(0xFF1C6AF7), // Bar 9: Electric Blue -> Royal Blue
    Color(0xFF315CF5), // Bar 10: Royal Blue
  ];

  // Bottom gradient colors across the 11 bars (depth anchoring)
  static const List<Color> _defaultBottomColors = [
    Color(0xFF2045D0), // Bar 0: Deep Royal Blue
    Color(0xFF254CDC), // Bar 1: Deep Royal Blue
    Color(0xFF2B54E8), // Bar 2: Royal Blue
    Color(0xFF315CF5), // Bar 3: Royal Blue
    Color(0xFF2365F6), // Bar 4: Electric/Royal Blue
    Color(0xFF156EF7), // Bar 5: Electric Blue
    Color(0xFF0878F9), // Bar 6: Electric Blue
    Color(0xFF1C6AF7), // Bar 7: Electric Blue
    Color(0xFF315CF5), // Bar 8: Royal Blue
    Color(0xFF2850E2), // Bar 9: Deep Royal Blue
    Color(0xFF2045D0), // Bar 10: Deep Royal Blue
  ];

  // Subtle cyan glow (#00D9E8) with 20% opacity (within requested 15-25% range)
  static const Color _subtleCyanGlow = Color(0x3300D9E8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(SoundWaveLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      _controller.duration = widget.cycleDuration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculates the animated height factor for a given bar [index] at normalized time [t].
  double _calculateHeightFactor(double t, int index) {
    // Primary wave harmonic with staggered spatial phase
    final w1 = math.sin(2 * math.pi * t - index * (2 * math.pi / 7.0));
    // Secondary subtle counter-harmonic for organic waveform motion
    final w2 = math.cos(4 * math.pi * t + index * (2 * math.pi / 5.0));

    final oscillation = 0.65 * (0.5 + 0.5 * w1) + 0.35 * (0.5 + 0.5 * w2);
    final peak = _peakFactors[index];

    return _minHeightFactor + (peak - _minHeightFactor) * oscillation;
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Total width of the 11 bars including spacing
    final totalWidth =
        _barCount * widget.barWidth + (_barCount - 1) * widget.spacing;

    return Semantics(
      label: 'Loading indicator',
      child: SizedBox(
        width: totalWidth,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = disableAnimations ? 0.0 : _controller.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_barCount, (index) {
                final factor = _calculateHeightFactor(t, index);
                final barHeight = math.max(
                  widget.height * factor,
                  widget.barWidth,
                );

                final topColor =
                    widget.primaryColor != null && widget.accentColor != null
                    ? Color.lerp(
                        widget.primaryColor,
                        widget.accentColor,
                        index / (_barCount - 1),
                      )!
                    : _defaultTopColors[index];

                final bottomColor =
                    widget.primaryColor != null && widget.accentColor != null
                    ? Color.lerp(
                        widget.primaryColor!.withValues(alpha: 0.8),
                        widget.accentColor!.withValues(alpha: 0.8),
                        index / (_barCount - 1),
                      )!
                    : _defaultBottomColors[index];

                return Container(
                  width: widget.barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.barWidth / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, bottomColor],
                    ),
                    boxShadow: widget.enableGlow
                        ? [
                            BoxShadow(
                              color: widget.accentColor != null
                                  ? widget.accentColor!.withValues(alpha: 0.20)
                                  : _subtleCyanGlow,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
