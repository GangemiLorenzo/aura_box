import 'dart:ui' show lerpDouble;

import 'package:aura_box/src/aura_spot.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:aura_box/src/rendering/aura_renderer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A [Decoration] that paints an aura: a list of blurred [AuraSpot]s over an
/// optional background [color].
///
/// Use it wherever a decoration is accepted, for example in a `DecoratedBox`
/// or a `Container`. Two aura decorations interpolate smoothly, so an
/// `AnimatedContainer` animates between them.
///
/// ```dart
/// DecoratedBox(
///   decoration: AuraDecoration(
///     borderRadius: BorderRadius.circular(16),
///     spots: const [
///       AuraSpot(color: Color(0xFF2196F3), radius: 200, blurRadius: 40),
///     ],
///   ),
///   child: const SizedBox(width: 200, height: 200),
/// )
/// ```
@immutable
class AuraDecoration extends Decoration {
  /// Creates an aura decoration.
  ///
  /// The [borderRadius] must be `null` when the [shape] is
  /// [BoxShape.circle].
  const AuraDecoration({
    required this.spots,
    this.color,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.grain = 0,
  }) : assert(
         shape != BoxShape.circle || borderRadius == null,
         'A circle cannot have a border radius',
       ),
       assert(grain >= 0 && grain <= 1, 'The grain must be between 0 and 1');

  /// The spots to paint, layered in list order.
  final List<AuraSpot> spots;

  /// The color painted behind the spots.
  final Color? color;

  /// Rounds the corners of the box. Only for [BoxShape.rectangle].
  final BorderRadiusGeometry? borderRadius;

  /// The shape of the painted area.
  final BoxShape shape;

  /// The strength of the film grain over the spots, from `0.0` (none) to
  /// `1.0`.
  ///
  /// The grain needs the fragment shader. It is not painted while the shader
  /// is loading.
  final double grain;

  /// Returns a copy of this decoration with the opacity of the spots and of
  /// the [color] multiplied by [factor].
  AuraDecoration scale(double factor) {
    return AuraDecoration(
      spots: [for (final spot in spots) spot.scale(factor)],
      color: Color.lerp(null, color, factor),
      borderRadius: BorderRadiusGeometry.lerp(null, borderRadius, factor),
      shape: shape,
      grain: grain * factor,
    );
  }

  @override
  bool get isComplex => true;

  @override
  AuraDecoration? lerpFrom(Decoration? a, double t) {
    if (a == null) {
      return scale(t);
    }
    if (a is AuraDecoration) {
      return AuraDecoration.lerp(a, this, t);
    }
    return super.lerpFrom(a, t) as AuraDecoration?;
  }

  @override
  AuraDecoration? lerpTo(Decoration? b, double t) {
    if (b == null) {
      return scale(1 - t);
    }
    if (b is AuraDecoration) {
      return AuraDecoration.lerp(this, b, t);
    }
    return super.lerpTo(b, t) as AuraDecoration?;
  }

  /// Linearly interpolates between two aura decorations.
  ///
  /// The [shape] is not interpolated: it switches at the midpoint.
  static AuraDecoration? lerp(AuraDecoration? a, AuraDecoration? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1 - t);
    }
    if (t == 0) {
      return a;
    }
    if (t == 1) {
      return b;
    }
    final shape = t < 0.5 ? a.shape : b.shape;
    return AuraDecoration(
      spots: AuraSpot.lerpList(a.spots, b.spots, t),
      color: Color.lerp(a.color, b.color, t),
      borderRadius: shape == BoxShape.circle
          ? null
          : BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      shape: shape,
      grain: lerpDouble(a.grain, b.grain, t)!,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    switch (shape) {
      case BoxShape.circle:
        return Path()..addOval(
          Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2),
        );
      case BoxShape.rectangle:
        final radius = borderRadius;
        if (radius == null) {
          return Path()..addRect(rect);
        }
        return Path()..addRRect(radius.resolve(textDirection).toRRect(rect));
    }
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) {
    return getClipPath(
      Offset.zero & size,
      textDirection ?? TextDirection.ltr,
    ).contains(position);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _AuraBoxPainter(this, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AuraDecoration &&
        listEquals(other.spots, spots) &&
        other.color == color &&
        other.borderRadius == borderRadius &&
        other.shape == shape &&
        other.grain == grain;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(spots), color, borderRadius, shape, grain);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<AuraSpot>('spots', spots))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(EnumProperty<BoxShape>('shape', shape))
      ..add(DoubleProperty('grain', grain, defaultValue: 0.0));
  }
}

class _AuraBoxPainter extends BoxPainter {
  _AuraBoxPainter(this._decoration, super.onChanged) {
    // Repaint with the shader as soon as it is available.
    if (onChanged != null) {
      AuraProgram.instance.addListener(onChanged!);
    }
  }

  final AuraDecoration _decoration;
  final AuraRenderer _renderer = AuraRenderer();

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final textDirection = configuration.textDirection;
    final color = _decoration.color;
    if (color != null) {
      final paint = Paint()..color = color;
      switch (_decoration.shape) {
        case BoxShape.circle:
          canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
        case BoxShape.rectangle:
          final radius = _decoration.borderRadius;
          if (radius == null) {
            canvas.drawRect(rect, paint);
          } else {
            canvas.drawRRect(
              radius.resolve(textDirection).toRRect(rect),
              paint,
            );
          }
      }
    }
    _renderer.paint(
      canvas,
      rect,
      spots: _decoration.spots,
      shape: _decoration.shape,
      borderRadius: _decoration.borderRadius,
      grain: _decoration.grain,
      devicePixelRatio: configuration.devicePixelRatio ?? 1,
      textDirection: textDirection,
    );
  }

  @override
  void dispose() {
    if (onChanged != null) {
      AuraProgram.instance.removeListener(onChanged!);
    }
    _renderer.dispose();
    super.dispose();
  }
}
