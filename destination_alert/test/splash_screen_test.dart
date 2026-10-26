import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/app.dart';
import 'package:destination_alert/app/router/app_router.dart';
import 'package:destination_alert/core/constants/asset_constants.dart';
import 'package:destination_alert/core/widgets/app_splash_screen.dart';
import 'package:destination_alert/features/auth/presentation/screens/login_screen.dart';
import 'package:destination_alert/features/home/presentation/screens/home_screen.dart';
import 'package:destination_alert/features/splash/presentation/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Screen Visual & Asset Tests', () {
    testWidgets('Uses exact background and logo assets with proper fit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppSplashScreen(animate: false, duration: null),
        ),
      );

      final bgFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AppAssets.splashBackground,
      );
      expect(bgFinder, findsOneWidget);

      final bgImage = tester.widget<Image>(bgFinder);
      expect(bgImage.fit, equals(BoxFit.cover));
      expect(bgImage.alignment, equals(Alignment.center));

      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.splashLogo,
      );
      expect(logoFinder, findsOneWidget);

      final logoImage = tester.widget<Image>(logoFinder);
      expect(logoImage.fit, equals(BoxFit.contain));
      expect(logoImage.alignment, equals(Alignment.center));
    });

    testWidgets('Logo is horizontally and vertically centered', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AppSplashScreen(animate: false, duration: null),
        ),
      );

      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.splashLogo,
      );

      final logoCenter = tester.getCenter(logoFinder);
      final screenCenter = const Offset(390 / 2, 844 / 2);

      expect(logoCenter.dx, closeTo(screenCenter.dx, 1.0));
      expect(logoCenter.dy, closeTo(screenCenter.dy, 1.0));
    });

    testWidgets('Adapts responsively to small phone without overflow', (
      WidgetTester tester,
    ) async {
      // Small phone: 320 x 568
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AppSplashScreen(animate: false, duration: null),
        ),
      );

      expect(tester.takeException(), isNull);

      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.splashLogo,
      );
      final logoSize = tester.getSize(logoFinder);
      expect(logoSize.width, greaterThanOrEqualTo(120.0));
      expect(logoSize.width, lessThanOrEqualTo(320.0));
      expect(logoSize.height, lessThanOrEqualTo(568 * 0.35));
    });

    testWidgets('Adapts responsively to large phone without overflow', (
      WidgetTester tester,
    ) async {
      // Large phone: 430 x 932
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AppSplashScreen(animate: false, duration: null),
        ),
      );

      expect(tester.takeException(), isNull);

      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.splashLogo,
      );
      final logoSize = tester.getSize(logoFinder);
      expect(logoSize.width, lessThanOrEqualTo(260.0));
    });

    testWidgets(
      'Adapts responsively to landscape / height-constrained screens',
      (WidgetTester tester) async {
        // Landscape: 800 x 400
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: AppSplashScreen(animate: false, duration: null),
          ),
        );

        expect(tester.takeException(), isNull);

        final logoFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == AppAssets.splashLogo,
        );
        final logoSize = tester.getSize(logoFinder);
        // Logo height must not exceed constraints or screen height
        expect(logoSize.height, lessThanOrEqualTo(400 * 0.35));
      },
    );
  });

  group('Startup Flow & Navigation Tests', () {
    testWidgets('Navigates to login screen when splash completes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Advance time past splash duration
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('DestinationAlertApp root boots into splash screen and then login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DestinationAlertApp());
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Navigates to custom nextRoute when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(
            duration: Duration(milliseconds: 100),
            nextRoute: AppRouter.home,
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
