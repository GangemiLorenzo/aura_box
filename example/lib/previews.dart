import 'package:aura_box/aura_box.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter/widgets.dart';

import 'presets.dart';

/// Widget previews. Run `flutter widget-preview start` in this folder.
@Preview(name: 'AuraBox', size: Size(300, 360))
Widget auraBoxPreview() {
  return AuraBox(
    spots: presets.first.spots,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  );
}

@Preview(name: 'AuraBox with grain and drift', size: Size(300, 360))
Widget auraBoxMotionPreview() {
  return AuraBox(
    spots: presets.last.spots,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    grain: 0.15,
    drift: const AuraDrift(),
  );
}
