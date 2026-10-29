import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/core/errors/app_exception.dart';
import 'package:destination_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:destination_alert/features/auth/data/models/user_model.dart';
import 'package:destination_alert/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('Auth Integration & Fallback Tests', () {
    test('UnconfiguredAuthRemoteDataSource reports isConfigured as false', () {
      const dataSource = UnconfiguredAuthRemoteDataSource();
      expect(dataSource.isConfigured, isFalse);
      expect(dataSource.currentUser, isNull);
    });

    test('UnconfiguredAuthRemoteDataSource throws AuthConfigurationException on login', () async {
      const dataSource = UnconfiguredAuthRemoteDataSource();
      expect(
        () => dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthConfigurationException>()),
      );
    });

    test('AuthRepositoryImpl uses resolved datasource without crashing', () {
      final repository = AuthRepositoryImpl();
      expect(repository.currentUser, isNull);
    });

    test('UserModel serializes and deserializes Firestore JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'fire-user-999',
        'email': 'commuter@destination.app',
        'name': 'Active Commuter',
        'phoneNumber': '+1234567890',
        'photoUrl': 'https://destination.app/avatar.png',
        'createdAt': now.toIso8601String(),
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'fire-user-999');
      expect(user.email, 'commuter@destination.app');
      expect(user.name, 'Active Commuter');
      expect(user.phoneNumber, '+1234567890');
      expect(user.photoUrl, 'https://destination.app/avatar.png');

      final serialized = user.toJson();
      expect(serialized['id'], 'fire-user-999');
      expect(serialized['email'], 'commuter@destination.app');
      expect(serialized['phoneNumber'], '+1234567890');
    });
  });
}
