import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/app.dart';
import 'package:destination_alert/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('App smoke test initializes to SplashScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DestinationAlertApp());

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
