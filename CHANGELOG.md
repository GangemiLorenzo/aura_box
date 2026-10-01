# v1.1.0 (1.1.0)

Maintenance release. No public API changes. First published version since 1.0.2 (1.0.3 and 1.0.4 were tagged in the repository but never published to pub.dev).

### Changed
- Require Dart `^3.8.0` and Flutter `>=3.32.0` (minimum SDK raised, hence the minor version bump).
- Set `homepage` to https://lorenzogangemi.com and add `repository` and `issue_tracker` links.
- Add pub.dev `topics` and a `screenshots` entry.
- Rewrite the package `description` to improve discoverability.
- Upgrade dev dependencies: `very_good_analysis` ^11.0.0, `patrol_finders` ^3.6.0.
- Use the latest `very_good_analysis` rule set and fix all new lints.
- Format the code with the current Dart formatter.
- Upgrade the example app (`flutter_lints` ^6.0.0, `cupertino_icons` ^2.0.0, current Flutter platform migrations).

### Documentation
- Add a preview image at the top of the README.
- Add install, usage and API overview sections for `AuraBox` and `AuraSpot`.

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
