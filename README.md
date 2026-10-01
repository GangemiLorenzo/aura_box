# Aura Box

[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![License: MIT][license_badge]][license_link]

![AuraBox preview: five boxes filled with blurred radial gradient spots](https://raw.githubusercontent.com/GangemiLorenzo/aura_box/main/doc/aura_box_preview.png)

Flutter widget for aura-style backgrounds. Compose multiple blurred radial
gradient spots inside a box to create soft, glowing, mesh-like gradients.

- **One draw call.** Every spot is painted by a single fragment shader pass.
  No offscreen images, no blur passes, no extra layers per spot.
- **Animatable.** Spots are plain data with `lerp`. Use `AnimatedAuraBox`, an
  `AnimatedContainer` with an `AuraDecoration`, or your own controller.
- **Alive.** An optional drift moves the spots slowly. An optional film grain
  adds texture.
- **Everywhere.** Android, iOS, macOS, Windows, Linux and web, on Impeller and
  on Skia, with the same look.
- **No dependencies** besides Flutter.

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
  aura_box: ^2.0.0
```

Then import it:

```dart
import 'package:aura_box/aura_box.dart';
```

Version 2 needs Flutter 3.44 or newer. Coming from 1.x? See
[Migrating from 1.x](#migrating-from-1x).

## Usage

Wrap any widget in an `AuraBox` and give it a list of `AuraSpot`s:

```dart
AuraBox(
  spots: const [
    // A blue spot in the center.
    AuraSpot(
      color: Colors.blue,
      radius: 100,
      alignment: Alignment.center,
      blurRadius: 5,
      stops: [0.0, 0.5],
    ),
    // A red spot in the bottom right corner.
    AuraSpot(
      color: Colors.red,
      radius: 150,
      alignment: Alignment.bottomRight,
      blurRadius: 10,
      stops: [0.0, 0.7],
    ),
  ],
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  ),
  child: const SizedBox(height: 100, width: 100),
)
```

The box takes the size of its child. Without a child it fills its parent, so
it also works as a page background:

```dart
Stack(
  children: [
    const Positioned.fill(child: AuraBox(spots: spots)),
    content,
  ],
)
```

### Animate between auras

`AnimatedAuraBox` animates every change of its spots, decoration and grain.
Spots are matched by index. A spot without a match fades in or out.

```dart
AnimatedAuraBox(
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  spots: selected ? warmSpots : coldSpots,
  child: const SizedBox(height: 200),
)
```

For full control, interpolate yourself with `AuraSpot.lerp` or
`AuraSpot.lerpList`.

### Use it as a decoration

`AuraDecoration` paints an aura wherever Flutter accepts a `Decoration`. Two
aura decorations interpolate, so an `AnimatedContainer` animates them:

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 600),
  width: expanded ? 320 : 160,
  height: 160,
  decoration: AuraDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(24),
    spots: expanded ? warmSpots : coldSpots,
  ),
)
```

### Drift

Give the box a drift and every spot wanders slowly around its alignment:

```dart
AuraBox(
  spots: spots,
  drift: const AuraDrift(
    amplitude: 0.2, // in alignment units
    period: Duration(seconds: 12),
  ),
)
```

The motion is deterministic: the same `seed` gives the same paths. It stops
when the platform asks for reduced motion.

### Grain

A film grain over the spots, from `0.0` to `1.0`:

```dart
AuraBox(spots: spots, grain: 0.1)
```

### Skip the first fallback frame

The fragment shader loads asynchronously the first time an aura is painted.
Until it is ready, the spots are painted as plain gradients with the same
shape, without grain. To use the shader from the very first frame, load it
before `runApp`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuraBox.precache();
  runApp(const MyApp());
}
```

## API overview

### `AuraBox`

A box that paints a list of `AuraSpot`s behind its `child`.

| Parameter    | Type             | Default | Description                                                                                                                  |
| ------------ | ---------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `spots`      | `List<AuraSpot>` |         | Required. The spots to paint, layered in list order.                                                                          |
| `child`      | `Widget?`        | `null`  | The content painted on top of the spots. It gives the box its size. Without a child the box fills its parent.                  |
| `decoration` | `BoxDecoration?` | `null`  | Painted behind the spots. A `borderRadius` or `BoxShape.circle` also cuts the spots, so they never paint outside the shape.    |
| `grain`      | `double`         | `0`     | Film grain strength, `0.0` to `1.0`.                                                                                          |
| `drift`      | `AuraDrift?`     | `null`  | A slow, continuous movement of the spots.                                                                                     |

`AnimatedAuraBox` has the same parameters plus `duration`, `curve` and `onEnd`.

### `AuraSpot`

A single spot: a radial falloff of one color, optionally blurred. Immutable
data, not a widget.

| Parameter    | Type                | Default            | Description                                                                             |
| ------------ | ------------------- | ------------------ | --------------------------------------------------------------------------------------- |
| `color`      | `Color`             |                    | Required. The color at the center of the spot. It fades to transparent at the edge.      |
| `radius`     | `double`            |                    | Required. The radius of the spot, in logical pixels.                                     |
| `alignment`  | `AlignmentGeometry` | `Alignment.center` | The position of the spot center inside the box.                                         |
| `blurRadius` | `double`            | `0`                | The blur intensity: the standard deviation of a Gaussian, in logical pixels.            |
| `stops`      | `List<double>`      | `[0.0, 1.0]`       | Where the fade starts and ends, as fractions of the radius. Exactly 2 ascending values. |

### `AuraDecoration`

| Parameter      | Type                    | Default              | Description                               |
| -------------- | ----------------------- | -------------------- | ----------------------------------------- |
| `spots`        | `List<AuraSpot>`        |                      | Required. The spots to paint.             |
| `color`        | `Color?`                | `null`               | The color painted behind the spots.       |
| `borderRadius` | `BorderRadiusGeometry?` | `null`               | Rounds the corners of the painted area.   |
| `shape`        | `BoxShape`              | `BoxShape.rectangle` | The shape of the painted area.            |
| `grain`        | `double`                | `0`                  | Film grain strength, `0.0` to `1.0`.      |

### `AuraDrift`

| Parameter   | Type       | Default      | Description                                                             |
| ----------- | ---------- | ------------ | ----------------------------------------------------------------------- |
| `amplitude` | `double`   | `0.2`        | How far a spot moves from its alignment, in alignment units.             |
| `period`    | `Duration` | `12 seconds` | The time a spot takes to complete one loop, on average.                  |
| `seed`      | `int`      | `0`          | Selects a different set of paths.                                        |

### Alignment

A spot is positioned inside the box with its `alignment`. Values outside the
`-1.0..1.0` range place the spot center outside the box, which is useful for
soft glows that enter from an edge.

For more details, see the [Alignment class documentation](https://api.flutter.dev/flutter/painting/Alignment-class.html).

## How it works

All the spots of a box are painted by one fragment shader, in one pass. The
blur is not an image filter: the shader evaluates a closed-form approximation
of a Gaussian-blurred radial ramp for every pixel. That makes the cost
independent of the blur radius, keeps the result sharp at any pixel density,
and leaves nothing to cache or dispose.

A box with more than 8 spots uses one extra pass for every 8 spots.

The shader output is dithered, so soft gradients show no banding.

## Migrating from 1.x

Most 1.x code compiles unchanged. What is different:

- **`AuraSpot` is no longer a widget.** It is immutable data. Code that put an
  `AuraSpot` directly in a widget tree must wrap it in an `AuraBox`. The `key`
  parameter is gone.
- **`blurRadius` is a true Gaussian blur.** In 1.x the blur was cut at the
  edges of the box, so very large values kept the colors strong. Now a blur
  that is large compared to the `radius` spreads the color and lowers its
  intensity, like a real blur does. If a design looks paler than before, lower
  its `blurRadius`.
- **The child gets the constraints of the box.** In 1.x the child sat in a
  `Stack` with loose constraints. Now it is laid out like the child of a
  `DecoratedBox`.
- **`child` is optional** and `alignment` defaults to `Alignment.center`.
- **Minimum SDK:** Flutter 3.44, Dart 3.12.

## Example

The [`example/`](https://github.com/GangemiLorenzo/aura_box/tree/main/example) folder contains a complete app with presets, implicit animation, the decoration API and a playground for blur, grain and drift:

```sh
cd example
flutter run
```

---

Made by [Lorenzo Gangemi](https://lorenzogangemi.com)
