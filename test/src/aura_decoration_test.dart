import 'package:aura_box/aura_box.dart';
import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

const _blue = Color(0xFF0000FF);
const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _transparent = Color(0x00000000);

const _spot = AuraSpot(color: _blue, radius: 20, stops: [0.9, 1]);

Widget _box(Decoration decoration) {
  return DecoratedBox(
    decoration: decoration,
    child: const SizedBox(width: 100, height: 100),
  );
}

void main() {
  final original = AuraProgram.instance;
  setUp(useFallback);
  tearDown(() => AuraProgram.instance = original);

  group('AuraDecoration', () {
    test('rejects a border radius on a circle', () {
      expect(
        () => AuraDecoration(
          spots: const [],
          shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(4),
        ),
        throwsAssertionError,
      );
    });

    test('rejects a grain out of range', () {
      expect(
        () => AuraDecoration(spots: const [], grain: 1.5),
        throwsAssertionError,
      );
    });

    test('is complex', () {
      expect(const AuraDecoration(spots: []).isComplex, isTrue);
    });

    test('scale multiplies the opacity of the spots and of the color', () {
      final scaled = const AuraDecoration(
        spots: [_spot],
        color: _red,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        grain: 0.4,
      ).scale(0.5);

      expect(scaled.spots.single.color.a, closeTo(0.5, 0.01));
      expect(scaled.color!.a, closeTo(0.5, 0.01));
      expect(scaled.borderRadius, const BorderRadius.all(Radius.circular(5)));
      expect(scaled.grain, 0.2);
    });

    group('lerp', () {
      const a = AuraDecoration(
        spots: [_spot],
        color: _red,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      );
      const b = AuraDecoration(
        spots: [AuraSpot(color: _green, radius: 40)],
        color: _blue,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        grain: 1,
      );
      const circle = AuraDecoration(spots: [_spot], shape: BoxShape.circle);

      test('returns the ends untouched', () {
        expect(AuraDecoration.lerp(a, a, 0.5), same(a));
        expect(AuraDecoration.lerp(null, null, 0.5), isNull);
        expect(AuraDecoration.lerp(a, b, 0), same(a));
        expect(AuraDecoration.lerp(a, b, 1), same(b));
      });

      test('interpolates every field', () {
        final middle = AuraDecoration.lerp(a, b, 0.5)!;

        expect(middle.spots.single.radius, 30);
        expect(middle.color, Color.lerp(_red, _blue, 0.5));
        expect(
          middle.borderRadius,
          const BorderRadius.all(Radius.circular(20)),
        );
        expect(middle.grain, 0.5);
      });

      test('fades in from null and out to null', () {
        expect(AuraDecoration.lerp(null, a, 0.25), a.scale(0.25));
        expect(AuraDecoration.lerp(a, null, 0.25), a.scale(0.75));
      });

      test('switches the shape at the midpoint', () {
        final before = AuraDecoration.lerp(a, circle, 0.4)!;
        final after = AuraDecoration.lerp(a, circle, 0.6)!;

        expect(before.shape, BoxShape.rectangle);
        expect(before.borderRadius, isNotNull);
        expect(after.shape, BoxShape.circle);
        expect(after.borderRadius, isNull);
      });

      test('works through lerpFrom and lerpTo', () {
        expect(b.lerpFrom(a, 0.5), AuraDecoration.lerp(a, b, 0.5));
        expect(a.lerpTo(b, 0.5), AuraDecoration.lerp(a, b, 0.5));
      });

      test('works through Decoration.lerp', () {
        expect(Decoration.lerp(a, b, 0.5), AuraDecoration.lerp(a, b, 0.5));
        expect(Decoration.lerp(null, a, 0.25), a.scale(0.25));
        expect(Decoration.lerp(a, null, 0.25), a.scale(0.75));
      });

      test('cross-fades with a decoration of another type', () {
        const other = BoxDecoration(color: _green);

        // No direct interpolation: Decoration.lerp fades the first one out,
        // then the second one in.
        expect(a.lerpFrom(other, 0.5), isNull);
        expect(a.lerpTo(other, 0.5), isNull);
        expect(Decoration.lerp(a, other, 0.2), a.scale(1 - 0.2 * 2));
        expect(Decoration.lerp(other, a, 0.8), a.scale((0.8 - 0.5) * 2));
      });
    });

    group('getClipPath', () {
      const rect = Rect.fromLTWH(0, 0, 100, 50);

      test('is the rect for a rectangle', () {
        final path = const AuraDecoration(
          spots: [],
        ).getClipPath(rect, TextDirection.ltr);

        expect(path.contains(const Offset(1, 1)), isTrue);
        expect(path.getBounds(), rect);
      });

      test('is rounded with a border radius', () {
        final path = const AuraDecoration(
          spots: [],
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ).getClipPath(rect, TextDirection.ltr);

        expect(path.contains(const Offset(1, 1)), isFalse);
        expect(path.contains(const Offset(50, 25)), isTrue);
      });

      test('is the inscribed circle for a circle', () {
        final path = const AuraDecoration(
          spots: [],
          shape: BoxShape.circle,
        ).getClipPath(rect, TextDirection.ltr);

        expect(path.getBounds(), const Rect.fromLTWH(25, 0, 50, 50));
      });
    });

    test('hitTest follows the shape', () {
      const decoration = AuraDecoration(spots: [], shape: BoxShape.circle);
      const size = Size(100, 100);

      expect(decoration.hitTest(size, const Offset(50, 50)), isTrue);
      expect(decoration.hitTest(size, const Offset(2, 2)), isFalse);
      expect(
        decoration.hitTest(
          size,
          const Offset(50, 50),
          textDirection: TextDirection.rtl,
        ),
        isTrue,
      );
    });

    test('supports value equality', () {
      const decoration = AuraDecoration(spots: [_spot], color: _red);
      // The spots are compared by content, not by identity.
      final same = AuraDecoration(spots: [_spot.copyWith()], color: _red);

      expect(decoration, same);
      expect(decoration.hashCode, same.hashCode);
      expect(decoration == decoration, isTrue);
      expect(decoration, isNot(const AuraDecoration(spots: [_spot])));
      expect(decoration, isNot(const AuraDecoration(spots: [], color: _red)));
      expect(
        decoration,
        isNot(const AuraDecoration(spots: [_spot], color: _red, grain: 0.1)),
      );
      expect(
        decoration,
        isNot(
          const AuraDecoration(
            spots: [_spot],
            color: _red,
            shape: BoxShape.circle,
          ),
        ),
      );
      expect(
        decoration,
        isNot(
          const AuraDecoration(
            spots: [_spot],
            color: _red,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      );
      expect(decoration, isNot(const BoxDecoration(color: _red)));
    });

    test('describes itself', () {
      final builder = DiagnosticPropertiesBuilder();

      const AuraDecoration(spots: [_spot]).debugFillProperties(builder);

      expect(builder.properties.map((property) => property.name), [
        'spots',
        'color',
        'borderRadius',
        'shape',
        'grain',
      ]);
    });

    testWidgets('paints the spots over the color', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        _box(const AuraDecoration(spots: [_spot], color: _red)),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(2, 2), _red);
    });

    testWidgets('paints without a color', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        _box(const AuraDecoration(spots: [_spot])),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(2, 2), _transparent);
    });

    testWidgets('cuts the color to a circle', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        _box(
          const AuraDecoration(
            spots: [_spot],
            color: _red,
            shape: BoxShape.circle,
          ),
        ),
      );

      expectColor(pixels.at(50, 50), _blue);
      expectColor(pixels.at(50, 5), _red);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testWidgets('cuts the color to a border radius', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        _box(
          const AuraDecoration(
            spots: [_spot],
            color: _red,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
      );

      expectColor(pixels.at(50, 2), _red);
      expectColor(pixels.at(3, 3), _transparent);
    });

    testWidgets('paints at the offset of the box', (tester) async {
      final pixels = await pumpAndCapture(
        tester,
        Padding(
          padding: const EdgeInsets.only(left: 100),
          child: _box(const AuraDecoration(spots: [_spot])),
        ),
      );

      expectColor(pixels.at(150, 50), _blue);
      expectColor(pixels.at(50, 50), _transparent);
    });

    testWidgets('animates inside an AnimatedContainer', (tester) async {
      Widget build(Color color) {
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: 100,
          height: 100,
          decoration: AuraDecoration(
            spots: [
              AuraSpot(color: color, radius: 500, stops: const [0.9, 1]),
            ],
          ),
        );
      }

      await pumpAndCapture(tester, build(_blue));
      final key = find.byType(RepaintBoundary).evaluate().first.widget.key!;
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(key: key, child: build(_red)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      final pixels = await capture(tester, key as GlobalKey);

      expectColor(pixels.at(50, 50), Color.lerp(_blue, _red, 0.5)!);
    });

    testWidgets('repaints when the shader becomes available', (tester) async {
      AuraProgram.instance = AuraProgram();
      var changes = 0;
      final painter = const AuraDecoration(
        spots: [_spot],
      ).createBoxPainter(() => changes++);

      await tester.runAsync(AuraProgram.instance.ensureLoaded);
      expect(changes, 1);

      painter.dispose();
      AuraProgram.instance.notifyListeners();
      expect(changes, 1);
    });

    test('creates a painter without a change callback', () {
      const AuraDecoration(spots: [_spot]).createBoxPainter().dispose();
    });
  });
}
