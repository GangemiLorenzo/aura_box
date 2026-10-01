import 'package:aura_box/aura_box.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

import '../helpers/helpers.dart';

const _blue = Color(0xFF0000FF);
const _red = Color(0xFFFF0000);
const _duration = Duration(seconds: 1);
const _child = SizedBox(width: 100, height: 100);

void main() {
  final original = AuraProgram.instance;
  setUp(useFallback);
  tearDown(() => AuraProgram.instance = original);

  group('AnimatedAuraBox', () {
    test('rejects a grain out of range', () {
      expect(
        () => AnimatedAuraBox(spots: const [], duration: _duration, grain: 2),
        throwsAssertionError,
      );
    });

    testWidgets('builds an AuraBox with its values', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );
      const spots = [AuraSpot(color: _blue, radius: 50)];
      const drift = AuraDrift();

      await $.pumpWidget(
        const Center(
          child: AnimatedAuraBox(
            spots: spots,
            duration: _duration,
            grain: 0.3,
            drift: drift,
            child: _child,
          ),
        ),
      );

      final box = tester.widget<AuraBox>($(AuraBox));
      expect(box.spots, spots);
      expect(box.decoration, isNull);
      expect(box.grain, 0.3);
      expect(box.drift, drift);
      expect(box.child, _child);
    });

    testWidgets('animates the spots, the decoration and the grain', (
      tester,
    ) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );
      var ended = false;
      Widget build({
        required Color color,
        required double radius,
        required double grain,
      }) {
        return Center(
          child: AnimatedAuraBox(
            duration: _duration,
            onEnd: () => ended = true,
            spots: [AuraSpot(color: color, radius: 50)],
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            grain: grain,
            child: _child,
          ),
        );
      }

      await $.pumpWidget(build(color: _blue, radius: 0, grain: 0));
      await $.pumpWidget(build(color: _red, radius: 20, grain: 1));
      await $.pump(const Duration(milliseconds: 500));

      final middle = tester.widget<AuraBox>($(AuraBox));
      expect(middle.spots.single.color, Color.lerp(_blue, _red, 0.5));
      expect(
        middle.decoration!.borderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(middle.grain, 0.5);

      await $.pumpAndSettle();

      final end = tester.widget<AuraBox>($(AuraBox));
      expect(end.spots.single.color, _red);
      expect(end.grain, 1);
      expect(ended, isTrue);
    });

    testWidgets('fades a new spot in', (tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );
      const first = AuraSpot(color: _blue, radius: 50);
      const second = AuraSpot(color: _red, radius: 30);

      await $.pumpWidget(
        const Center(
          child: AnimatedAuraBox(
            spots: [first],
            duration: _duration,
            child: _child,
          ),
        ),
      );
      await $.pumpWidget(
        const Center(
          child: AnimatedAuraBox(
            spots: [first, second],
            duration: _duration,
            child: _child,
          ),
        ),
      );
      await $.pump(const Duration(milliseconds: 500));

      final box = tester.widget<AuraBox>($(AuraBox));
      expect(box.spots, hasLength(2));
      expect(box.spots[1].color.a, closeTo(0.5, 0.01));
    });
  });
}
