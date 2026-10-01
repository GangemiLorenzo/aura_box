import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A slow, continuous movement applied to every spot of an `AuraBox`.
///
/// Each spot wanders around its own alignment on a smooth path. The path is
/// different for each spot and fully determined by the spot index and the
/// [seed], so the same configuration always produces the same motion.
@immutable
class AuraDrift {
  /// Creates a drift.
  const AuraDrift({
    this.amplitude = 0.2,
    this.period = const Duration(seconds: 12),
    this.seed = 0,
  }) : assert(amplitude >= 0, 'The amplitude must not be negative');

  /// How far a spot moves away from its alignment, in alignment units.
  ///
  /// An amplitude of `1.0` is half the size of the box.
  final double amplitude;

  /// The time a spot takes to complete one loop, on average.
  ///
  /// Each spot runs slightly faster or slower than this, so the spots never
  /// move in lockstep.
  final Duration period;

  /// Selects a different set of paths. Any integer is valid.
  final int seed;

  /// The displacement of the spot at [index] after [elapsed] time.
  ///
  /// The result is in alignment units. Add it to the alignment of the spot.
  Alignment offsetAt(int index, Duration elapsed) {
    final micros = period.inMicroseconds;
    if (amplitude == 0 || micros <= 0) {
      return Alignment.center;
    }
    final turns = elapsed.inMicroseconds / micros;
    final angle = 2 * math.pi * turns;
    final phaseX = _unit(index, 0) * 2 * math.pi;
    final phaseY = _unit(index, 1) * 2 * math.pi;
    final speedX = 0.7 + 0.6 * _unit(index, 2);
    final speedY = 0.7 + 0.6 * _unit(index, 3);
    return Alignment(
      amplitude * math.sin(angle * speedX + phaseX),
      amplitude * math.cos(angle * speedY + phaseY),
    );
  }

  /// A repeatable pseudo-random value in `0.0..1.0`.
  double _unit(int index, int channel) {
    final x =
        math.sin(index * 12.9898 + channel * 78.233 + seed * 37.719) *
        43758.5453;
    return x - x.floorToDouble();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AuraDrift &&
        other.amplitude == amplitude &&
        other.period == period &&
        other.seed == seed;
  }

  @override
  int get hashCode => Object.hash(amplitude, period, seed);

  @override
  String toString() =>
      'AuraDrift(amplitude: $amplitude, period: $period, seed: $seed)';
}
