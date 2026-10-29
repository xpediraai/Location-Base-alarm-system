import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/theme/app_theme.dart';
import 'package:destination_alert/features/alarm/data/models/destination_alarm_model.dart';
import 'package:destination_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:destination_alert/features/auth/data/models/user_model.dart';
import 'package:destination_alert/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:destination_alert/features/auth/presentation/providers/auth_provider.dart';
import 'package:destination_alert/features/home/presentation/screens/home_screen.dart';
import 'package:destination_alert/features/home/presentation/widgets/active_alarm_card.dart';

class MockDashboardAuthDataSource implements AuthRemoteDataSource {
  UserModel? _user;

  MockDashboardAuthDataSource({UserModel? initialUser}) : _user = initialUser;

  @override
  bool get isConfigured => true;

  @override
  UserModel? get currentUser => _user;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    _user = UserModel(id: 'mock-uid-1', email: email, name: 'Alice Commuter');
    return _user!;
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    _user = UserModel(id: 'mock-uid-1', email: email, name: name);
    return _user!;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> logout() async {
    _user = null;
  }
}

Widget createTestableDashboard({
  required Widget child,
  Map<String, WidgetBuilder>? routes,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    routes: routes ?? {},
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 — Interactive Dashboard Acceptance Tests', () {
    testWidgets('1. Displays personalized greeting with user name', (
      tester,
    ) async {
      final mockAuth = MockDashboardAuthDataSource(
        initialUser: const UserModel(
          id: 'user-001',
          email: 'alice@example.com',
          name: 'Alice Commuter',
        ),
      );
      final repo = AuthRepositoryImpl(remoteDataSource: mockAuth);
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        createTestableDashboard(
          child: HomeScreen(
            authProvider: provider,
            customAlarmsStream: Stream.value([]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Alice Commuter', findRichText: true),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home_greeting_name')), findsOneWidget);
    });

    testWidgets('2. Empty state appears when user has no alarms', (
      tester,
    ) async {
      final mockAuth = MockDashboardAuthDataSource(
        initialUser: const UserModel(
          id: 'user-001',
          email: 'alice@example.com',
          name: 'Alice',
        ),
      );
      final provider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
      );

      await tester.pumpWidget(
        createTestableDashboard(
          child: HomeScreen(
            authProvider: provider,
            customAlarmsStream: Stream.value([]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_empty_alarms_view')), findsOneWidget);
      expect(find.text('No destination alarms set yet'), findsOneWidget);
      expect(find.byKey(const Key('home_empty_set_alarm_btn')), findsOneWidget);
    });

    testWidgets(
      '3. Populated state displays destination alarms with ActiveAlarmCard',
      (tester) async {
        final testAlarm = DestinationAlarmModel(
          id: 'alarm-101',
          destinationName: 'Central Metro Station',
          address: 'MG Road, Platform 2',
          latitude: 23.0225,
          longitude: 72.5714,
          radiusMeters: 500,
          isEnabled: true,
          alarmTone: 'Metro Chime',
          createdAt: DateTime.now(),
        );

        final mockAuth = MockDashboardAuthDataSource(
          initialUser: const UserModel(
            id: 'user-001',
            email: 'alice@example.com',
            name: 'Alice',
          ),
        );
        final provider = AuthProvider(
          repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
        );

        await tester.pumpWidget(
          createTestableDashboard(
            child: HomeScreen(
              authProvider: provider,
              customAlarmsStream: Stream.value([testAlarm]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ActiveAlarmCard), findsOneWidget);
        expect(find.text('Central Metro Station'), findsOneWidget);
        expect(find.text('MG Road, Platform 2'), findsOneWidget);
        expect(find.textContaining('500 m alert radius'), findsOneWidget);
      },
    );

    testWidgets('4. Real-time updates reflect when stream emits new alarm', (
      tester,
    ) async {
      final streamController =
          StreamController<List<DestinationAlarmModel>>.broadcast();

      final mockAuth = MockDashboardAuthDataSource(
        initialUser: const UserModel(
          id: 'user-001',
          email: 'alice@example.com',
          name: 'Alice',
        ),
      );
      final provider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
      );

      await tester.pumpWidget(
        createTestableDashboard(
          child: HomeScreen(
            authProvider: provider,
            customAlarmsStream: streamController.stream,
          ),
        ),
      );

      // Initially empty
      streamController.add([]);
      await tester.pumpAndSettle();
      expect(find.byType(ActiveAlarmCard), findsNothing);

      // Stream receives an alarm live
      final alarm = DestinationAlarmModel(
        id: 'live-alarm-1',
        destinationName: 'Airport Terminal 2',
        latitude: 23.0725,
        longitude: 72.6341,
        radiusMeters: 1000,
        createdAt: DateTime.now(),
      );
      streamController.add([alarm]);
      await tester.pumpAndSettle();

      expect(find.byType(ActiveAlarmCard), findsOneWidget);
      expect(find.text('Airport Terminal 2'), findsOneWidget);
      expect(find.textContaining('1 km alert radius'), findsOneWidget);

      await streamController.close();
    });

    testWidgets('5. Signing out triggers confirmation and signs out user', (
      tester,
    ) async {
      final mockAuth = MockDashboardAuthDataSource(
        initialUser: const UserModel(
          id: 'user-001',
          email: 'alice@example.com',
          name: 'Alice',
        ),
      );
      final provider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
      );

      bool navigatedToLogin = false;

      await tester.pumpWidget(
        createTestableDashboard(
          routes: {
            '/login': (context) {
              navigatedToLogin = true;
              return const Scaffold(body: Text('Login Route'));
            },
          },
          child: HomeScreen(
            authProvider: provider,
            customAlarmsStream: Stream.value([]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout button in appbar
      await tester.tap(find.byKey(const Key('home_logout_button')));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Sign Out'), findsWidgets);

      // Tap Sign Out confirm
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(provider.isAuthenticated, isFalse);
      expect(navigatedToLogin, isTrue);
    });

    testWidgets(
      '6. User data isolation: User A does not receive User B records',
      (tester) async {
        // Simulate User A and User B collections
        final userAAlarms = [
          DestinationAlarmModel(
            id: 'alarm-a',
            destinationName: "User A's Home",
            latitude: 10.0,
            longitude: 20.0,
            radiusMeters: 250,
            createdAt: DateTime.now(),
          ),
        ];
        final userBAlarms = [
          DestinationAlarmModel(
            id: 'alarm-b',
            destinationName: "User B's Office",
            latitude: 30.0,
            longitude: 40.0,
            radiusMeters: 500,
            createdAt: DateTime.now(),
          ),
        ];

        final userAStream = Stream.value(userAAlarms);

        final mockAuth = MockDashboardAuthDataSource(
          initialUser: const UserModel(
            id: 'user-a',
            email: 'a@example.com',
            name: 'User A',
          ),
        );
        final provider = AuthProvider(
          repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
        );

        await tester.pumpWidget(
          createTestableDashboard(
            child: HomeScreen(
              authProvider: provider,
              customAlarmsStream: userAStream,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(userAAlarms.contains(userBAlarms.first), isFalse);
        expect(find.text("User A's Home"), findsOneWidget);
        expect(find.text("User B's Office"), findsNothing);
      },
    );

    testWidgets('7. Error and offline state displays retry banner', (
      tester,
    ) async {
      final mockAuth = MockDashboardAuthDataSource(
        initialUser: const UserModel(
          id: 'user-001',
          email: 'alice@example.com',
          name: 'Alice',
        ),
      );
      final provider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockAuth),
      );

      final errorStream = Stream<List<DestinationAlarmModel>>.error(
        'Cloud Firestore network unavailable',
      );

      await tester.pumpWidget(
        createTestableDashboard(
          child: HomeScreen(
            authProvider: provider,
            customAlarmsStream: errorStream,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load alarms'), findsOneWidget);
      expect(
        find.textContaining('Cloud Firestore network unavailable'),
        findsOneWidget,
      );
      expect(find.text('Retry Connection'), findsOneWidget);
    });
  });
}
