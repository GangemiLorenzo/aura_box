import 'package:aura_box/aura_box.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

import '../helpers/helpers.dart';

const _blue = Color(0xFF0000FF);
const _red = Color(0xFFFF0000);
const _transparent = Color(0x00000000);

const _spot = AuraSpot(color: _blue, radius: 20, stops: [0.9, 1]);
const _child = SizedBox(width: 100, height: 100);

void main() {
  final original = AuraProgram.instance;
  setUp(useFallback);
  tearDown(() => AuraProgram.instance = original);

  group('AuraBox', () {
    test('rejects a grain out of range', () {
      expect(() => AuraBox(spots: const [], grain: -0.1), throwsAssertionError);
    });

    testWidgets('paints the spots behind the child', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const AuraBox(
          spots: [_spot],
          child: SizedBox(
            width: 100,
            height: 100,
            child: Align(
              alignment: Alignment.topLeft,
              child: ColoredBox(
                color: _red,
                child: SizedBox(width: 10, height: 10),
              ),
            ),
          ),
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(5, 5), _red);
      expectColor(pixels.at(90, 90), _transparent);
    });

    testWidgets('works without a Directionality', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        const Center(
          child: AuraBox(spots: [_spot], child: _child),
        ),
      );

      expect(tester.takeException(), isNull);
      expect($(AuraBox), findsOneWidget);
    });

    testWidgets('reads the device pixel ratio from the MediaQuery', (
      tester,
    ) async {
      final pixels = await pumpAndCapture(
        tester,
        const MediaQuery(
          data: MediaQueryData(devicePixelRatio: 2),
          child: AuraBox(spots: [_spot], child: _child),
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
    });

    testWidgets('takes the size of its child', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        const Center(
          child: AuraBox(
            spots: [_spot],
            child: SizedBox(width: 80, height: 40),
          ),
        ),
      );

      expect(tester.getSize($(AuraBox)), const Size(80, 40));
    });

    testWidgets('fills its parent without a child', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        const Center(
          child: SizedBox(
            width: 120,
            height: 60,
            child: AuraBox(spots: [_spot]),
          ),
        ),
      );

      expect(tester.getSize($(AuraBox)), const Size(120, 60));
    });

    testWidgets('collapses without a child in an unbounded parent', (
      tester,
    ) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              AuraBox(spots: [_spot]),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize($(AuraBox)).height, 0);
    });

    testWidgets('does not throw with a zero or tiny size', (tester) async {
      for (final size in const [Size.zero, Size(0.5, 0.5), Size(100, 0)]) {
        await tester.pumpWidget(
          Center(
            child: AuraBox(
              spots: const [_spot],
              child: SizedBox.fromSize(size: size),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('paints the decoration behind the spots', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const AuraBox(
          spots: [_spot],
          decoration: BoxDecoration(color: _red),
          child: _child,
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(5, 5), _red);
    });

    testWidgets('cuts the spots to the border radius of the decoration', (
      tester,
    ) async {
      final pixels = await pumpAndCapture(
        tester,
        const AuraBox(
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: _child,
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testWidgets('cuts the spots to a circle decoration', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        const AuraBox(
          spots: [
            AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
          ],
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: _child,
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testWidgets('insets the spots and the child by the border', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );
      final key = GlobalKey();

      await $.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: key,
            child: AuraBox(
              spots: const [
                AuraSpot(color: _blue, radius: 500, stops: [0.9, 1]),
              ],
              decoration: BoxDecoration(
                border: Border.all(color: _red, width: 10),
              ),
              child: _child,
            ),
          ),
        ),
      );
      final pixels = await capture(tester, key);

      expect(tester.getSize($(AuraBox)), const Size(120, 120));
      expectColor(pixels.at(5, 5), _red);
      expectColor(pixels.at(60, 60), _blue);
    });

    testWidgets('repaints when the spots change', (tester) async {
      await pumpAndCapture(
        tester,
        const AuraBox(spots: [_spot], child: _child),
      );
      final pixels = await pumpAndCapture(
        tester,
        const AuraBox(
          spots: [
            AuraSpot(color: _red, radius: 20, stops: [0.9, 1]),
          ],
          child: _child,
        ),
      );

      expectColor(pixels.at(50, 50), _red);
    });

    testWidgets('switches to the shader when it is loaded', (tester) async {
      AuraProgram.instance = AuraProgram();
      final key = GlobalKey();
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: key,
            child: const AuraBox(
              spots: [AuraSpot(color: Color(0xFF808080), radius: 500)],
              grain: 1,
              child: _child,
            ),
          ),
        ),
      );
      // The first frame uses the fallback, which has no grain.
      final fallback = await capture(tester, key);

      await tester.runAsync(AuraBox.precache);
      await tester.pump();
      final shader = await capture(tester, key);

      expect(shader.difference(fallback), greaterThan(2));
    });

    group('drift', () {
      const drifting = AuraBox(
        spots: [_spot],
        drift: AuraDrift(amplitude: 0.5),
        child: _child,
      );

      testWidgets('moves the spots over time', (tester) async {
        final start = await pumpAndCapture(tester, drifting);
        expect(tester.hasRunningAnimations, isTrue);

        await tester.pump(const Duration(seconds: 2));
        final key = find.byType(RepaintBoundary).evaluate().first.widget.key!;
        final later = await capture(tester, key as GlobalKey);

        expect(later.difference(start), greaterThan(1));
      });

      testWidgets('keeps running when the widget updates', (tester) async {
        await tester.pumpWidget(const Center(child: drifting));
        await tester.pumpWidget(
          const Center(
            child: AuraBox(
              spots: [_spot],
              grain: 0.1,
              drift: AuraDrift(amplitude: 0.5),
              child: _child,
            ),
          ),
        );

        expect(tester.hasRunningAnimations, isTrue);
      });

      testWidgets('stops when the drift is removed', (tester) async {
        await tester.pumpWidget(const Center(child: drifting));
        await tester.pumpWidget(
          const Center(
            child: AuraBox(spots: [_spot], child: _child),
          ),
        );

        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('does not move when animations are disabled', (tester) async {
        final still = await pumpAndCapture(
          tester,
          const AuraBox(spots: [_spot], child: _child),
        );
        final reduced = await pumpAndCapture(
          tester,
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: drifting,
          ),
        );

        expect(tester.hasRunningAnimations, isFalse);
        expect(reduced.difference(still), 0);
      });
    });
  });
}
