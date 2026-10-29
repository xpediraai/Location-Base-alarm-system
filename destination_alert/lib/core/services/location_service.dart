import 'package:geolocator/geolocator.dart';

/// Enum representing the outcome of a location check / permission request.
enum LocationStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  ready,
}

/// Service managing device GPS location and location permissions.
class LocationService {
  static LocationService? _instance;

  LocationService._();

  /// Default factory constructor returning singleton instance
  factory LocationService() => instance;

  /// Singleton accessor
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  /// Checks if location services (GPS) are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Checks current location permission without prompting the user.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Requests location permission from the operating system.
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Evaluates readiness and prompts for permission if needed.
  Future<LocationStatus> verifyLocationReadiness() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }

    return LocationStatus.ready;
  }

  /// Gets the current device GPS position.
  ///
  /// Throws an exception if services are disabled or permissions are missing.
  Future<Position?> getCurrentPosition() async {
    final readiness = await verifyLocationReadiness();
    if (readiness != LocationStatus.ready) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      // Fallback to last known position if active fix timed out
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Calculates geodesic distance between two points in meters using the WGS-84 ellipsoid.
  double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Opens application settings page.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Opens device location settings page.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}
