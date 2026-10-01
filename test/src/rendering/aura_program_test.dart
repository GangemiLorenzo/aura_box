import 'dart:ui' as ui;

import 'package:aura_box/src/rendering/aura_program.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuraProgram', () {
    test('has no program before loading', () {
      expect(AuraProgram().program, isNull);
    });

    test('loads the shader of the package and notifies', () async {
      final program = AuraProgram();
      var notifications = 0;
      program.addListener(() => notifications++);

      await program.ensureLoaded();

      expect(program.program, isNotNull);
      expect(notifications, 1);
    });

    test('tries the asset keys in order', () async {
      final keys = <String>[];
      final program = AuraProgram(
        loader: (key) {
          keys.add(key);
          if (key == AuraProgram.assetKeys.first) {
            throw Exception('Not found');
          }
          return ui.FragmentProgram.fromAsset(key);
        },
      );

      await program.ensureLoaded();

      expect(keys, AuraProgram.assetKeys);
      expect(program.program, isNotNull);
    });

    test('loads only once', () async {
      var calls = 0;
      final program = AuraProgram(
        loader: (key) {
          calls++;
          return ui.FragmentProgram.fromAsset('shaders/aura.frag');
        },
      );

      final first = program.ensureLoaded();
      final second = program.ensureLoaded();
      await first;

      expect(second, same(first));
      expect(calls, 1);
    });

    test('keeps no program and does not throw when loading fails', () async {
      final program = AuraProgram(
        loader: (key) async => throw Exception('Not found'),
      );
      var notifications = 0;
      program.addListener(() => notifications++);

      await program.ensureLoaded();

      expect(program.program, isNull);
      expect(notifications, 0);
    });
  });
}
