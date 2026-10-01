import 'package:aura_box/aura_box.dart';
import 'package:material_ui/material_ui.dart';

/// A named list of spots.
class AuraPreset {
  const AuraPreset(this.name, this.spots, {this.background});

  final String name;
  final List<AuraSpot> spots;
  final Color? background;
}

final List<AuraPreset> presets = [
  AuraPreset('Violet', [
    AuraSpot(
      color: Colors.purple.shade300,
      radius: 500,
      alignment: const Alignment(0, 0.9),
      blurRadius: 50,
    ),
    AuraSpot(
      color: Colors.deepPurple.shade100,
      radius: 400,
      alignment: const Alignment(-1.2, 1.2),
      blurRadius: 50,
    ),
    AuraSpot(
      color: Colors.indigo.shade700,
      radius: 400,
      alignment: const Alignment(-0.5, -1.2),
      blurRadius: 50,
    ),
    AuraSpot(
      color: Colors.purpleAccent.shade700,
      radius: 300,
      alignment: const Alignment(1.2, -1.2),
      blurRadius: 60,
    ),
  ]),
  AuraPreset('Mint', [
    AuraSpot(
      color: Colors.green.shade400,
      radius: 600,
      alignment: const Alignment(-1, 0),
      blurRadius: 80,
    ),
    AuraSpot(
      color: Colors.green.shade100,
      radius: 250,
      alignment: const Alignment(0.5, -0.7),
      blurRadius: 50,
    ),
    AuraSpot(
      color: Colors.blue,
      radius: 350,
      alignment: const Alignment(0.5, 0.9),
      blurRadius: 70,
    ),
  ]),
  AuraPreset('Sunset', [
    AuraSpot(
      color: Colors.red.shade300,
      radius: 420,
      alignment: const Alignment(0, -0.4),
      blurRadius: 80,
    ),
    AuraSpot(
      color: Colors.amber,
      radius: 300,
      alignment: const Alignment(0, 1.4),
      blurRadius: 30,
    ),
  ]),
  AuraPreset('Ember', background: Colors.blueGrey.shade100, [
    const AuraSpot(
      color: Colors.amber,
      radius: 200,
      alignment: Alignment(0.1, 0.1),
      blurRadius: 30,
    ),
    AuraSpot(
      color: Colors.red.shade400,
      radius: 180,
      alignment: const Alignment(-0.1, -0.1),
      blurRadius: 20,
    ),
  ]),
  AuraPreset('Rose', [
    AuraSpot(
      color: Colors.pink.shade600,
      radius: 500,
      alignment: const Alignment(-0.9, -0.9),
      blurRadius: 60,
    ),
    AuraSpot(
      color: Colors.deepOrange.shade200,
      radius: 200,
      alignment: const Alignment(0, -0.9),
      blurRadius: 50,
    ),
    AuraSpot(
      color: Colors.orange.shade300,
      radius: 300,
      alignment: const Alignment(0, 0.9),
      blurRadius: 60,
    ),
    AuraSpot(
      color: Colors.deepOrange.shade100,
      radius: 400,
      alignment: const Alignment(-0.9, 0.9),
      blurRadius: 30,
    ),
    AuraSpot(
      color: Colors.pink.shade900,
      radius: 400,
      alignment: const Alignment(1, -0.3),
      blurRadius: 90,
    ),
  ]),
];
