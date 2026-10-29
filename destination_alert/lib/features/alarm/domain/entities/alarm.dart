/// Domain entity representing a location-based destination alarm.
class DestinationAlarm {
  final String id;
  final String destinationName;
  final String? address;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isEnabled;
  final String alarmTone;
  final bool vibrate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DestinationAlarm({
    required this.id,
    required this.destinationName,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.isEnabled = true,
    this.alarmTone = 'Chime Alert',
    this.vibrate = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Formatted radius display (e.g. "500 m" or "1.5 km").
  String get formattedRadius {
    if (radiusMeters >= 1000) {
      final km = radiusMeters / 1000;
      return '${km.toStringAsFixed(km.truncateToDouble() == km ? 0 : 1)} km';
    }
    return '${radiusMeters.toInt()} m';
  }

  DestinationAlarm copyWith({
    String? id,
    String? destinationName,
    String? address,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isEnabled,
    String? alarmTone,
    bool? vibrate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DestinationAlarm(
      id: id ?? this.id,
      destinationName: destinationName ?? this.destinationName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isEnabled: isEnabled ?? this.isEnabled,
      alarmTone: alarmTone ?? this.alarmTone,
      vibrate: vibrate ?? this.vibrate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
