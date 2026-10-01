import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A single spot of an aura: a radial falloff of one [color], optionally
/// blurred.
///
/// A spot is plain immutable data. It is painted by an `AuraBox` or an
/// `AuraDecoration`, and it can be interpolated with [lerp].
///
/// ```dart
/// const AuraSpot(
///   color: Color(0xFF2196F3),
///   radius: 100,
///   alignment: Alignment.center,
///   blurRadius: 5,
///   stops: [0.0, 0.5],
/// )
/// ```
@immutable
class AuraSpot with Diagnosticable {
  /// Creates a spot.
  ///
  /// The [radius] and the [blurRadius] must not be negative. The [stops] must
  /// contain exactly two values in ascending order, both between 0 and 1.
  const AuraSpot({
    required this.color,
    required this.radius,
    this.alignment = Alignment.center,
    this.blurRadius = 0,
    this.stops = const [0.0, 1.0],
  }) : assert(radius >= 0, 'The radius must not be negative'),
       assert(blurRadius >= 0, 'The blur radius must not be negative');

  /// The color at the center of the spot. It fades to transparent at the
  /// edge.
  final Color color;

  /// The radius of the spot, in logical pixels.
  final double radius;

  /// The position of the center of the spot inside the box.
  ///
  /// Values outside the `-1.0..1.0` range place the center outside the box.
  final AlignmentGeometry alignment;

  /// The intensity of the blur, as the standard deviation of a Gaussian in
  /// logical pixels.
  final double blurRadius;

  /// Where the fade starts and ends, as fractions of the [radius].
  ///
  /// The spot is fully opaque up to `stops[0]` and fully transparent from
  /// `stops[1]`. Must contain exactly two values.
  final List<double> stops;

  /// The distance from the center where the fade starts, in logical pixels.
  double get innerRadius => radius * stops[0];

  /// The distance from the center where the fade ends, in logical pixels.
  double get outerRadius => radius * stops[1];

  /// Asserts that the [stops] are valid.
  ///
  /// The check cannot run in the constructor because it would prevent
  /// `const` spots.
  bool debugAssertIsValid() {
    assert(stops.length == 2, 'Stops length must be equal to 2');
    assert(
      stops[0] >= 0 && stops[0] <= stops[1] && stops[1] <= 1,
      'Stops must be in ascending order, between 0 and 1',
    );
    return true;
  }

  /// Returns a copy of this spot with the given fields replaced.
  AuraSpot copyWith({
    Color? color,
    double? radius,
    AlignmentGeometry? alignment,
    double? blurRadius,
    List<double>? stops,
  }) {
    return AuraSpot(
      color: color ?? this.color,
      radius: radius ?? this.radius,
      alignment: alignment ?? this.alignment,
      blurRadius: blurRadius ?? this.blurRadius,
      stops: stops ?? this.stops,
    );
  }

  /// Returns a copy of this spot with its opacity multiplied by [factor].
  AuraSpot scale(double factor) {
    return copyWith(color: color.withValues(alpha: color.a * factor));
  }

  /// Linearly interpolates between two spots.
  ///
  /// A `null` spot is treated as a fully transparent copy of the other one,
  /// so a spot can fade in or out.
  static AuraSpot? lerp(AuraSpot? a, AuraSpot? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1 - t);
    }
    return AuraSpot(
      color: Color.lerp(a.color, b.color, t)!,
      radius: lerpDouble(a.radius, b.radius, t)!,
      alignment: AlignmentGeometry.lerp(a.alignment, b.alignment, t)!,
      blurRadius: lerpDouble(a.blurRadius, b.blurRadius, t)!,
      stops: [
        lerpDouble(a.stops[0], b.stops[0], t)!,
        lerpDouble(a.stops[1], b.stops[1], t)!,
      ],
    );
  }

  /// Linearly interpolates between two lists of spots.
  ///
  /// Spots are matched by index. When the lists have different lengths, the
  /// extra spots fade in or out.
  static List<AuraSpot> lerpList(
    List<AuraSpot>? a,
    List<AuraSpot>? b,
    double t,
  ) {
    final from = a ?? const <AuraSpot>[];
    final to = b ?? const <AuraSpot>[];
    return [
      for (var i = 0; i < from.length || i < to.length; i++)
        lerp(
          i < from.length ? from[i] : null,
          i < to.length ? to[i] : null,
          t,
        )!,
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AuraSpot &&
        other.color == color &&
        other.radius == radius &&
        other.alignment == alignment &&
        other.blurRadius == blurRadius &&
        listEquals(other.stops, stops);
  }

  @override
  int get hashCode =>
      Object.hash(color, radius, alignment, blurRadius, Object.hashAll(stops));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('radius', radius))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment))
      ..add(DoubleProperty('blurRadius', blurRadius, defaultValue: 0.0))
      ..add(IterableProperty<double>('stops', stops));
  }
}
