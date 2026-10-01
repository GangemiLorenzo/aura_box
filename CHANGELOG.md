# v2.0.0 (2.0.0)

A full rewrite of the rendering. Every spot of a box is now painted by a single fragment shader pass, on every platform.

### Breaking
- `AuraSpot` is immutable data, not a widget. Its `key` parameter is gone.
- `blurRadius` is a true Gaussian blur. A blur that is large compared to the `radius` now lowers the intensity of the spot. In 1.x the blur was cut at the edges of the box.
- The `child` of an `AuraBox` gets the constraints of the box, like the child of a `DecoratedBox`. In 1.x it sat in a `Stack` with loose constraints.
- Require Dart `^3.12.0` and Flutter `>=3.44.0`.

### Added
- `AnimatedAuraBox`: implicit animation of spots, decoration and grain.
- `AuraDecoration`: an aura as a `Decoration`, with `lerp` support for `AnimatedContainer` and `DecorationTween`.
- `AuraDrift` and `AuraBox.drift`: a slow, continuous movement of the spots. It respects the reduced motion setting.
- `grain`: an optional film grain.
- `AuraSpot.lerp`, `AuraSpot.lerpList`, `AuraSpot.copyWith`, `AuraSpot.scale` and value equality.
- `AuraBox.precache()` to load the shader before the first frame.
- `AuraSpot.alignment` accepts any `AlignmentGeometry` and defaults to `Alignment.center`.
- `AuraBox.child` is optional. Without a child the box fills its parent.
- `AuraSpot` can be `const`.

### Changed
- One draw call for every 8 spots, instead of two offscreen images, a layer and a clip per spot.
- The output is dithered: no banding in soft gradients.
- Spots are sharp at any device pixel ratio.
- The library imports `package:flutter/widgets.dart` only. No Material dependency.
- The example app shows the new features and uses the standalone `material_ui` package.

### Maintenance
- First published version since 1.0.2 (1.0.3 and 1.0.4 were tagged in the repository but never published to pub.dev).
- Set `homepage` to https://lorenzogangemi.com and add `repository` and `issue_tracker` links.
- Add pub.dev `topics` and a `screenshots` entry, and rewrite the package `description`.
- Upgrade dev dependencies: `very_good_analysis` ^11.0.0, `patrol_finders` ^3.6.0.
- Rewrite the README: new preview image, usage of every feature, API overview and migration notes.

### Fixed
- `Invalid image dimensions` exception when the box has a zero or sub-pixel size.
- Images, pictures and shaders that were never disposed.
- The spots were rebuilt on every paint of the box.
- `AuraBox` needed a `Directionality` ancestor.

# v1.0.3 (1.0.3)

Updated the dependencies in pubspec.yaml

# v1.0.2 (1.0.2)

### Added
- `patrol_finder` dependency
- widget testing
- CI improvements

# v1.0.1 (1.0.1)

Updated the README and `pubspec.yaml` file

# v1.0.0 (1.0.0)

### Added
- `AuraBox` widget.
- `AuraSpot` widget.

### Functionalities
- Compose multiple radial gradients in a stack way using the `alignment` property for positioning.
- Apply blur effect over each `AuraSpot` using the `blurRadius` property.
