import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/router/app_router.dart';
import 'package:destination_alert/app/theme/app_theme.dart';
import 'package:destination_alert/core/services/local_storage_service.dart';
import 'package:destination_alert/core/widgets/app_page_indicator.dart';
import 'package:destination_alert/features/auth/presentation/screens/login_screen.dart';
import 'package:destination_alert/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:destination_alert/features/onboarding/presentation/widgets/onboarding_cards_illustration.dart';
import 'package:destination_alert/features/onboarding/presentation/widgets/onboarding_commuter_illustration.dart';
import 'package:destination_alert/features/onboarding/presentation/widgets/onboarding_map_radar_illustration.dart';

Widget createTestableWidget({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
    onGenerateRoute: AppRouter.onGenerateRoute,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await LocalStorageService.instance.init();
    await LocalStorageService.instance.setOnboardingCompleted(false);
  });

  group('OnboardingScreen Flow & Visual Tests', () {
    testWidgets(
      'Renders page 1 with commuter illustration, title, and buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestableWidget(child: const OnboardingScreen()),
        );

        expect(find.text('Never Miss Your Destination'), findsOneWidget);
        expect(
          find.text(
            'Set location-based alarms and get notified when you arrive.',
          ),
          findsOneWidget,
        );
        expect(find.byType(OnboardingCommuterIllustration), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
        expect(find.byType(AppPageIndicator), findsOneWidget);
      },
    );

    testWidgets('Tapping Next navigates smoothly through all 3 pages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const OnboardingScreen()),
      );

      // Page 1
      expect(find.text('Never Miss Your Destination'), findsOneWidget);
      expect(find.byType(OnboardingCommuterIllustration), findsOneWidget);

      // Tap Next -> advances to Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Your Destination'), findsOneWidget);
      expect(
        find.text(
          'Find places easily, select your destination, and set your arrival radius.',
        ),
        findsOneWidget,
      );
      expect(find.byType(OnboardingMapRadarIllustration), findsOneWidget);

      // Tap Next -> advances to Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Travel with Confidence'), findsOneWidget);
      expect(
        find.text(
          'Create alarms, receive arrival alerts, and manage your journeys with ease.',
        ),
        findsOneWidget,
      );
      expect(find.byType(OnboardingCardsIllustration), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      // On page 3, 'Next' and 'Skip' are replaced with full-width Get Started
      expect(find.text('Next'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('Swipe gestures navigate between onboarding pages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const OnboardingScreen()),
      );

      expect(find.text('Never Miss Your Destination'), findsOneWidget);

      // Fling left to page 2
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Choose Your Destination'), findsOneWidget);

      // Fling left to page 3
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Travel with Confidence'), findsOneWidget);

      // Fling right back to page 2
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Choose Your Destination'), findsOneWidget);
    });

    testWidgets(
      'Tapping Skip completes onboarding and navigates to LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.onboarding,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(LocalStorageService.instance.isOnboardingCompleted, isFalse);

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(LocalStorageService.instance.isOnboardingCompleted, isTrue);
      },
    );

    testWidgets(
      'Tapping Get Started on Page 3 completes onboarding and navigates to LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.onboarding,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );

        // Advance to page 3
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget);
        expect(LocalStorageService.instance.isOnboardingCompleted, isFalse);

        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(LocalStorageService.instance.isOnboardingCompleted, isTrue);
      },
    );

    testWidgets('Adapts responsively to small screen without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Advance to page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Advance to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
