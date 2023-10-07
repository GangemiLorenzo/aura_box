import 'package:aura_box/aura_box.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool brigthness = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraBox example',
      themeMode: brigthness ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('Aura box'),
          actions: [
            IconButton(
              onPressed: () => setState(() => brigthness = !brigthness),
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
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          AuraBox(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            spots: [
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
                blurRadius: 100,
              ),
            ],
            child: SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Aura Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          AuraBox(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            spots: [
              AuraSpot(
                color: Colors.green.shade400,
                radius: 600,
                alignment: const Alignment(-1, 0),
                blurRadius: 400,
              ),
              AuraSpot(
                color: Colors.green.shade100,
                radius: 200,
                alignment: const Alignment(0.5, -0.7),
                blurRadius: 100,
              ),
              AuraSpot(
                color: Colors.blue,
                radius: 300,
                alignment: const Alignment(0.5, 0.8),
                blurRadius: 300,
              ),
            ],
            child: SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Aura Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          AuraBox(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            spots: [
              AuraSpot(
                color: Colors.red,
                radius: 300,
                alignment: Alignment.center,
                blurRadius: 200,
              ),
              AuraSpot(
                color: Colors.amber,
                radius: 300,
                alignment: const Alignment(0, 1.4),
                blurRadius: 30,
              ),
            ],
            child: SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Aura Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          AuraBox(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            spots: [
              AuraSpot(
                color: Colors.amber,
                radius: 200,
                alignment: const Alignment(0.1, 0.1),
                blurRadius: 30,
              ),
              AuraSpot(
                color: Colors.red.shade400,
                radius: 180,
                alignment: const Alignment(-0.1, -0.1),
                blurRadius: 20,
              ),
            ],
            child: SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Aura Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          AuraBox(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            spots: [
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
                blurRadius: 150,
              ),
            ],
            child: SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Aura Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
