import 'package:aura_box/src/aura_box.dart';
import 'package:aura_box/src/aura_drift.dart';
import 'package:aura_box/src/aura_spot.dart';
import 'package:flutter/widgets.dart';

/// An [AuraBox] that animates when its [spots], [decoration] or [grain]
/// change.
///
/// Spots are matched by index. A spot that has no match in the other list
/// fades in or out.
///
/// ```dart
/// AnimatedAuraBox(
///   duration: const Duration(milliseconds: 600),
///   curve: Curves.easeInOut,
///   spots: selected ? warmSpots : coldSpots,
///   child: const SizedBox(width: 200, height: 200),
/// )
/// ```
class AnimatedAuraBox extends ImplicitlyAnimatedWidget {
  /// Creates a box that animates its aura.
  const AnimatedAuraBox({
    required this.spots,
    required super.duration,
    this.child,
    this.decoration,
    this.grain = 0,
    this.drift,
    super.curve,
    super.onEnd,
    super.key,
  }) : assert(grain >= 0 && grain <= 1, 'The grain must be between 0 and 1');

  /// The spots to paint, layered in list order.
  final List<AuraSpot> spots;

  /// The content painted on top of the spots.
  final Widget? child;

  /// The decoration painted behind the spots. See [AuraBox.decoration].
  final BoxDecoration? decoration;

  /// The strength of the film grain. See [AuraBox.grain].
  final double grain;

  /// A continuous movement of the spots. See [AuraBox.drift].
  ///
  /// The drift is not animated: a new value applies immediately.
  final AuraDrift? drift;

  @override
  AnimatedWidgetBaseState<AnimatedAuraBox> createState() =>
      _AnimatedAuraBoxState();
}

class _AnimatedAuraBoxState extends AnimatedWidgetBaseState<AnimatedAuraBox> {
  _AuraSpotsTween? _spots;
  DecorationTween? _decoration;
  Tween<double>? _grain;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _spots =
        visitor(
              _spots,
              widget.spots,
              (dynamic value) =>
                  _AuraSpotsTween(begin: value as List<AuraSpot>),
            )
            as _AuraSpotsTween?;
    _decoration =
        visitor(
              _decoration,
              widget.decoration,
              (dynamic value) => DecorationTween(begin: value as Decoration),
            )
            as DecorationTween?;
    _grain =
        visitor(
              _grain,
              widget.grain,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return AuraBox(
      spots: _spots!.evaluate(animation),
      decoration: _decoration?.evaluate(animation) as BoxDecoration?,
      grain: _grain!.evaluate(animation).clamp(0, 1),
      drift: widget.drift,
      child: widget.child,
    );
  }
}

class _AuraSpotsTween extends Tween<List<AuraSpot>> {
  _AuraSpotsTween({super.begin});

  @override
  List<AuraSpot> lerp(double t) => AuraSpot.lerpList(begin, end, t);
}
