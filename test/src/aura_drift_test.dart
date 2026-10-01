import 'package:aura_box/aura_box.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuraDrift', () {
    test('rejects a negative amplitude', () {
      expect(() => AuraDrift(amplitude: -1), throwsAssertionError);
    });

    test('does not move with a zero amplitude or a zero period', () {
      const still = AuraDrift(amplitude: 0);
      const instant = AuraDrift(period: Duration.zero);

      expect(still.offsetAt(0, const Duration(seconds: 3)), Alignment.center);
      expect(instant.offsetAt(0, const Duration(seconds: 3)), Alignment.center);
    });

    test('stays within the amplitude', () {
      const drift = AuraDrift(amplitude: 0.3);

      for (var index = 0; index < 8; index++) {
        for (var ms = 0; ms < 60000; ms += 777) {
          final offset = drift.offsetAt(index, Duration(milliseconds: ms));
          expect(offset.x.abs(), lessThanOrEqualTo(0.3));
          expect(offset.y.abs(), lessThanOrEqualTo(0.3));
        }
      }
    });

    test('is repeatable', () {
      const elapsed = Duration(milliseconds: 4321);

      expect(
        const AuraDrift(seed: 7).offsetAt(2, elapsed),
        const AuraDrift(seed: 7).offsetAt(2, elapsed),
      );
    });

    test('moves over time', () {
      const drift = AuraDrift();

      expect(
        drift.offsetAt(0, Duration.zero),
        isNot(drift.offsetAt(0, const Duration(seconds: 2))),
      );
    });

    test('gives each spot and each seed a different path', () {
      const elapsed = Duration(seconds: 1);

      expect(
        const AuraDrift().offsetAt(0, elapsed),
        isNot(const AuraDrift().offsetAt(1, elapsed)),
      );
      expect(
        const AuraDrift().offsetAt(0, elapsed),
        isNot(const AuraDrift(seed: 1).offsetAt(0, elapsed)),
      );
    });

    test('supports value equality', () {
      const drift = AuraDrift(amplitude: 0.1, seed: 3);
      // Not const, to compare two distinct instances.
      // ignore: prefer_const_constructors
      final same = AuraDrift(amplitude: 0.1, seed: 3);

      expect(drift, same);
      expect(drift.hashCode, same.hashCode);
      expect(drift == drift, isTrue);
      expect(drift, isNot(const AuraDrift(amplitude: 0.1)));
      expect(drift, isNot(const AuraDrift(amplitude: 0.1, seed: 4)));
      expect(
        drift,
        isNot(
          const AuraDrift(
            amplitude: 0.1,
            seed: 3,
            period: Duration(seconds: 1),
          ),
        ),
      );
      expect(drift, isNot('a drift'));
    });

    test('describes itself', () {
      expect(
        const AuraDrift().toString(),
        'AuraDrift(amplitude: 0.2, period: 0:00:12.000000, seed: 0)',
      );
    });
  });
}
