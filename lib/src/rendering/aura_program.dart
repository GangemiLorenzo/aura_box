import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Loads a fragment program from an asset key.
typedef AuraProgramLoader = Future<ui.FragmentProgram> Function(String key);

/// Loads the aura fragment program once and shares it.
///
/// Listeners are notified when the program becomes available, so painters
/// can replace the fallback rendering with the shader.
final class AuraProgram extends ChangeNotifier {
  /// Creates a program holder that loads with [loader].
  ///
  /// Use [instance] in production code.
  @visibleForTesting
  AuraProgram({this.loader = ui.FragmentProgram.fromAsset});

  /// The program holder shared by every aura in the app.
  static AuraProgram instance = AuraProgram();

  /// The asset keys of the shader, in lookup order.
  ///
  /// The first key resolves when `aura_box` is a dependency. The second
  /// resolves inside the package itself, for example in its own tests.
  static const List<String> assetKeys = [
    'packages/aura_box/shaders/aura.frag',
    'shaders/aura.frag',
  ];

  /// Loads the program from an asset key.
  final AuraProgramLoader loader;

  Future<void>? _loading;

  /// The loaded program, or `null` while loading or after a failed load.
  ui.FragmentProgram? get program => _program;
  ui.FragmentProgram? _program;

  /// Starts loading the program if needed.
  ///
  /// The returned future completes when the load has finished, whether it
  /// succeeded or not. It never throws: when the shader cannot be loaded,
  /// [program] stays `null` and auras keep the fallback rendering.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    for (final key in assetKeys) {
      try {
        _program = await loader(key);
        notifyListeners();
        return;
      } on Object catch (_) {
        // Try the next key.
      }
    }
    debugPrint(
      'aura_box: the fragment shader could not be loaded. '
      'Using the gradient fallback.',
    );
  }
}
