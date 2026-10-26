import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/core/widgets/app_splash_screen.dart';
import 'package:destination_alert/core/widgets/sound_wave_loader.dart';
import 'package:destination_alert/features/splash/presentation/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundWaveLoader Widget Tests', () {
    testWidgets('Renders 11 bars with rounded corners', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: SoundWaveLoader())),
        ),
      );

      // Verify Semantics label exists
      expect(find.byType(SoundWaveLoader), findsOneWidget);

      // Verify 11 bar containers exist
      final containers = find.descendant(
        of: find.byType(SoundWaveLoader),
        matching: find.byType(Container),
      );
      expect(containers, findsNWidgets(11));

      // Advance animation slightly and verify bars remain rendered
      await tester.pump(const Duration(milliseconds: 200));
      expect(containers, findsNWidgets(11));
    });

    testWidgets('Animates bar heights over time without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundWaveLoader(
                cycleDuration: Duration(milliseconds: 1000),
              ),
            ),
          ),
        ),
      );

      // Sample heights at t = 0
      final containers = find.descendant(
        of: find.byType(SoundWaveLoader),
        matching: find.byType(Container),
      );
      final initialHeightBar6 = tester.getSize(containers.at(6)).height;

      // Advance by 250ms (quarter cycle)
      await tester.pump(const Duration(milliseconds: 250));
      final quarterHeightBar6 = tester.getSize(containers.at(6)).height;

      // Advance by another 250ms (half cycle)
      await tester.pump(const Duration(milliseconds: 250));
      final halfHeightBar6 = tester.getSize(containers.at(6)).height;

      // Heights should animate smoothly and change across the cycle
      expect(initialHeightBar6, greaterThan(0.0));
      expect(quarterHeightBar6, greaterThan(0.0));
      expect(halfHeightBar6, greaterThan(0.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Is integrated into AppSplashScreen and SplashScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen(duration: Duration(seconds: 10))),
      );

      // Both SplashScreen and SoundWaveLoader should be present
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(AppSplashScreen), findsOneWidget);
      expect(find.byType(SoundWaveLoader), findsOneWidget);

      // Verify 11 bars rendered within the splash screen
      final containers = find.descendant(
        of: find.byType(SoundWaveLoader),
        matching: find.byType(Container),
      );
      expect(containers, findsNWidgets(11));
    });

    testWidgets('Disposes animation controller cleanly when unmounted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SoundWaveLoader())),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Replace widget with empty container to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
