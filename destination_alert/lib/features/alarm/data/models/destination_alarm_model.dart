import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/alarm.dart';

/// Data model representing a serialized DestinationAlarm from Cloud Firestore.
class DestinationAlarmModel extends DestinationAlarm {
  const DestinationAlarmModel({
    required super.id,
    required super.destinationName,
    super.address,
    required super.latitude,
    required super.longitude,
    required super.radiusMeters,
    super.isEnabled,
    super.alarmTone,
    super.vibrate,
    required super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to parse a Firestore document snapshot or JSON map.
  factory DestinationAlarmModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return DestinationAlarmModel(
      id: docId ?? json['id'] as String? ?? '',
      destinationName:
          json['destinationName'] as String? ??
          json['title'] as String? ??
          'Destination',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 500.0,
      isEnabled:
          json['isEnabled'] as bool? ?? json['isActive'] as bool? ?? true,
      alarmTone: json['alarmTone'] as String? ?? 'Chime Alert',
      vibrate: json['vibrate'] as bool? ?? true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseNullableDate(json['updatedAt']),
    );
  }

  /// Converts this model to a Firestore-compatible JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationName': destinationName,
      'title': destinationName,
      'address': ?address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isEnabled': isEnabled,
      'isActive': isEnabled,
      'alarmTone': alarmTone,
      'vibrate': vibrate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory to convert domain entity to model.
  factory DestinationAlarmModel.fromEntity(DestinationAlarm alarm) {
    return DestinationAlarmModel(
      id: alarm.id,
      destinationName: alarm.destinationName,
      address: alarm.address,
      latitude: alarm.latitude,
      longitude: alarm.longitude,
      radiusMeters: alarm.radiusMeters,
      isEnabled: alarm.isEnabled,
      alarmTone: alarm.alarmTone,
      vibrate: alarm.vibrate,
      createdAt: alarm.createdAt,
      updatedAt: alarm.updatedAt,
    );
  }
}
