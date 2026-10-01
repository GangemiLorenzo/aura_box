import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes every aura use the gradient fallback: the shader never loads.
void useFallback() {
  AuraProgram.instance = AuraProgram(
    loader: (key) async => throw Exception('No shader in this test'),
  );
}

/// Makes every aura use the real fragment shader, loaded before the test
/// pumps its first frame.
Future<void> useShader(WidgetTester tester) async {
  AuraProgram.instance = AuraProgram();
  await tester.runAsync(AuraProgram.instance.ensureLoaded);
  expect(AuraProgram.instance.program, isNotNull);
}

/// The pixels of a rendered widget, stored premultiplied.
class Pixels {
  Pixels(this.width, this.height, this._data);

  final int width;
  final int height;
  final ByteData _data;

  /// The straight (not premultiplied) color at the given pixel.
  Color at(int x, int y) {
    final offset = (y * width + x) * 4;
    final alpha = _data.getUint8(offset + 3);
    if (alpha == 0) {
      return const Color(0x00000000);
    }
    int straight(int channel) =>
        (_data.getUint8(offset + channel) * 255 / alpha).round().clamp(0, 255);
    return Color.fromARGB(alpha, straight(0), straight(1), straight(2));
  }

  /// The mean absolute difference per premultiplied channel against
  /// [other], 0 to 255.
  double difference(Pixels other) {
    expect(other.width, width);
    expect(other.height, height);
    var total = 0;
    for (var i = 0; i < _data.lengthInBytes; i++) {
      total += (_data.getUint8(i) - other._data.getUint8(i)).abs();
    }
    return total / _data.lengthInBytes;
  }
}

/// Pumps [widget] inside a repaint boundary and reads its pixels back at one
/// device pixel per logical pixel.
Future<Pixels> pumpAndCapture(WidgetTester tester, Widget widget) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(key: key, child: widget),
    ),
  );
  return await capture(tester, key);
}

/// Reads the pixels of the repaint boundary with the given [key].
Future<Pixels> capture(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  late ui.Image image;
  late ByteData data;
  await tester.runAsync(() async {
    image = await boundary.toImage();
    data = (await image.toByteData())!;
  });
  final pixels = Pixels(image.width, image.height, data);
  image.dispose();
  return pixels;
}

/// Expects [actual] to match [expected] within [tolerance] per channel, on a
/// 0 to 255 scale.
void expectColor(Color actual, Color expected, {int tolerance = 3}) {
  int channel(double value) => (value * 255).round();
  final reason = 'Expected $expected, got $actual';
  expect(
    channel(actual.a),
    closeTo(channel(expected.a), tolerance),
    reason: reason,
  );
  // The color of a transparent pixel has no meaning.
  if (channel(expected.a) == 0) {
    return;
  }
  expect(
    channel(actual.r),
    closeTo(channel(expected.r), tolerance),
    reason: reason,
  );
  expect(
    channel(actual.g),
    closeTo(channel(expected.g), tolerance),
    reason: reason,
  );
  expect(
    channel(actual.b),
    closeTo(channel(expected.b), tolerance),
    reason: reason,
  );
}
