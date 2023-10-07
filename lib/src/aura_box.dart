import 'package:aura_box/src/aura_spot.dart';
import 'package:flutter/material.dart';

/// A widget that combines multiple [AuraSpot] widgets and a child widget in a
/// stack with optional decoration.
class AuraBox extends StatelessWidget {
  /// The [AuraBox] widget allows you to create a stack of [AuraSpot] widgets
  /// with an optional decoration, along with a child widget. It is useful for
  /// creating complex visual effects by layering multiple [AuraSpot] widgets on
  /// top of each other and adding a background decoration.
  ///
  /// To use this widget, provide the required parameters: [child] and [spots],
  /// and optionally customize the [decoration].
  ///
  /// Example usage:
  ///
  /// ```dart
  /// AuraBox(
  ///   child: SizedBox(
  ///      height: 100,
  ///      width: 100,
  ///   ),
  ///   spots: [
  ///     AuraSpot(
  ///       color: Colors.blue,
  ///       radius: 100.0,
  ///       alignment: Alignment.center,
  ///       blurRadius: 5.0,
  ///       stops: [0.0, 0.5],
  ///     ),
  ///     AuraSpot(
  ///       color: Colors.red,
  ///       radius: 150.0,
  ///       alignment: Alignment.bottomRight,
  ///       blurRadius: 10.0,
  ///       stops: [0.0, 0.7],
  ///     ),
  ///   ],
  ///   decoration: BoxDecoration(
  ///     color: Colors.transparent,
  ///     shape: BoxShape.rectangle,
  ///     borderRadius: BorderRadius.circular(10.0),
  ///   ),
  /// )
  /// ```
  ///
  /// The [child] parameter is the primary content of the stack and is typically
  /// used to display other widgets.
  ///
  /// The [spots] parameter is a list of [AuraSpot] widgets that will be
  /// layered on top of each other within the stack.
  ///
  /// The [decoration] parameter allows you to specify the background decoration
  /// of the [AuraBox]. It can be used to add background colors, shapes, and
  /// borders to the stack.
  const AuraBox({
    required this.child,
    required this.spots,
    this.decoration,
    super.key,
  });

  /// The content that goes in the higher position of the stack
  final Widget child;

  /// A list of [AuraSpot] widgets that will be rendered in the box
  final List<AuraSpot> spots;

  /// Container decoration
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: Stack(
        children: [
          ...spots.map(
            (spot) => Positioned.fill(
              child: _clipWithBoxDecoration(
                decoration: decoration,
                child: spot,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _clipWithBoxDecoration({
    required Widget child,
    BoxDecoration? decoration,
  }) {
    if (decoration?.shape == BoxShape.circle) {
      return ClipOval(child: child);
    }
    if (decoration?.borderRadius != null) {
      return ClipRRect(
        borderRadius: decoration!.borderRadius!,
        child: child,
      );
    }

    return child;
  }
}
