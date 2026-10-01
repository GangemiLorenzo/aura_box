import 'dart:math' as math;

/// `pi / 2 - 1`: the gap between the Rayleigh mean and the far-field mean of
/// the Rice distribution, in units of sigma squared.
const double _riceGap = math.pi / 2 - 1;

/// Error function, Abramowitz and Stegun 7.1.26.
///
/// The absolute error is below `1.5e-7`.
double auraErf(double x) {
  final a = x.abs();
  final t = 1 / (1 + 0.3275911 * a);
  final poly =
      ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) *
              t +
          0.254829592) *
      t;
  return x.sign * (1 - poly * math.exp(-a * a));
}

/// `max(x, 0)` convolved with a Gaussian of standard deviation [sigma].
double auraSoftRelu(double x, double sigma) {
  final z = x / math.max(sigma, 0.0001);
  final cdf = 0.5 * (1 + auraErf(z * math.sqrt1_2));
  final pdf = math.exp(-0.5 * z * z) / math.sqrt(2 * math.pi);
  return x * cdf + sigma * pdf;
}

/// The opacity of a spot at [distance] from its center.
///
/// The spot is a radial ramp: opaque inside the [inner] radius, fading
/// linearly to transparent at the [outer] radius, then blurred by a Gaussian
/// of standard deviation [sigma].
///
/// Blurring a radially symmetric shape is the expected value of the ramp over
/// a Rice distribution. This function approximates that distribution with a
/// moment-matched normal distribution, which gives a closed form. The result
/// is exact for `sigma == 0` and stays within about 0.04 of the true blur for
/// a sigma as large as 1.5 times the radius.
///
/// This is the Dart twin of `falloff` in `shaders/aura.frag`. Keep both in
/// sync.
double auraFalloff(double distance, double inner, double outer, double sigma) {
  final d2 = distance * distance;
  final s2 = sigma * sigma;
  final gap = _riceGap / (1 + 0.5 * d2 / math.max(s2, 0.00000001));
  final mean = math.sqrt(d2 + s2 * (1 + gap));
  final deviation = sigma * math.sqrt(1 - gap);
  final ramp =
      auraSoftRelu(outer - mean, deviation) -
      auraSoftRelu(inner - mean, deviation);
  return (ramp / (outer - inner)).clamp(0.0, 1.0);
}
