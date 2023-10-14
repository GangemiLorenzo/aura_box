import 'package:aura_box/aura_box.dart'; // Import your AuraBox class
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

void main() {
  group('AuraBox', () {
    testWidgets('renders AuraSpot and ShaderMasks',
        (WidgetTester tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        MaterialApp(
          home: AuraBox(
            spots: [
              AuraSpot(
                color: Colors.blue,
                radius: 50,
                alignment: Alignment.center,
                blurRadius: 5,
              ),
              AuraSpot(
                color: Colors.red,
                radius: 50,
                alignment: Alignment.bottomLeft,
                blurRadius: 5,
              ),
            ],
            child: Container(),
          ),
        ),
      );

      expect($(AuraBox), findsOneWidget);
      expect($(AuraBox).$(AuraSpot), findsNWidgets(2));
      expect($(AuraBox).$(AuraSpot).$(ShaderMask), findsNWidgets(2));
    });

    testWidgets('applies decoration over the main container',
        (WidgetTester tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        MaterialApp(
          home: AuraBox(
            spots: const [],
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(),
          ),
        ),
      );

      // Verify that the decoration is applied correctly
      final container =
          $(AuraBox).$(Container).first.evaluate().single.widget as Container;
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
      expect(decoration.shape, equals(BoxShape.rectangle));
      expect(decoration.borderRadius, equals(BorderRadius.circular(10)));
    });

    testWidgets('given decoration with border radius, applies ClipRRect',
        (WidgetTester tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        MaterialApp(
          home: AuraBox(
            spots: [
              AuraSpot(
                color: Colors.blue,
                radius: 50,
                alignment: Alignment.center,
                blurRadius: 5,
                stops: const [0.0, 0.5],
              ),
              AuraSpot(
                color: Colors.red,
                radius: 50,
                alignment: Alignment.bottomLeft,
                blurRadius: 5,
              ),
            ],
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(),
          ),
        ),
      );

      expect($(AuraBox).$(ClipRRect), findsNWidgets(2));
      final clipRRect =
          $(AuraBox).$(ClipRRect).first.evaluate().single.widget as ClipRRect;
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(10)));
    });

    testWidgets('given decoration with BoxShape.circle, applies ClipOval',
        (WidgetTester tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );

      await $.pumpWidget(
        MaterialApp(
          home: AuraBox(
            spots: [
              AuraSpot(
                color: Colors.blue,
                radius: 50,
                alignment: Alignment.center,
                blurRadius: 5,
                stops: const [0.0, 0.5],
              ),
              AuraSpot(
                color: Colors.red,
                radius: 50,
                alignment: Alignment.bottomLeft,
                blurRadius: 5,
              ),
            ],
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Container(),
          ),
        ),
      );

      expect($(AuraBox).$(ClipOval), findsNWidgets(2));
    });

    testWidgets('composes child and spots in a Stack',
        (WidgetTester tester) async {
      final $ = PatrolTester(
        tester: tester,
        config: const PatrolTesterConfig(),
      );
      await $.pumpWidget(
        MaterialApp(
          home: AuraBox(
            spots: [
              AuraSpot(
                color: Colors.blue,
                radius: 50,
                alignment: Alignment.center,
                blurRadius: 5,
                stops: const [0.0, 0.5],
              ),
              AuraSpot(
                color: Colors.red,
                radius: 50,
                alignment: Alignment.bottomLeft,
                blurRadius: 5,
              ),
            ],
            child: Container(),
          ),
        ),
      );

      expect($(Stack), findsOneWidget);
      final stack = $(Stack).evaluate().single.widget as Stack;
      expect(stack.children.length, equals(3));
    });
  });
}
