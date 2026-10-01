import 'package:aura_box/src/rendering/aura_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('auraErf', () {
    test('matches known values of the error function', () {
      expect(auraErf(0), closeTo(0, 1e-6));
      expect(auraErf(0.5), closeTo(0.5204999, 1e-6));
      expect(auraErf(1), closeTo(0.8427008, 1e-6));
      expect(auraErf(-1), closeTo(-0.8427008, 1e-6));
      expect(auraErf(3), closeTo(0.9999779, 1e-6));
    });
  });

  group('auraSoftRelu', () {
    test('is max(x, 0) without blur', () {
      expect(auraSoftRelu(3, 0), closeTo(3, 1e-9));
      expect(auraSoftRelu(-3, 0), closeTo(0, 1e-9));
    });

    test('is sigma / sqrt(2 pi) at zero', () {
      expect(auraSoftRelu(0, 10), closeTo(3.9894228, 1e-6));
    });

    test('converges to max(x, 0) far from zero', () {
      expect(auraSoftRelu(100, 5), closeTo(100, 1e-6));
      expect(auraSoftRelu(-100, 5), closeTo(0, 1e-6));
    });
  });

  group('auraFalloff', () {
    test('is the exact linear ramp without blur', () {
      expect(auraFalloff(0, 20, 100, 0), 1);
      expect(auraFalloff(20, 20, 100, 0), closeTo(1, 1e-6));
      expect(auraFalloff(60, 20, 100, 0), closeTo(0.5, 1e-6));
      expect(auraFalloff(100, 20, 100, 0), closeTo(0, 1e-6));
      expect(auraFalloff(150, 20, 100, 0), 0);
    });

    test('matches the true blur at the center of a cone', () {
      // For a cone of radius R blurred by sigma, the exact center value is
      // 1 - sigma * sqrt(pi / 2) * erf(R / (sigma * sqrt(2))) / R.
      expect(auraFalloff(0, 0, 100, 10), closeTo(0.8747, 0.02));
      expect(auraFalloff(0, 0, 100, 50), closeTo(0.4018, 0.02));
      expect(auraFalloff(0, 0, 100, 100), closeTo(0.1444, 0.02));
    });

    test('decreases with the distance from the center', () {
      for (final sigma in [0.0, 5.0, 30.0, 100.0, 150.0]) {
        var previous = double.infinity;
        for (var distance = 0.0; distance <= 600; distance += 5) {
          final value = auraFalloff(distance, 30, 100, sigma);
          expect(value, lessThanOrEqualTo(previous + 1e-9));
          expect(value, inInclusiveRange(0, 1));
          previous = value;
        }
      }
    });

    test('is negligible three sigmas after the outer radius', () {
      expect(auraFalloff(100 + 3 * 40, 0, 100, 40), lessThan(0.005));
    });
  });
}
