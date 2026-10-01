# Aura Box

[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![License: MIT][license_badge]][license_link]

![AuraBox preview: five boxes filled with blurred radial gradient spots](https://raw.githubusercontent.com/GangemiLorenzo/aura_box/main/doc/aura_box_preview.png)

Flutter widget for aura-style backgrounds. Compose multiple blurred radial
gradient spots inside a box to create soft, glowing, mesh-like gradients.

[pub_badge]: https://img.shields.io/pub/v/aura_box.svg
[pub_link]: https://pub.dev/packages/aura_box
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[patrol_finders_badge]: https://img.shields.io/badge/test-patrol_finders-yellow
[patrol_finders_link]: https://pub.dev/packages/patrol_finders

## Installation

Add the package with the Flutter CLI:

```sh
flutter pub add aura_box
```

Or add it to your `pubspec.yaml` manually:

```yaml
dependencies:
  aura_box: ^1.1.0
```

Then import it:

```dart
import 'package:aura_box/aura_box.dart';
```

## Usage

Wrap any widget in an `AuraBox` and give it a list of `AuraSpot`s:

```dart
AuraBox(
  spots: [
    // A blue spot in the center.
    AuraSpot(
      color: Colors.blue,
      radius: 100,
      alignment: Alignment.center,
      blurRadius: 5,
      stops: const [0.0, 0.5],
    ),
    // A red spot in the bottom right corner.
    AuraSpot(
      color: Colors.red,
      radius: 150,
      alignment: Alignment.bottomRight,
      blurRadius: 10,
      stops: const [0.0, 0.7],
    ),
  ],
  decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(10),
  ),
  child: const SizedBox(height: 100, width: 100),
)
```

![AuraBox with a blue and a red spot](https://github.com/GangemiLorenzo/aura_box/assets/26723808/974cfc39-28be-4942-bbab-95d942a5917a)

## API overview

### `AuraBox`

A container that paints a stack of `AuraSpot`s behind its `child`.

| Parameter    | Type              | Required | Description                                                                                                                         |
| ------------ | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `spots`      | `List<AuraSpot>`  | yes      | The spots to paint, layered in list order.                                                                                          |
| `child`      | `Widget`          | yes      | The content painted on top of the spots. It also gives the box its size.                                                            |
| `decoration` | `BoxDecoration?`  | no       | Background decoration of the box. A `borderRadius` or `BoxShape.circle` also clips the spots, so they never paint outside the shape. |

### `AuraSpot`

A single radial gradient spot with an optional blur.

| Parameter    | Type           | Required | Default      | Description                                                              |
| ------------ | -------------- | -------- | ------------ | ------------------------------------------------------------------------ |
| `color`      | `Color`        | yes      |              | The color at the center of the spot. It fades to transparent at the edge. |
| `radius`     | `double`       | yes      |              | The radius of the radial gradient, in logical pixels.                     |
| `alignment`  | `Alignment`    | yes      |              | The position of the spot center inside the box.                           |
| `blurRadius` | `double`       | no       | `0`          | The blur intensity applied to the spot.                                   |
| `stops`      | `List<double>` | no       | `[0.0, 1.0]` | The gradient distribution. Must contain exactly 2 values.                 |

### Alignment

The spots are positioned inside a `Stack` with the `alignment` property.
Values outside the `-1.0..1.0` range place the spot center outside the box,
which is useful for soft glows that enter from an edge.

For more details, see the [Alignment class documentation](https://api.flutter.dev/flutter/painting/Alignment-class.html).

## Example

The [`example/`](https://github.com/GangemiLorenzo/aura_box/tree/main/example) folder contains a complete app with several presets and a light/dark toggle:

```sh
cd example
flutter run
```

![Example app](https://github.com/GangemiLorenzo/aura_box/assets/26723808/c5852f3a-b85d-4c2d-8e97-57016712c5ea)

---

Made by [Lorenzo Gangemi](https://lorenzogangemi.com)
