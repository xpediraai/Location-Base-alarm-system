import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/alarm/data/models/destination_alarm_model.dart';

/// Database service for managing Cloud Firestore collections:
/// - `users`: User profiles and settings
/// - `users/{userId}/alarms`: Geofence / location-based destination alarms
/// - `users/{userId}/saved_locations`: Favorite / quick-access places
/// - `users/{userId}/history`: Travel trip history and triggered alarm records
class FirestoreDatabaseService {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  static FirestoreDatabaseService? _instance;

  FirestoreDatabaseService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _customFirestore = firestore,
      _customAuth = auth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  /// Singleton accessor
  static FirestoreDatabaseService get instance {
    _instance ??= FirestoreDatabaseService();
    return _instance!;
  }

  /// Current authenticated user ID
  String? get currentUserId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------
  // USER PROFILE
  // -------------------------------------------------------------

  /// Stream of the user profile document
  Stream<DocumentSnapshot<Map<String, dynamic>>?> userProfileStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Updates profile metadata in Firestore
  Future<void> updateUserProfile({
    required String name,
    String? phoneNumber,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('User not authenticated');

    final data = <String, dynamic>{
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
      'phoneNumber': ?phoneNumber,
      'photoUrl': ?photoUrl,
      ...?additionalData,
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // -------------------------------------------------------------
  // DESTINATION ALARMS (users/{uid}/destinationAlarms)
  // -------------------------------------------------------------

  /// Type-safe stream of destination alarms for the active user.
  Stream<List<DestinationAlarmModel>> destinationAlarmsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('destinationAlarms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DestinationAlarmModel.fromJson(doc.data(), docId: doc.id);
          }).toList();
        });
  }

  /// Add or update a destination alarm
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
    final uid = currentUserId;
    if (uid == null) throw StateError('User not authenticated');

    final col = _firestore
        .collection('users')
        .doc(uid)
        .collection('destinationAlarms');
    final docRef = alarmId != null ? col.doc(alarmId) : col.doc();

    final payload = <String, dynamic>{
      'id': docRef.id,
      'destinationName': destinationName,
      'title': destinationName,
      'address': ?address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isEnabled': isEnabled,
      'isActive': isEnabled,
      'alarmTone': alarmTone ?? 'Chime Alert',
      'vibrate': vibrate,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (alarmId == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
    return docRef.id;
  }

  /// Toggle alarm enabled status
  Future<void> toggleAlarmStatus(String alarmId, bool isEnabled) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('destinationAlarms')
        .doc(alarmId)
        .update({
          'isEnabled': isEnabled,
          'isActive': isEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Delete an alarm
  Future<void> deleteAlarm(String alarmId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('destinationAlarms')
        .doc(alarmId)
        .delete();
  }

  // -------------------------------------------------------------
  // SAVED LOCATIONS (Home, Work, Station, etc.)
  // -------------------------------------------------------------

  /// Stream of saved locations
  Stream<QuerySnapshot<Map<String, dynamic>>> savedLocationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_locations')
        .orderBy('name')
        .snapshots();
  }

  /// Save a favorite location
  Future<String> saveLocation({
    String? locationId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? tag, // e.g. "Home", "Work", "Station", "Other"
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('User not authenticated');

    final col = _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_locations');
    final docRef = locationId != null ? col.doc(locationId) : col.doc();

    final payload = <String, dynamic>{
      'id': docRef.id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'tag': ?tag,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (locationId == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
    return docRef.id;
  }

  /// Delete a saved location
  Future<void> deleteSavedLocation(String locationId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_locations')
        .doc(locationId)
        .delete();
  }

  // -------------------------------------------------------------
  // TRIP HISTORY
  // -------------------------------------------------------------

  /// Record completed trip / triggered alarm into history
  Future<void> recordTripHistory({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime triggeredAt,
    Duration? tripDuration,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('history').add({
      'destinationName': destinationName,
      'latitude': latitude,
      'longitude': longitude,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      if (tripDuration != null) 'tripDurationSeconds': tripDuration.inSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of trip history
  Stream<QuerySnapshot<Map<String, dynamic>>> tripHistoryStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('triggeredAt', descending: true)
        .snapshots();
  }
}
