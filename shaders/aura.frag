#version 460 core

// Paints up to MAX_SPOTS blurred radial spots in a single pass.
//
// Each spot is a radial ramp: fully opaque inside the inner radius, fading
// linearly to transparent at the outer radius. The Gaussian blur is not a
// separate pass. For a radially symmetric shape, blurring is the expected
// value of the ramp over a Rice distribution, which is approximated here by a
// moment-matched normal distribution. That expectation has a closed form.
//
// Keep the math in sync with lib/src/rendering/aura_profile.dart.

#include <flutter/runtime_effect.glsl>

precision highp float;

#define MAX_SPOTS 8

// Number of active spots, 0..MAX_SPOTS.
uniform float uCount;
// Film grain amplitude. 0 disables grain, dithering stays on.
uniform float uGrain;
// Device pixels per logical pixel. Keeps the noise locked to device pixels.
uniform float uPixelRatio;
// Straight (not premultiplied) color of each spot.
uniform vec4 uColor[MAX_SPOTS];
// Per spot: center.xy, inner radius, outer radius. Logical pixels.
uniform vec4 uGeom[MAX_SPOTS];
// Per spot: blur sigma in logical pixels.
uniform float uSigma[MAX_SPOTS];

out vec4 fragColor;

// pi / 2 - 1: the gap between the Rayleigh mean and the far-field mean.
const float kRiceGap = 0.57079633;

// max(x, 0) convolved with a Gaussian of deviation s.
//
// The closed form is x * cdf(z) + s * pdf(z) with z = x / s. The error
// function inside the cdf is Abramowitz and Stegun 7.1.26 (absolute error
// below 1.5e-7). Its exponential is the same one the pdf needs, so each call
// costs a single exp.
float softRelu(float x, float s) {
  float z = x / max(s, 0.0001);
  float gauss = exp(-0.5 * z * z);
  float t = 1.0 / (1.0 + 0.3275911 * 0.70710678 * abs(z));
  float poly = ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t
      - 0.284496736) * t + 0.254829592) * t;
  float erf = sign(z) * (1.0 - poly * gauss);
  return x * 0.5 * (1.0 + erf) + s * 0.39894228 * gauss;
}

// Opacity of a spot at squared distance d2 from its center.
float falloff(float d2, float inner, float outer, float sigma) {
  if (sigma <= 0.0) {
    // No blur: the exact linear ramp.
    return clamp((outer - sqrt(d2)) / (outer - inner), 0.0, 1.0);
  }
  float s2 = sigma * sigma;
  float gap = kRiceGap / (1.0 + 0.5 * d2 / s2);
  float mean = sqrt(d2 + s2 * (1.0 + gap));
  float deviation = sigma * sqrt(1.0 - gap);
  float ramp = softRelu(outer - mean, deviation) - softRelu(inner - mean, deviation);
  return clamp(ramp / (outer - inner), 0.0, 1.0);
}

// Hash without sine, by Dave Hoskins. Stable across GPUs.
float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  vec2 position = FlutterFragCoord().xy;
  vec4 result = vec4(0.0);

  for (int i = 0; i < MAX_SPOTS; i++) {
    if (float(i) >= uCount) {
      break;
    }
    vec2 delta = position - uGeom[i].xy;
    float d2 = dot(delta, delta);
    // Four sigmas past the outer radius the spot is invisible. Skip the math.
    float reach = uGeom[i].w + 4.0 * uSigma[i];
    if (d2 > reach * reach) {
      continue;
    }
    float alpha = uColor[i].a
        * falloff(d2, uGeom[i].z, uGeom[i].w, uSigma[i]);
    // Source-over, premultiplied.
    result = vec4(uColor[i].rgb * alpha, alpha) + result * (1.0 - alpha);
  }

  // One noise value per device pixel. Half a step of an 8-bit channel hides
  // the banding (dither). The grain is the same noise, scaled by the opacity.
  float noise = hash12(floor(position * uPixelRatio)) - 0.5;
  vec4 color = result + noise / 255.0;
  color.rgb += noise * uGrain * result.a;
  fragColor = vec4(max(color.rgb, 0.0), clamp(color.a, 0.0, 1.0));
}
