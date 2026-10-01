import 'package:aura_box/src/aura_drift.dart';
import 'package:aura_box/src/aura_spot.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:aura_box/src/rendering/aura_renderer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A box that paints an aura, a list of blurred [AuraSpot]s, behind its
/// [child].
///
/// ```dart
/// AuraBox(
///   spots: const [
///     AuraSpot(
///       color: Color(0xFF2196F3),
///       radius: 100,
///       alignment: Alignment.center,
///       blurRadius: 5,
///       stops: [0.0, 0.5],
///     ),
///     AuraSpot(
///       color: Color(0xFFF44336),
///       radius: 150,
///       alignment: Alignment.bottomRight,
///       blurRadius: 10,
///       stops: [0.0, 0.7],
///     ),
///   ],
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(10),
///   ),
///   child: const SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// The box takes the size of its [child]. Without a child it expands to fill
/// its parent, like a `Container`.
///
/// The spots are painted by a fragment shader in a single pass. The shader
/// loads asynchronously the first time an aura is painted, and until then the
/// spots are painted as plain gradients. Call [precache] before `runApp` to
/// skip that first fallback frame.
///
/// See also:
///
///  * `AnimatedAuraBox`, which animates changes of its spots.
///  * `AuraDecoration`, to paint an aura wherever a `Decoration` is accepted.
class AuraBox extends StatefulWidget {
  /// Creates a box that paints [spots] behind its [child].
  const AuraBox({
    required this.spots,
    this.child,
    this.decoration,
    this.grain = 0,
    this.drift,
    super.key,
  }) : assert(grain >= 0 && grain <= 1, 'The grain must be between 0 and 1');

  /// The spots to paint, layered in list order.
  final List<AuraSpot> spots;

  /// The content painted on top of the spots.
  final Widget? child;

  /// The decoration painted behind the spots.
  ///
  /// A `borderRadius` or a [BoxShape.circle] shape also cuts the spots, so
  /// they never paint outside the shape. A border insets the spots and the
  /// [child], like in a `Container`.
  final BoxDecoration? decoration;

  /// The strength of the film grain over the spots, from `0.0` (none) to
  /// `1.0`.
  ///
  /// The grain needs the fragment shader. It is not painted while the shader
  /// is loading.
  final double grain;

  /// A continuous movement of the spots. No movement when `null`.
  ///
  /// The movement stops when the platform asks to reduce animations, see
  /// [MediaQueryData.disableAnimations].
  final AuraDrift? drift;

  /// Loads the aura fragment shader ahead of time.
  ///
  /// Optional. Await it before `runApp` to make the very first frame use the
  /// shader instead of the gradient fallback. Never throws.
  static Future<void> precache() => AuraProgram.instance.ensureLoaded();

  @override
  State<AuraBox> createState() => _AuraBoxState();
}

class _AuraBoxState extends State<AuraBox> with SingleTickerProviderStateMixin {
  final AuraRenderer _renderer = AuraRenderer();
  final ValueNotifier<Duration> _elapsed = ValueNotifier(Duration.zero);
  Ticker? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTicker();
  }

  @override
  void didUpdateWidget(AuraBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTicker();
  }

  bool get _drifting =>
      widget.drift != null &&
      !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  void _updateTicker() {
    if (_drifting) {
      final ticker = _ticker ??= createTicker(
        (elapsed) => _elapsed.value = elapsed,
      );
      if (!ticker.isActive) {
        ticker.start();
      }
    } else {
      _ticker?.stop();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _elapsed.dispose();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration;
    final textDirection = Directionality.maybeOf(context);
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;

    Widget result = Stack(
      // A non-directional alignment: no Directionality ancestor needed.
      alignment: Alignment.topLeft,
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AuraPainter(
                renderer: _renderer,
                spots: widget.spots,
                shape: decoration?.shape ?? BoxShape.rectangle,
                borderRadius: decoration?.borderRadius,
                grain: widget.grain,
                devicePixelRatio: devicePixelRatio,
                textDirection: textDirection,
                drift: _drifting ? widget.drift : null,
                elapsed: _elapsed,
              ),
            ),
          ),
        ),
        widget.child ??
            LimitedBox(
              maxWidth: 0,
              maxHeight: 0,
              child: ConstrainedBox(constraints: const BoxConstraints.expand()),
            ),
      ],
    );

    if (decoration != null) {
      result = DecoratedBox(
        decoration: decoration,
        child: Padding(padding: decoration.padding, child: result),
      );
    }
    return result;
  }
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({
    required this.renderer,
    required this.spots,
    required this.shape,
    required this.borderRadius,
    required this.grain,
    required this.devicePixelRatio,
    required this.textDirection,
    required this.drift,
    required this.elapsed,
  }) : super(repaint: Listenable.merge([elapsed, AuraProgram.instance]));

  final AuraRenderer renderer;
  final List<AuraSpot> spots;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final double grain;
  final double devicePixelRatio;
  final TextDirection? textDirection;
  final AuraDrift? drift;
  final ValueListenable<Duration> elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    renderer.paint(
      canvas,
      Offset.zero & size,
      spots: spots,
      shape: shape,
      borderRadius: borderRadius,
      grain: grain,
      devicePixelRatio: devicePixelRatio,
      textDirection: textDirection,
      drift: drift,
      elapsed: elapsed.value,
    );
  }

  @override
  bool shouldRepaint(_AuraPainter oldDelegate) {
    return !listEquals(oldDelegate.spots, spots) ||
        oldDelegate.shape != shape ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.grain != grain ||
        oldDelegate.devicePixelRatio != devicePixelRatio ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.drift != drift;
  }
}
