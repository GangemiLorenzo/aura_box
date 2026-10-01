import 'dart:ui' as ui;

import 'package:aura_box/aura_box.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:aura_box/src/rendering/aura_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

const _blue = Color(0xFF0000FF);
const _red = Color(0xFFFF0000);
const _transparent = Color(0x00000000);

/// Paints with an [AuraRenderer] through a [CustomPaint].
class _Harness extends StatefulWidget {
  const _Harness({
    required this.spots,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.grain = 0,
    this.textDirection,
    this.drift,
    this.elapsed = Duration.zero,
    this.origin = Offset.zero,
  });

  final List<AuraSpot> spots;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final double grain;
  final TextDirection? textDirection;
  final AuraDrift? drift;
  final Duration elapsed;
  final Offset origin;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final renderer = AuraRenderer();

  @override
  void dispose() {
    renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 100),
      painter: _HarnessPainter(renderer, widget),
    );
  }
}

class _HarnessPainter extends CustomPainter {
  _HarnessPainter(this.renderer, this.config);

  final AuraRenderer renderer;
  final _Harness config;

  @override
  void paint(Canvas canvas, Size size) {
    renderer.paint(
      canvas,
      config.origin & (size - config.origin as Size),
      spots: config.spots,
      shape: config.shape,
      borderRadius: config.borderRadius,
      grain: config.grain,
      textDirection: config.textDirection,
      drift: config.drift,
      elapsed: config.elapsed,
    );
  }

  @override
  bool shouldRepaint(_HarnessPainter oldDelegate) => true;
}

/// Runs [body] once with the gradient fallback and once with the shader.
void testBothPaths(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets('$description (fallback)', (tester) async {
    useFallback();
    await body(tester);
  });
  testWidgets('$description (shader)', (tester) async {
    await useShader(tester);
    await body(tester);
  });
}

void main() {
  final original = AuraProgram.instance;
  tearDown(() => AuraProgram.instance = original);

  group('AuraRenderer', () {
    testBothPaths('paints the color of a spot at its center', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(spots: [AuraSpot(color: _blue, radius: 40)]),
      );

      expectColor(pixels.at(50, 50), _blue, tolerance: 8);
    });

    testBothPaths('fades a spot linearly to transparent', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(spots: [AuraSpot(color: _blue, radius: 40)]),
      );

      expectColor(
        pixels.at(70, 50),
        _blue.withValues(alpha: 0.5),
        tolerance: 6,
      );
      expectColor(pixels.at(95, 50), _transparent);
      expectColor(pixels.at(2, 2), _transparent);
    });

    testBothPaths('keeps a spot opaque up to the first stop', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(color: _blue, radius: 40, stops: [0.5, 1]),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(65, 50), _blue);
      expectColor(
        pixels.at(80, 50),
        _blue.withValues(alpha: 0.5),
        tolerance: 8,
      );
    });

    testBothPaths('paints a disc when both stops are equal', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(color: _blue, radius: 40, stops: [0.5, 0.5]),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(65, 50), _blue);
      expectColor(pixels.at(75, 50), _transparent);
    });

    testBothPaths('blurs a spot', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(
              color: _blue,
              radius: 30,
              blurRadius: 10,
              stops: [0.99, 1],
            ),
          ],
        ),
      );

      // The blur lowers the center and spreads past the radius. On the edge
      // of a disc the value is below one half, because the edge is curved.
      expect(pixels.at(50, 50).a, inInclusiveRange(0.85, 0.999));
      expect(pixels.at(80, 50).a, inInclusiveRange(0.35, 0.5));
      expect(pixels.at(90, 50).a, inInclusiveRange(0.02, 0.3));
    });

    testBothPaths('layers the spots in list order', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(color: _blue, radius: 200, stops: [0.9, 1]),
            AuraSpot(color: _red, radius: 20, stops: [0.9, 1]),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _red);
      expectColor(pixels.at(90, 50), _blue);
    });

    testBothPaths('positions a spot with its alignment', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(
              color: _blue,
              radius: 20,
              alignment: Alignment.bottomRight,
              stops: [0.9, 1],
            ),
          ],
        ),
      );

      expectColor(pixels.at(98, 98), _blue);
      expectColor(pixels.at(50, 50), _transparent);
    });

    testBothPaths('resolves a directional alignment', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          textDirection: TextDirection.rtl,
          spots: [
            AuraSpot(
              color: _blue,
              radius: 20,
              alignment: AlignmentDirectional.centerStart,
              stops: [0.9, 1],
            ),
          ],
        ),
      );

      expectColor(pixels.at(98, 50), _blue);
      expectColor(pixels.at(2, 50), _transparent);
    });

    testBothPaths('cuts the spots to a circle', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          shape: BoxShape.circle,
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testBothPaths('cuts the spots to a border radius', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(50, 2), _blue);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testBothPaths('treats a zero border radius as a rectangle', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          borderRadius: BorderRadius.zero,
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
        ),
      );

      expectColor(pixels.at(1, 1), _blue);
    });

    testBothPaths('paints relative to the origin of the rect', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          origin: Offset(50, 50),
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
        ),
      );

      expectColor(pixels.at(75, 75), _blue);
      expectColor(pixels.at(25, 25), _transparent);
    });

    testBothPaths('moves the spots with a drift', (tester) async {
      const spots = [
        AuraSpot(color: _blue, radius: 30, stops: [0.9, 1]),
      ];
      final still = await pumpAndCapture(tester, const _Harness(spots: spots));
      final moved = await pumpAndCapture(
        tester,
        const _Harness(
          spots: spots,
          drift: AuraDrift(amplitude: 0.5),
          elapsed: Duration(seconds: 2),
        ),
      );

      expect(moved.difference(still), greaterThan(1));
    });

    testBothPaths('paints more spots than one pass holds', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        _Harness(
          spots: [
            for (var i = 0; i < auraSpotsPerPass * 2 + 1; i++)
              AuraSpot(
                color: i == auraSpotsPerPass * 2 ? _red : _blue,
                radius: 30,
                alignment: Alignment(i.isEven ? -0.5 : 0.5, 0),
                stops: const [0.9, 1],
              ),
          ],
        ),
      );

      // The last spot is painted by the third pass, on top of the others.
      expectColor(pixels.at(25, 50), _red);
      expectColor(pixels.at(75, 50), _blue);
    });

    testBothPaths('skips invisible spots', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const _Harness(
          spots: [
            AuraSpot(color: _transparent, radius: 40),
            AuraSpot(color: _blue, radius: 0),
          ],
        ),
      );

      expectColor(pixels.at(50, 50), _transparent);
    });

    testBothPaths('paints nothing without spots', (tester) async {
      final pixels = await pumpAndCapture(tester, const _Harness(spots: []));

      expectColor(pixels.at(50, 50), _transparent);
    });

    testWidgets('paints nothing in an empty or infinite rect', (tester) async {
      await useShader(tester);
      final renderer = AuraRenderer();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const spots = [AuraSpot(color: _blue, radius: 40)];

      renderer
        ..paint(canvas, Rect.zero, spots: spots)
        ..paint(canvas, const Rect.fromLTWH(0, 0, 10, 0), spots: spots)
        ..paint(
          canvas,
          const Rect.fromLTWH(0, 0, double.infinity, 10),
          spots: spots,
        )
        ..dispose();

      final picture = recorder.endRecording();
      expect(picture.approximateBytesUsed, lessThan(1000));
      picture.dispose();
    });

    testWidgets('asserts that the spots are valid', (tester) async {
      useFallback();
      await tester.pumpWidget(
        const _Harness(
          spots: [
            AuraSpot(color: _blue, radius: 40, stops: [1, 0]),
          ],
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('the shader matches the fallback', (tester) async {
      const harness = _Harness(
        spots: [
          AuraSpot(
            color: _blue,
            radius: 60,
            alignment: Alignment.topLeft,
            blurRadius: 15,
          ),
          AuraSpot(
            color: _red,
            radius: 50,
            alignment: Alignment.bottomRight,
            blurRadius: 40,
            stops: [0.2, 0.8],
          ),
          AuraSpot(color: Color(0x8000FF00), radius: 30),
        ],
      );
      useFallback();
      final fallback = await pumpAndCapture(tester, harness);
      await tester.pumpWidget(const SizedBox());
      await useShader(tester);
      final shader = await pumpAndCapture(tester, harness);

      expect(shader.difference(fallback), lessThan(1.5));
    });

    testWidgets('the grain adds noise with the shader', (tester) async {
      await useShader(tester);
      const spots = [AuraSpot(color: Color(0xFF808080), radius: 500)];
      final clean = await pumpAndCapture(tester, const _Harness(spots: spots));
      final grainy = await pumpAndCapture(
        tester,
        const _Harness(spots: spots, grain: 0.5),
      );

      expect(grainy.difference(clean), greaterThan(2));
      // The grain is noise around the same color, not a tint.
      expect(grainy.difference(clean), lessThan(40));
    });

    testWidgets('switches to the shader when a new program is set', (
      tester,
    ) async {
      const harness = _Harness(spots: [AuraSpot(color: _blue, radius: 40)]);
      await useShader(tester);
      await pumpAndCapture(tester, harness);

      // A new program: the passes of the previous one are disposed.
      await useShader(tester);
      final pixels = await pumpAndCapture(tester, harness);

      expectColor(pixels.at(50, 50), _blue, tolerance: 8);
    });
  });
}
