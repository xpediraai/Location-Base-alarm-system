import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/alarm/data/models/destination_alarm_model.dart';
import 'location_service.dart';

/// Types of geofence boundary transitions.
enum GeofenceTransitionType { entered, exited, dwell }

/// Event emitted when a user crosses a destination alarm radius.
class GeofenceTransitionEvent {
  final String alarmId;
  final String destinationName;
  final GeofenceTransitionType transitionType;
  final double distanceMeters;
  final double radiusMeters;
  final DateTime timestamp;

  const GeofenceTransitionEvent({
    required this.alarmId,
    required this.destinationName,
    required this.transitionType,
    required this.distanceMeters,
    required this.radiusMeters,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'GeofenceTransitionEvent(alarmId: $alarmId, dest: $destinationName, type: $transitionType, dist: ${distanceMeters.toStringAsFixed(1)}m, radius: ${radiusMeters.toStringAsFixed(1)}m)';
  }
}

/// Evaluation result for a specific alarm against a point.
class GeofenceEvaluationResult {
  final String alarmId;
  final String destinationName;
  final double distanceMeters;
  final double radiusMeters;
  final bool isInside;
  final double distanceToBoundary; // Positive if outside, negative if inside

  const GeofenceEvaluationResult({
    required this.alarmId,
    required this.destinationName,
    required this.distanceMeters,
    required this.radiusMeters,
    required this.isInside,
    required this.distanceToBoundary,
  });
}

/// Diagnostic report outlining Android & iOS background execution readiness.
class BackgroundReadinessReport {
  final bool hasForegroundLocationPermission;
  final bool hasBackgroundLocationPermission;
  final bool hasNotificationPermission;
  final bool isBatteryOptimizationIgnored;
  final String backgroundExecutionAssessment;
  final List<String> requiredPermissionsForFullBackground;
  final List<String> technicalLimitations;

  const BackgroundReadinessReport({
    required this.hasForegroundLocationPermission,
    required this.hasBackgroundLocationPermission,
    required this.hasNotificationPermission,
    required this.isBatteryOptimizationIgnored,
    required this.backgroundExecutionAssessment,
    required this.requiredPermissionsForFullBackground,
    required this.technicalLimitations,
  });
}

/// Service managing geodesic proximity calculation, hysteresis debounce,
/// and live location monitoring for destination alarms.
class GeofenceService {
  final LocationService _locationService;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Track the last known state for each alarm to avoid noisy GPS trigger flapping.
  // key: alarmId, value: isInside
  final Map<String, bool> _alarmInsideState = {};

  // Hysteresis buffer in meters (prevents flapping at the boundary)
  static const double hysteresisBufferMeters = 15.0;

  final _transitionController =
      StreamController<GeofenceTransitionEvent>.broadcast();

  Stream<GeofenceTransitionEvent> get transitionStream =>
      _transitionController.stream;

  GeofenceService({LocationService? locationService})
    : _locationService = locationService ?? LocationService();

  /// Pure geodesic evaluation of a position against an alarm.
  /// Can be tested deterministically without hardware GPS.
  GeofenceEvaluationResult evaluatePosition({
    required double currentLatitude,
    required double currentLongitude,
    required DestinationAlarmModel alarm,
  }) {
    final distance = _locationService.calculateDistanceMeters(
      startLatitude: currentLatitude,
      startLongitude: currentLongitude,
      endLatitude: alarm.latitude,
      endLongitude: alarm.longitude,
    );

    final isInside = distance <= alarm.radiusMeters;
    final distanceToBoundary = distance - alarm.radiusMeters;

    return GeofenceEvaluationResult(
      alarmId: alarm.id,
      destinationName: alarm.destinationName,
      distanceMeters: distance,
      radiusMeters: alarm.radiusMeters,
      isInside: isInside,
      distanceToBoundary: distanceToBoundary,
    );
  }

  /// Processes a position update for a set of registered alarms, applying
  /// hysteresis debouncing to suppress jitter at the perimeter.
  List<GeofenceTransitionEvent> processPositionUpdate({
    required double currentLatitude,
    required double currentLongitude,
    required List<DestinationAlarmModel> activeAlarms,
  }) {
    final List<GeofenceTransitionEvent> events = [];
    final now = DateTime.now();

    for (final alarm in activeAlarms) {
      if (!alarm.isEnabled) {
        // Reset state if alarm is disabled
        _alarmInsideState.remove(alarm.id);
        continue;
      }

      final evaluation = evaluatePosition(
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
        alarm: alarm,
      );

      final wasInside = _alarmInsideState[alarm.id];

      if (wasInside == null) {
        // Initial reading
        _alarmInsideState[alarm.id] = evaluation.isInside;
        if (evaluation.isInside) {
          final event = GeofenceTransitionEvent(
            alarmId: alarm.id,
            destinationName: alarm.destinationName,
            transitionType: GeofenceTransitionType.entered,
            distanceMeters: evaluation.distanceMeters,
            radiusMeters: alarm.radiusMeters,
            timestamp: now,
          );
          events.add(event);
          _transitionController.add(event);
        }
      } else if (!wasInside &&
          evaluation.distanceMeters <=
              (alarm.radiusMeters - hysteresisBufferMeters / 2)) {
        // Transitioned from OUTSIDE to INSIDE with hysteresis margin
        _alarmInsideState[alarm.id] = true;
        final event = GeofenceTransitionEvent(
          alarmId: alarm.id,
          destinationName: alarm.destinationName,
          transitionType: GeofenceTransitionType.entered,
          distanceMeters: evaluation.distanceMeters,
          radiusMeters: alarm.radiusMeters,
          timestamp: now,
        );
        events.add(event);
        _transitionController.add(event);
      } else if (wasInside &&
          evaluation.distanceMeters >
              (alarm.radiusMeters + hysteresisBufferMeters / 2)) {
        // Transitioned from INSIDE to OUTSIDE with hysteresis margin
        _alarmInsideState[alarm.id] = false;
        final event = GeofenceTransitionEvent(
          alarmId: alarm.id,
          destinationName: alarm.destinationName,
          transitionType: GeofenceTransitionType.exited,
          distanceMeters: evaluation.distanceMeters,
          radiusMeters: alarm.radiusMeters,
          timestamp: now,
        );
        events.add(event);
        _transitionController.add(event);
      }
    }

    return events;
  }

  /// Clears state for removed or deleted alarms.
  void removeAlarmRegistration(String alarmId) {
    _alarmInsideState.remove(alarmId);
  }

  /// Clears all tracking state.
  void resetAll() {
    _alarmInsideState.clear();
  }

  /// Starts monitoring active alarms using real foreground GPS position stream.
  void startForegroundMonitoring({
    required List<DestinationAlarmModel> Function() getActiveAlarms,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  }) {
    stopMonitoring();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
                (position) {
                  final activeAlarms = getActiveAlarms();
                  processPositionUpdate(
                    currentLatitude: position.latitude,
                    currentLongitude: position.longitude,
                    activeAlarms: activeAlarms,
                  );
                },
                onError: (err) {
                  debugPrint('GeofenceService position stream error: $err');
                },
              );
    } catch (e) {
      debugPrint('GeofenceService failed to initialize position stream: $e');
    }
  }

  /// Stops live GPS position monitoring.
  void stopMonitoring() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Evaluates background readiness on Android/iOS without making false promises.
  /// Android requires explicit background permission, foreground service, and battery exclusion.
  Future<BackgroundReadinessReport> assessBackgroundReadiness() async {
    final permission = await _locationService.checkPermission();
    final hasForeground =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    // Notice: Geolocator handles foreground permission.
    // ACCESS_BACKGROUND_LOCATION is only granted if requested separately on Android 10+.
    final isBackgroundGranted = permission == LocationPermission.always;
    const isNotificationGranted = false;
    const isBatteryExempt = false;

    return BackgroundReadinessReport(
      hasForegroundLocationPermission: hasForeground,
      hasBackgroundLocationPermission: isBackgroundGranted,
      hasNotificationPermission: isNotificationGranted,
      isBatteryOptimizationIgnored: isBatteryExempt,
      backgroundExecutionAssessment: 'Foreground monitoring is fully operational. Full background execution while screen is off requires Android Foreground Service notification and ACCESS_BACKGROUND_LOCATION permission.',
      requiredPermissionsForFullBackground: [
        'android.permission.ACCESS_BACKGROUND_LOCATION (Android 10+)',
        'android.permission.FOREGROUND_SERVICE (Android 9+)',
        'android.permission.FOREGROUND_SERVICE_LOCATION (Android 14+)',
        'android.permission.POST_NOTIFICATIONS (Android 13+)',
        'android.permission.RECEIVE_BOOT_COMPLETED (Persistence across reboot)',
      ],
      technicalLimitations: [
        'Android Doze mode aggressively limits background GPS polling unless a persistent foreground service with ongoing notification is maintained.',
        'Play Services Geofencing API is recommended for battery-efficient hardware-assisted boundary triggers when Google Play Services are present.',
        'Background execution cannot be guaranteed 100% on OEM customized Android builds (e.g. MIUI, ColorOS) without user manually disabling aggressive battery optimization.',
      ],
    );
  }

  void dispose() {
    stopMonitoring();
    _transitionController.close();
  }
}
