import 'package:aura_box/aura_box.dart';
import 'package:material_ui/material_ui.dart';

import 'presets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional: load the shader before the first frame.
  await AuraBox.precache();
  runApp(const ExampleApp());
}

const _radius = BorderRadius.all(Radius.circular(24));

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraBox example',
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Aura Box'),
          actions: [
            IconButton(
              tooltip: 'Toggle brightness',
              onPressed: () => setState(() => _dark = !_dark),
              icon: const Icon(Icons.brightness_4),
            ),
          ],
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            HeroSection(),
            Section('Presets', 'A box and a list of spots.', PresetsSection()),
            Section(
              'Implicit animation',
              'AnimatedAuraBox animates between two lists of spots. Tap it.',
              AnimatedSection(),
            ),
            Section(
              'Decoration',
              'AuraDecoration works in any Container. Tap it.',
              DecorationSection(),
            ),
            Section(
              'Playground',
              'Blur, grain and drift, live.',
              PlaygroundSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section(this.title, this.subtitle, this.child, {super.key});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.bodyMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class Label extends StatelessWidget {
  const Label(this.text, {this.size = 24, super.key});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Drifting spots with a bit of grain.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AuraBox(
      spots: presets.first.spots,
      decoration: const BoxDecoration(borderRadius: _radius),
      grain: 0.08,
      drift: const AuraDrift(amplitude: 0.35),
      child: const SizedBox(height: 320, child: Label('Aura Box', size: 48)),
    );
  }
}

class PresetsSection extends StatelessWidget {
  const PresetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: 260,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        for (final preset in presets)
          AuraBox(
            spots: preset.spots,
            decoration: BoxDecoration(
              color: preset.background,
              borderRadius: _radius,
            ),
            child: Label(preset.name),
          ),
      ],
    );
  }
}

class AnimatedSection extends StatefulWidget {
  const AnimatedSection({super.key});

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final preset = presets[_index];
    return GestureDetector(
      onTap: () => setState(() => _index = (_index + 1) % presets.length),
      child: AnimatedAuraBox(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        spots: preset.spots,
        decoration: const BoxDecoration(borderRadius: _radius),
        child: SizedBox(height: 240, child: Label(preset.name, size: 32)),
      ),
    );
  }
}

class DecorationSection extends StatefulWidget {
  const DecorationSection({super.key});

  @override
  State<DecorationSection> createState() => _DecorationSectionState();
}

class _DecorationSectionState extends State<DecorationSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          width: _expanded ? 420 : 200,
          height: 200,
          decoration: AuraDecoration(
            spots: presets[_expanded ? 2 : 4].spots,
            borderRadius: BorderRadius.circular(_expanded ? 24 : 100),
          ),
          child: Label(_expanded ? 'Sunset' : 'Rose'),
        ),
      ),
    );
  }
}

class PlaygroundSection extends StatefulWidget {
  const PlaygroundSection({super.key});

  @override
  State<PlaygroundSection> createState() => _PlaygroundSectionState();
}

class _PlaygroundSectionState extends State<PlaygroundSection> {
  double _blur = 40;
  double _grain = 0.1;
  bool _drift = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuraBox(
          spots: [
            AuraSpot(
              color: Colors.cyan.shade400,
              radius: 260,
              alignment: const Alignment(-0.6, -0.4),
              blurRadius: _blur,
            ),
            AuraSpot(
              color: Colors.pinkAccent,
              radius: 240,
              alignment: const Alignment(0.6, 0.5),
              blurRadius: _blur,
            ),
            AuraSpot(
              color: Colors.amber,
              radius: 160,
              alignment: const Alignment(0.2, -0.8),
              blurRadius: _blur,
              stops: const [0.2, 1],
            ),
          ],
          decoration: const BoxDecoration(
            color: Color(0xFF14121F),
            borderRadius: _radius,
          ),
          grain: _grain,
          drift: _drift ? const AuraDrift() : null,
          child: const SizedBox(height: 280, width: double.infinity),
        ),
        const SizedBox(height: 8),
        _Control(
          label: 'Blur ${_blur.round()}',
          child: Slider(
            max: 150,
            value: _blur,
            onChanged: (value) => setState(() => _blur = value),
          ),
        ),
        _Control(
          label: 'Grain ${_grain.toStringAsFixed(2)}',
          child: Slider(
            max: 0.5,
            value: _grain,
            onChanged: (value) => setState(() => _grain = value),
          ),
        ),
        _Control(
          label: 'Drift',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Switch(
              value: _drift,
              onChanged: (value) => setState(() => _drift = value),
            ),
          ),
        ),
      ],
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(child: child),
      ],
    );
  }
}
