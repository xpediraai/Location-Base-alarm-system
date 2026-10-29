import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/theme/app_theme.dart';
import 'package:destination_alert/core/services/firestore_database_service.dart';
import 'package:destination_alert/core/services/places_search_service.dart';
import 'package:destination_alert/features/alarm/data/models/destination_alarm_model.dart';
import 'package:destination_alert/features/alarm/presentation/screens/set_destination_alarm_screen.dart';

/// Test mock implementation for controlled FirestoreDatabaseService operations.
class MockControlledFirestoreService extends FirestoreDatabaseService {
  final List<Map<String, dynamic>> savedAlarms = [];

  @override
  Future<String> saveDestinationAlarm({
    String? alarmId,
    required String destinationName,
    String? address,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    bool isEnabled = true,
    String? alarmTone,
    bool vibrate = true,
  }) async {
    final id = alarmId ?? 'alarm-doc-${savedAlarms.length + 1}';
    savedAlarms.add({
      'id': id,
      'destinationName': destinationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isEnabled': isEnabled,
      'alarmTone': alarmTone,
      'vibrate': vibrate,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return id;
  }
}

Widget createTestableSetAlarmWidget({required Widget child}) {
  return MaterialApp(theme: AppTheme.lightTheme, home: child);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlacesSearchService searchService;
  late MockControlledFirestoreService mockFirestore;

  setUp(() {
    searchService = PlacesSearchService();
    mockFirestore = MockControlledFirestoreService();
  });

  group('Phase 3 — Destination Alarm Flow Acceptance Tests', () {
    // 1. Destination search returns usable results
    test('1. PlacesSearchService returns curated results and coordinates for search queries', () async {
      final stationResults = await searchService.searchDestinations('Station');
      expect(stationResults.isNotEmpty, isTrue);
      expect(stationResults.first.name, contains('Station'));
      expect(stationResults.first.latitude, isNonZero);
      expect(stationResults.first.longitude, isNonZero);

      final airportResults = await searchService.searchDestinations('Airport');
      expect(airportResults.isNotEmpty, isTrue);
      expect(airportResults.first.name, contains('Airport'));

      // Coordinate string parsing
      final coordResults = await searchService.searchDestinations(
        '23.0225, 72.5714',
      );
      expect(coordResults.length, 1);
      expect(coordResults.first.latitude, closeTo(23.0225, 0.0001));
      expect(coordResults.first.longitude, closeTo(72.5714, 0.0001));
    });

    // 2. Reject missing destination data on submit
    testWidgets(
      '2. Submitting without selecting destination is rejected with actionable error',
      (tester) async {
        await tester.pumpWidget(
          createTestableSetAlarmWidget(
            child: SetDestinationAlarmScreen(
              firestoreDatabaseService: mockFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Save Destination Alarm button with empty form
        await tester.ensureVisible(
          find.byKey(const Key('set_alarm_submit_button')),
        );
        await tester.tap(find.byKey(const Key('set_alarm_submit_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Please search and select a destination stop.'),
          findsOneWidget,
        );
      },
    );

    // 3. Search and select destination displays preview card with coordinates
    testWidgets(
      '3. Selecting a destination from search results displays selected card with GPS coordinates',
      (tester) async {
        await tester.pumpWidget(
          createTestableSetAlarmWidget(
            child: SetDestinationAlarmScreen(
              firestoreDatabaseService: mockFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(
          find.byKey(const Key('set_alarm_search_field')),
          'Railway',
        );
        await tester.pumpAndSettle();

        // Tap on search result
        expect(find.byKey(const Key('search_result_item_0')), findsOneWidget);
        await tester.tap(find.byKey(const Key('search_result_item_0')));
        await tester.pumpAndSettle();

        // Selected card is visible
        expect(
          find.byKey(const Key('set_alarm_selected_destination_card')),
          findsOneWidget,
        );
        expect(find.textContaining('GPS:'), findsOneWidget);
      },
    );

    // 4. Radius selection updates value and chip state
    testWidgets(
      '4. Radius selection switches between 100m, 250m, 500m, 1 km, and 2 km presets',
      (tester) async {
        await tester.pumpWidget(
          createTestableSetAlarmWidget(
            child: SetDestinationAlarmScreen(
              firestoreDatabaseService: mockFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Default is 500 m
        expect(find.byKey(const Key('set_alarm_radius_label')), findsOneWidget);
        expect(find.text('500 m'), findsWidgets);

        // Select 1 km
        await tester.tap(find.byKey(const Key('radius_chip_1000')));
        await tester.pumpAndSettle();
        expect(find.text('1 km'), findsWidgets);

        // Select 250 m
        await tester.tap(find.byKey(const Key('radius_chip_250')));
        await tester.pumpAndSettle();
        expect(find.text('250 m'), findsWidgets);
      },
    );

    // 5. Successful alarm save flow triggers callback
    testWidgets(
      '5. Successful alarm creation saves data and triggers completion callback',
      (tester) async {
        bool onAlarmSavedCalled = false;

        await tester.pumpWidget(
          createTestableSetAlarmWidget(
            child: SetDestinationAlarmScreen(
              firestoreDatabaseService: mockFirestore,
              onAlarmSaved: () {
                onAlarmSavedCalled = true;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Search and select
        await tester.enterText(
          find.byKey(const Key('set_alarm_search_field')),
          'Central',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('search_result_item_0')));
        await tester.pumpAndSettle();

        // Change radius to 1000m
        await tester.ensureVisible(find.byKey(const Key('radius_chip_1000')));
        await tester.tap(find.byKey(const Key('radius_chip_1000')));
        await tester.pumpAndSettle();

        // Save alarm
        await tester.ensureVisible(
          find.byKey(const Key('set_alarm_submit_button')),
        );
        await tester.tap(find.byKey(const Key('set_alarm_submit_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(onAlarmSavedCalled, isTrue);
        expect(mockFirestore.savedAlarms.length, 1);
        expect(
          mockFirestore.savedAlarms.first['destinationName'],
          'Central Railway Station',
        );
        expect(mockFirestore.savedAlarms.first['radiusMeters'], 1000.0);
      },
    );

    // 6. DestinationAlarmModel serialization and deserialization
    test('6. DestinationAlarmModel serializes and deserializes accurately with formatted radius', () {
      final now = DateTime.now();
      final alarm = DestinationAlarmModel(
        id: 'alarm-test-99',
        destinationName: 'Tech Park Metro Gate 3',
        address: 'Electronic City Phase 1',
        latitude: 12.8456,
        longitude: 77.6601,
        radiusMeters: 1000,
        isEnabled: true,
        alarmTone: 'Gentle Radar',
        vibrate: true,
        createdAt: now,
      );

      final json = alarm.toJson();
      expect(json['id'], 'alarm-test-99');
      expect(json['destinationName'], 'Tech Park Metro Gate 3');
      expect(json['radiusMeters'], 1000);
      expect(json['isEnabled'], isTrue);
      expect(json['alarmTone'], 'Gentle Radar');

      final deserialized = DestinationAlarmModel.fromJson(
        json,
        docId: 'alarm-test-99',
      );
      expect(deserialized.id, 'alarm-test-99');
      expect(deserialized.destinationName, 'Tech Park Metro Gate 3');
      expect(deserialized.formattedRadius, '1 km');
    });
  });
}
