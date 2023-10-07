# Aura Box

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Flutter widget that combines multiple radial gradients and blur effect.

![Aura box banner image](https://github.com/GangemiLorenzo/aura_box/assets/26723808/16a43670-17df-4515-8a57-29f17b94607b)


[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis


## Installation

Add this line into the project `pubspec.yaml` file.

```yaml
dependencies:
    aura_box: ^1.0.0
```

Then in your files you can import it:

```dart
import 'package:aura_box/aura_box.dart';
```


## Usage

The package exposes two widgets.
- `AuraBox` acts as a container which can receive a `child`, a `decoration` and a list of `AuraSpot`.
- `AuraSpot` represent the point where the radiant gradients are generated.

```dart
AuraBox(
    spots: [
        // Places one blue spot in the center
        AuraSpot(
            color: Colors.blue,
            radius: 100.0,
            alignment: Alignment.center,
            blurRadius: 5.0,
            stops: const [0.0, 0.5],
        ),
        // Places one red spot in the bottom right
        AuraSpot(
            color: Colors.red,
            radius: 150.0,
            alignment: Alignment.bottomRight,
            blurRadius: 10.0,
            stops: const [0.0, 0.7],
        ),
    ],
    decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
    ),
    child: const SizedBox(
        height: 100,
        width: 100,
    ),
)
```

![](https://github.com/GangemiLorenzo/aura_box/assets/26723808/974cfc39-28be-4942-bbab-95d942a5917a)

### Alignment

The single spots are positioned inside a stack widget.
This gives control over their position using the `alignment` property.

For further details you can refer to the [Alignment class documentation](https://api.flutter.dev/flutter/painting/Alignment-class.html).

## Example

An example project is available within the project:

![example](https://github.com/GangemiLorenzo/aura_box/assets/26723808/c5852f3a-b85d-4c2d-8e97-57016712c5ea)






