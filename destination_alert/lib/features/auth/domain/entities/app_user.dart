/// App user domain entity representing an authenticated user.
class AppUser {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(id, email, name, phoneNumber, photoUrl);

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, name: $name, phoneNumber: $phoneNumber)';
  }
}
