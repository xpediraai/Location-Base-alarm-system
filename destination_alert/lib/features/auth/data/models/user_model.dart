import '../../domain/entities/app_user.dart';

/// Data model representing a serialized user from remote datasource or local cache.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    super.photoUrl,
    super.createdAt,
  });

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name:
          json['fullName'] as String? ??
          json['name'] as String? ??
          json['displayName'] as String? ??
          '',
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Converts this model to a JSON map for Cloud Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'id': id,
      'fullName': name,
      'name': name,
      'email': email,
      'phoneNumber': ?phoneNumber,
      'photoUrl': ?photoUrl,
      'createdAt': ?createdAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a [UserModel] from domain entity [AppUser].
  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
    );
  }
}
