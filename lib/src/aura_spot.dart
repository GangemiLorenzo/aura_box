import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A widget that creates a spot with a radial gradient and a blur effect.
class AuraSpot extends StatelessWidget {
  /// The [AuraSpot] widget creates a spot with a radial gradient that
  /// can be used to add various visual effects. It allows you to control
  /// the spot's color,
  /// radius, distribution of colors in the gradient, blur intensity,
  /// and position.
  ///
  /// To use this widget, provide the required parameters: [color], [radius],
  /// [alignment], and optionally customize the [blurRadius] and [stops] list.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// AuraSpot(
  ///   color: Colors.blue,
  ///   radius: 100.0,
  ///   alignment: Alignment.center,
  ///   blurRadius: 5.0,
  ///   stops: [0.0, 0.5],
  /// )
  /// ```
  ///
  /// The [color] parameter defines the gradient's starting color.
  ///
  /// The [radius] parameter specifies the radius of the radial gradient.
  ///
  /// The [alignment] parameter determines the spot's position using
  /// the [Alignment] class.
  ///
  /// The [blurRadius] parameter controls the intensity of the blur effect
  /// applied to the spot.
  ///
  /// The [stops] parameter defines the gradient distribution, and it must
  /// have a length equal to 2.
  ///
  /// The [AuraSpot] widget is typically used as a child of a [Stack] or other
  /// layout widgets to position and display the spot as needed.
  const AuraSpot({
    required this.color,
    required this.radius,
    required this.alignment,
    super.key,
    this.blurRadius = 0,
    this.stops = const [
      0.0,
      1.0,
    ],
  }) : assert(stops.length == 2, 'Stops length must be equal to 2');

  /// The gradient starting color.
  final Color color;

  /// Radius of the radial gradient.
  final double radius;

  /// Defines the gradient distribution.
  /// If not specified it assumes a uniform distribution.
  /// Must have length equal to 2.
  final List<double> stops;

  /// Control the blur effect intensity.
  final double blurRadius;

  /// Determine the spot position.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        final gradient = RadialGradient(
          center: alignment,
          radius: radius / min(bounds.height, bounds.width),
          colors: const [
            Colors.black,
            Colors.transparent,
          ],
          stops: stops,
        );

        return _createBlurredImageShaderFromGradient(
          gradient: gradient,
          bounds: bounds,
          blurRadius: blurRadius,
        );
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        color: color,
      ),
    );
  }

  /// Creates a blurred `ImageShader` from the given `RadialGradient`.
  ImageShader _createBlurredImageShaderFromGradient({
    required RadialGradient gradient,
    required Rect bounds,
    required double blurRadius,
  }) {
    final image = _createImageFromGradient(
      gradient: gradient,
      bounds: bounds,
    );

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder, bounds);
    final paint = Paint();

    // Use the blurred image as a paint shader
    canvas.drawImage(
      image,
      Offset.zero,
      paint
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: blurRadius,
          sigmaY: blurRadius,
        ),
    );

    // End recording and convert the Picture into an Image.
    final blurredImage = pictureRecorder.endRecording().toImageSync(
          bounds.size.width.toInt(),
          bounds.size.height.toInt(),
        );

    // Convert the blurred image to an ImageShader.
    return ImageShader(
      blurredImage,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
    );
  }

  ui.Image _createImageFromGradient({
    required RadialGradient gradient,
    required Rect bounds,
  }) {
    final recorder = ui.PictureRecorder();
    final paint = Paint()..shader = gradient.createShader(bounds);
    Canvas(recorder, bounds).drawRect(bounds, paint);

    return recorder.endRecording().toImageSync(
          bounds.width.toInt(),
          bounds.height.toInt(),
        );
  }
}
