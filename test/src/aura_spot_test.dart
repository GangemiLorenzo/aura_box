import 'package:aura_box/aura_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _blue = Color(0xFF0000FF);
const _red = Color(0xFFFF0000);

void main() {
  group('AuraSpot', () {
    test('can be const and has sensible defaults', () {
      const spot = AuraSpot(color: _blue, radius: 100);

      expect(spot.alignment, Alignment.center);
      expect(spot.blurRadius, 0);
      expect(spot.stops, [0.0, 1.0]);
    });

    test('rejects a negative radius or blur radius', () {
      expect(() => AuraSpot(color: _blue, radius: -1), throwsAssertionError);
      expect(
        () => AuraSpot(color: _blue, radius: 1, blurRadius: -1),
        throwsAssertionError,
      );
    });

    test('exposes the inner and outer radius in logical pixels', () {
      const spot = AuraSpot(color: _blue, radius: 200, stops: [0.25, 0.5]);

      expect(spot.innerRadius, 50);
      expect(spot.outerRadius, 100);
    });

    test('debugAssertIsValid accepts two ascending stops', () {
      const spot = AuraSpot(color: _blue, radius: 100, stops: [0.2, 0.9]);

      expect(spot.debugAssertIsValid(), isTrue);
    });

    test('debugAssertIsValid rejects a wrong number of stops', () {
      const spot = AuraSpot(color: _blue, radius: 100, stops: [0, 0.5, 1]);

      expect(spot.debugAssertIsValid, throwsAssertionError);
    });

    test('debugAssertIsValid rejects stops out of order or out of range', () {
      const descending = AuraSpot(color: _blue, radius: 100, stops: [0.8, 0.2]);
      const tooLarge = AuraSpot(color: _blue, radius: 100, stops: [0, 1.5]);

      expect(descending.debugAssertIsValid, throwsAssertionError);
      expect(tooLarge.debugAssertIsValid, throwsAssertionError);
    });

    test('copyWith replaces only the given fields', () {
      const spot = AuraSpot(color: _blue, radius: 100, blurRadius: 5);

      expect(spot.copyWith(), spot);
      expect(
        spot.copyWith(
          color: _red,
          radius: 50,
          alignment: Alignment.topLeft,
          blurRadius: 1,
          stops: [0.1, 0.9],
        ),
        const AuraSpot(
          color: _red,
          radius: 50,
          alignment: Alignment.topLeft,
          blurRadius: 1,
          stops: [0.1, 0.9],
        ),
      );
    });

    test('scale multiplies the opacity', () {
      const spot = AuraSpot(color: Color(0x800000FF), radius: 100);

      final scaled = spot.scale(0.5);

      expect(scaled.color.a, closeTo(0.25, 0.01));
      expect(scaled.radius, 100);
    });

    group('lerp', () {
      const a = AuraSpot(
        color: _blue,
        radius: 100,
        alignment: Alignment.topLeft,
        stops: [0, 0.5],
      );
      const b = AuraSpot(
        color: _red,
        radius: 200,
        alignment: Alignment.bottomRight,
        blurRadius: 20,
      );

      test('returns the same instance for identical spots', () {
        expect(AuraSpot.lerp(a, a, 0.3), same(a));
        expect(AuraSpot.lerp(null, null, 0.3), isNull);
      });

      test('interpolates every field', () {
        final middle = AuraSpot.lerp(a, b, 0.5)!;

        expect(middle.color, Color.lerp(_blue, _red, 0.5));
        expect(middle.radius, 150);
        expect(middle.alignment, Alignment.center);
        expect(middle.blurRadius, 10);
        expect(middle.stops, [0.0, 0.75]);
      });

      test('fades a spot in from null', () {
        final spot = AuraSpot.lerp(null, b, 0.25)!;

        expect(spot.color.a, closeTo(0.25, 0.01));
        expect(spot.radius, b.radius);
      });

      test('fades a spot out to null', () {
        final spot = AuraSpot.lerp(a, null, 0.25)!;

        expect(spot.color.a, closeTo(0.75, 0.01));
        expect(spot.radius, a.radius);
      });
    });

    group('lerpList', () {
      const a = AuraSpot(color: _blue, radius: 100);
      const b = AuraSpot(color: _red, radius: 200);

      test('matches spots by index', () {
        final list = AuraSpot.lerpList([a], [b], 0.5);

        expect(list, [AuraSpot.lerp(a, b, 0.5)]);
      });

      test('fades extra spots in and out', () {
        final growing = AuraSpot.lerpList([a], [a, b], 0.5);
        final shrinking = AuraSpot.lerpList([a, b], [a], 0.5);

        expect(growing, hasLength(2));
        expect(growing[1].color.a, closeTo(0.5, 0.01));
        expect(shrinking, hasLength(2));
        expect(shrinking[1].color.a, closeTo(0.5, 0.01));
      });

      test('treats null as an empty list', () {
        expect(AuraSpot.lerpList(null, null, 0.5), isEmpty);
        expect(AuraSpot.lerpList(null, [a], 1), [a]);
      });
    });

    test('supports value equality', () {
      const spot = AuraSpot(color: _blue, radius: 100, stops: [0.1, 0.9]);
      // The stops are compared by content, not by identity.
      // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
      final same = AuraSpot(color: _blue, radius: 100, stops: [0.1, 0.9]);

      expect(spot, same);
      expect(spot.hashCode, same.hashCode);
      expect(spot, isNot(spot.copyWith(radius: 101)));
      expect(spot, isNot(spot.copyWith(stops: [0.2, 0.9])));
      expect(spot == spot, isTrue);
      expect(spot, isNot('a spot'));
    });

    test('describes itself', () {
      const spot = AuraSpot(color: _blue, radius: 100, blurRadius: 5);
      final builder = DiagnosticPropertiesBuilder();

      spot.debugFillProperties(builder);

      expect(builder.properties.map((property) => property.name), [
        'color',
        'radius',
        'alignment',
        'blurRadius',
        'stops',
      ]);
      expect(spot.toString(), contains('AuraSpot'));
    });
  });
}
