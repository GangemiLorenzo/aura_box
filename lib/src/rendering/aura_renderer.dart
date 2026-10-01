import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:aura_box/src/aura_drift.dart';
import 'package:aura_box/src/aura_spot.dart';
import 'package:aura_box/src/rendering/aura_profile.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter/painting.dart';

/// The number of spots the fragment shader paints in one pass.
///
/// Must match `MAX_SPOTS` in `shaders/aura.frag`.
const int auraSpotsPerPass = 8;

/// The number of color stops of a blurred spot in the fallback rendering.
const int _fallbackStops = 24;

/// Paints a list of [AuraSpot]s.
///
/// The spots are painted with the aura fragment shader, a single draw call
/// for every [auraSpotsPerPass] spots. While the shader is loading, or if it
/// cannot be loaded, each spot is painted as a plain radial gradient that
/// follows the same falloff curve, without dithering and grain.
///
/// A renderer owns native shader objects. Call [dispose] when it is no longer
/// needed.
final class AuraRenderer {
  final List<_ShaderPass> _passes = [];
  final Paint _paint = Paint();
  ui.FragmentProgram? _program;

  /// Paints the [spots] inside [rect].
  ///
  /// The painted area is [rect] cut to the given [shape] and [borderRadius],
  /// with the same meaning as in a [BoxDecoration].
  void paint(
    Canvas canvas,
    Rect rect, {
    required List<AuraSpot> spots,
    BoxShape shape = BoxShape.rectangle,
    BorderRadiusGeometry? borderRadius,
    double grain = 0,
    double devicePixelRatio = 1,
    TextDirection? textDirection,
    AuraDrift? drift,
    Duration elapsed = Duration.zero,
  }) {
    if (spots.isEmpty || rect.isEmpty || !rect.isFinite) {
      return;
    }

    // Paint in the coordinate space of the box, so the shader noise does not
    // depend on where the box is on the screen.
    final box = Offset.zero & rect.size;
    final minimumFade = 1 / devicePixelRatio;
    final resolved = <_ResolvedSpot>[];
    for (var i = 0; i < spots.length; i++) {
      final spot = spots[i];
      assert(spot.debugAssertIsValid(), 'Invalid spot at index $i');
      if (spot.color.a <= 0 || spot.outerRadius <= 0) {
        continue;
      }
      var alignment = spot.alignment.resolve(textDirection);
      if (drift != null) {
        alignment += drift.offsetAt(i, elapsed);
      }
      resolved.add(
        _ResolvedSpot(
          color: spot.color.withValues(colorSpace: ui.ColorSpace.extendedSRGB),
          center: alignment.withinRect(box),
          inner: spot.innerRadius,
          // A zero-width fade would alias. Keep it one device pixel wide.
          outer: math.max(spot.outerRadius, spot.innerRadius + minimumFade),
          sigma: spot.blurRadius,
        ),
      );
    }
    if (resolved.isEmpty) {
      return;
    }

    canvas
      ..save()
      ..translate(rect.left, rect.top);
    final program = AuraProgram.instance.program;
    if (program == null) {
      unawaited(AuraProgram.instance.ensureLoaded());
      _paintFallback(canvas, box, resolved, shape, borderRadius, textDirection);
    } else {
      _paintShader(
        canvas,
        box,
        resolved,
        program,
        shape,
        borderRadius,
        textDirection,
        grain,
        devicePixelRatio,
      );
    }
    canvas.restore();
  }

  void _paintShader(
    Canvas canvas,
    Rect box,
    List<_ResolvedSpot> spots,
    ui.FragmentProgram program,
    BoxShape shape,
    BorderRadiusGeometry? borderRadius,
    TextDirection? textDirection,
    double grain,
    double devicePixelRatio,
  ) {
    if (!identical(program, _program)) {
      _disposePasses();
      _program = program;
    }
    final passCount = (spots.length / auraSpotsPerPass).ceil();
    while (_passes.length < passCount) {
      _passes.add(_ShaderPass(program.fragmentShader()));
    }
    for (var p = 0; p < passCount; p++) {
      final pass = _passes[p];
      final start = p * auraSpotsPerPass;
      final count = math.min(auraSpotsPerPass, spots.length - start);
      pass.count.set(count.toDouble());
      // The grain is applied once, by the last pass.
      pass.grain.set(p == passCount - 1 ? grain : 0);
      pass.pixelRatio.set(devicePixelRatio);
      for (var i = 0; i < count; i++) {
        final spot = spots[start + i];
        final color = spot.color;
        pass.colors[i].set(color.r, color.g, color.b, color.a);
        pass.geometries[i].set(
          spot.center.dx,
          spot.center.dy,
          spot.inner,
          spot.outer,
        );
        pass.sigmas[i].set(spot.sigma);
      }
      _paint.shader = pass.shader;
      _drawShape(canvas, box, shape, borderRadius, textDirection);
    }
    _paint.shader = null;
  }

  void _paintFallback(
    Canvas canvas,
    Rect box,
    List<_ResolvedSpot> spots,
    BoxShape shape,
    BorderRadiusGeometry? borderRadius,
    TextDirection? textDirection,
  ) {
    for (final spot in spots) {
      final gradient = _fallbackGradient(spot);
      _paint.shader = gradient;
      _drawShape(canvas, box, shape, borderRadius, textDirection);
      gradient.dispose();
    }
    _paint.shader = null;
  }

  ui.Gradient _fallbackGradient(_ResolvedSpot spot) {
    final color = spot.color;
    final transparent = color.withValues(alpha: 0);
    if (spot.sigma <= 0) {
      return ui.Gradient.radial(
        spot.center,
        spot.outer,
        [color, transparent],
        [spot.inner / spot.outer, 1],
      );
    }
    // Sample the blurred falloff curve. It is negligible three sigmas after
    // the outer radius.
    final extent = spot.outer + 3 * spot.sigma;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < _fallbackStops; i++) {
      final stop = i / (_fallbackStops - 1);
      final opacity = i == _fallbackStops - 1
          ? 0.0
          : auraFalloff(stop * extent, spot.inner, spot.outer, spot.sigma);
      colors.add(color.withValues(alpha: color.a * opacity));
      stops.add(stop);
    }
    return ui.Gradient.radial(spot.center, extent, colors, stops);
  }

  void _drawShape(
    Canvas canvas,
    Rect box,
    BoxShape shape,
    BorderRadiusGeometry? borderRadius,
    TextDirection? textDirection,
  ) {
    switch (shape) {
      case BoxShape.circle:
        canvas.drawCircle(box.center, box.shortestSide / 2, _paint);
      case BoxShape.rectangle:
        if (borderRadius == null || borderRadius == BorderRadius.zero) {
          canvas.drawRect(box, _paint);
        } else {
          canvas.drawRRect(
            borderRadius.resolve(textDirection).toRRect(box),
            _paint,
          );
        }
    }
  }

  void _disposePasses() {
    for (final pass in _passes) {
      pass.shader.dispose();
    }
    _passes.clear();
  }

  /// Releases the native resources held by this renderer.
  void dispose() {
    _disposePasses();
    _program = null;
  }
}

/// A spot resolved against a box: absolute center, radii in logical pixels.
class _ResolvedSpot {
  const _ResolvedSpot({
    required this.color,
    required this.center,
    required this.inner,
    required this.outer,
    required this.sigma,
  });

  final Color color;
  final Offset center;
  final double inner;
  final double outer;
  final double sigma;
}

/// A fragment shader instance with its uniforms bound by name.
class _ShaderPass {
  _ShaderPass(this.shader)
    : count = shader.getUniformFloat('uCount'),
      grain = shader.getUniformFloat('uGrain'),
      pixelRatio = shader.getUniformFloat('uPixelRatio'),
      colors = shader.getUniformVec4Array('uColor'),
      geometries = shader.getUniformVec4Array('uGeom'),
      sigmas = shader.getUniformFloatArray('uSigma');

  final ui.FragmentShader shader;
  final ui.UniformFloatSlot count;
  final ui.UniformFloatSlot grain;
  final ui.UniformFloatSlot pixelRatio;
  final ui.UniformArray<ui.UniformVec4Slot> colors;
  final ui.UniformArray<ui.UniformVec4Slot> geometries;
  final ui.UniformArray<ui.UniformFloatSlot> sigmas;
}
