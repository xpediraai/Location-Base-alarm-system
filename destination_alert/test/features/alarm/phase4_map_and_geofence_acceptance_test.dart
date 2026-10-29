import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:destination_alert/core/services/geofence_service.dart';
import 'package:destination_alert/core/services/places_search_service.dart';
import 'package:destination_alert/features/alarm/data/models/destination_alarm_model.dart';
import 'package:destination_alert/features/map_picker/presentation/widgets/destination_map_view.dart';
import 'package:destination_alert/features/map_picker/presentation/widgets/radius_slider.dart';

void main() {
  group('Phase 4 — Map Display & Interaction Acceptance Tests', () {
    testWidgets(
      '1. DestinationMapView renders FlutterMap, tile layer, and attribution',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DestinationMapView(
                initialCenter: LatLng(23.0225, 72.5714),
                initialZoom: 14.0,
              ),
            ),
          ),
        );
        await tester.pump();

        // Check FlutterMap widget exists
        expect(find.byType(FlutterMap), findsOneWidget);

        // Check TileLayer exists and targets OpenStreetMap
        final tileLayerFinder = find.byType(TileLayer);
        expect(tileLayerFinder, findsOneWidget);
        final tileLayer = tester.widget<TileLayer>(tileLayerFinder);
        expect(
          tileLayer.urlTemplate,
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        );

        // Check SimpleAttributionWidget exists
        expect(find.byType(SimpleAttributionWidget), findsOneWidget);
      },
    );

    testWidgets(
      '2. DestinationMapView displays destination marker and radius circle',
      (tester) async {
        const destCoords = LatLng(23.0300, 72.5800);
        const currentCoords = LatLng(23.0225, 72.5714);
        const radius = 500.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DestinationMapView(
                initialCenter: destCoords,
                currentLocation: currentCoords,
                destination: destCoords,
                radiusMeters: radius,
              ),
            ),
          ),
        );
        await tester.pump();

        // CircleLayer with radius
        final circleLayerFinder = find.byType(CircleLayer);
        expect(circleLayerFinder, findsOneWidget);
        final circleLayer = tester.widget<CircleLayer>(circleLayerFinder);
        expect(circleLayer.circles.length, 1);
        final circle = circleLayer.circles.first;
        expect(circle.point, destCoords);
        expect(circle.radius, radius);
        expect(circle.useRadiusInMeter, isTrue);

        // MarkerLayer with both current location and destination markers
        final markerLayerFinder = find.byType(MarkerLayer);
        expect(markerLayerFinder, findsOneWidget);
        final markerLayer = tester.widget<MarkerLayer>(markerLayerFinder);
        expect(markerLayer.markers.length, 2);

        // Destination icon rendered
        expect(find.byKey(const Key('destination_pin_marker')), findsOneWidget);
        // Current location dot rendered
        expect(find.byKey(const Key('current_location_dot')), findsOneWidget);
      },
    );

    testWidgets(
      '3. Map controls (Zoom In, Zoom Out, Recenter) trigger callbacks correctly',
      (tester) async {
        bool recenterCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestinationMapView(
                initialCenter: const LatLng(23.0225, 72.5714),
                onRecenter: () {
                  recenterCalled = true;
                },
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('map_zoom_in_button')), findsOneWidget);
        expect(find.byKey(const Key('map_zoom_out_button')), findsOneWidget);
        expect(find.byKey(const Key('map_recenter_button')), findsOneWidget);

        await tester.tap(find.byKey(const Key('map_zoom_in_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('map_zoom_out_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('map_recenter_button')));
        await tester.pump();

        expect(recenterCalled, isTrue);
      },
    );

    testWidgets(
      '4. RadiusSlider updates values via preset choice chips and slider',
      (tester) async {
        double selectedRadius = 500.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return RadiusSlider(
                    selectedRadiusMeters: selectedRadius,
                    onRadiusChanged: (newRadius) {
                      setState(() {
                        selectedRadius = newRadius;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('500 m'), findsWidgets);

        // Tap 1 km preset
        await tester.tap(find.byKey(const Key('preset_chip_1000')));
        await tester.pumpAndSettle();
        expect(selectedRadius, 1000.0);
        expect(find.text('1 km'), findsWidgets);

        // Tap 250 m preset
        await tester.tap(find.byKey(const Key('preset_chip_250')));
        await tester.pumpAndSettle();
        expect(selectedRadius, 250.0);
        expect(find.text('250 m'), findsWidgets);
      },
    );
  });

  group('Phase 4 — Geocoding & Nominatim Provider Acceptance Tests', () {
    test('1. Nominatim provider sends required User-Agent and parses coordinate results', () async {
      final mockClient = MockClient((request) async {
        // Enforce OSM Nominatim policy requirement: User-Agent header
        expect(
          request.headers['User-Agent'],
          contains('DestinationAlert-FlutterApp/1.0.0'),
        );
        expect(request.url.host, 'nominatim.openstreetmap.org');

        final fakeOsmResponse = [
          {
            'place_id': 12345,
            'name': 'Ahmedabad Junction',
            'display_name':
                'Ahmedabad Junction, Kalupur, Ahmedabad, Gujarat, India',
            'lat': '23.0238',
            'lon': '72.5997',
            'type': 'station',
          },
        ];

        return http.Response(
          jsonEncode(fakeOsmResponse),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final provider = NominatimGeocodingProvider(client: mockClient);
      final results = await provider.search('Ahmedabad Junction');

      expect(results.length, 1);
      final item = results.first;
      expect(item.name, 'Ahmedabad Junction');
      expect(item.latitude, 23.0238);
      expect(item.longitude, 72.5997);
      expect(item.category, 'Station');
    });

    test(
      '2. Direct coordinate query (lat, lng) is parsed without network lookup',
      () async {
        final searchService = PlacesSearchService();
        final results = await searchService.searchDestinations(
          '23.0225, 72.5714',
        );

        expect(results.length, 1);
        final item = results.first;
        expect(item.latitude, closeTo(23.0225, 0.0001));
        expect(item.longitude, closeTo(72.5714, 0.0001));
        expect(item.category, 'Custom Pin');
      },
    );

    test(
      '3. Reverse geocode parses address from Nominatim JSON response',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/reverse');
          return http.Response(
            jsonEncode({
              'display_name':
                  'Sabarmati Riverfront, Ashram Road, Ahmedabad, India',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final provider = NominatimGeocodingProvider(client: mockClient);
        final address = await provider.reverseGeocode(
          latitude: 23.0300,
          longitude: 72.5700,
        );

        expect(address, 'Sabarmati Riverfront, Ashram Road, Ahmedabad, India');
      },
    );
  });

  group('Phase 4 — Geofencing Service & Proximity Acceptance Tests', () {
    late GeofenceService geofenceService;

    setUp(() {
      geofenceService = GeofenceService();
    });

    tearDown(() {
      geofenceService.dispose();
    });

    test(
      '1. Accurate geodesic evaluation identifies inside vs outside radius',
      () {
        final alarm = DestinationAlarmModel(
          id: 'alarm-test-1',
          destinationName: 'Central Station',
          address: 'Station Road',
          latitude: 23.0238,
          longitude: 72.5997,
          radiusMeters: 500.0,
          alarmTone: 'Chime',
          vibrate: true,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        // Point at 23.0238, 72.5997 is 0m away -> INSIDE
        final insideEval = geofenceService.evaluatePosition(
          currentLatitude: 23.0238,
          currentLongitude: 72.5997,
          alarm: alarm,
        );
        expect(insideEval.isInside, isTrue);
        expect(insideEval.distanceMeters, 0.0);
        expect(insideEval.distanceToBoundary, -500.0);

        // Point at 23.1000, 72.5997 is ~8.4 km away -> OUTSIDE
        final outsideEval = geofenceService.evaluatePosition(
          currentLatitude: 23.1000,
          currentLongitude: 72.5997,
          alarm: alarm,
        );
        expect(outsideEval.isInside, isFalse);
        expect(outsideEval.distanceMeters, greaterThan(8000.0));
        expect(outsideEval.distanceToBoundary, greaterThan(7500.0));
      },
    );

    test(
      '2. Hysteresis debounce suppresses trigger flapping near perimeter',
      () {
        final alarm = DestinationAlarmModel(
          id: 'alarm-test-2',
          destinationName: 'Metro Station',
          address: 'MG Road',
          latitude: 23.0000,
          longitude: 72.0000,
          radiusMeters: 500.0,
          alarmTone: 'Bell',
          vibrate: true,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        // Start OUTSIDE: ~1 km away
        final initialEvents = geofenceService.processPositionUpdate(
          currentLatitude: 23.0090, // ~1000m north
          currentLongitude: 72.0000,
          activeAlarms: [alarm],
        );
        expect(initialEvents, isEmpty); // No transition triggered initially

        // Step INSIDE: right at the center
        final enterEvents = geofenceService.processPositionUpdate(
          currentLatitude: 23.0000,
          currentLongitude: 72.0000,
          activeAlarms: [alarm],
        );
        expect(enterEvents.length, 1);
        expect(
          enterEvents.first.transitionType,
          GeofenceTransitionType.entered,
        );
        expect(enterEvents.first.alarmId, 'alarm-test-2');

        // GPS jitter: slightly moves but remains inside
        final jitterInsideEvents = geofenceService.processPositionUpdate(
          currentLatitude: 23.0010,
          currentLongitude: 72.0000,
          activeAlarms: [alarm],
        );
        expect(
          jitterInsideEvents,
          isEmpty,
        ); // Suppressed! No duplicate entered event.
      },
    );

    test('3. Disabled alarms are ignored during position evaluation', () {
      final disabledAlarm = DestinationAlarmModel(
        id: 'alarm-disabled-1',
        destinationName: 'Closed Branch',
        address: 'Old Town',
        latitude: 23.0000,
        longitude: 72.0000,
        radiusMeters: 500.0,
        alarmTone: 'Default',
        vibrate: false,
        isEnabled: false, // DISABLED
        createdAt: DateTime.now(),
      );

      final events = geofenceService.processPositionUpdate(
        currentLatitude: 23.0000,
        currentLongitude: 72.0000,
        activeAlarms: [disabledAlarm],
      );

      expect(events, isEmpty);
    });

    test('4. Background readiness report returns comprehensive permission requirements', () async {
      final report = await geofenceService.assessBackgroundReadiness();

      expect(
        report.requiredPermissionsForFullBackground,
        contains(contains('ACCESS_BACKGROUND_LOCATION')),
      );
      expect(
        report.requiredPermissionsForFullBackground,
        contains(contains('FOREGROUND_SERVICE')),
      );
      expect(report.technicalLimitations.isNotEmpty, isTrue);
      expect(report.backgroundExecutionAssessment.isNotEmpty, isTrue);
    });
  });
}
