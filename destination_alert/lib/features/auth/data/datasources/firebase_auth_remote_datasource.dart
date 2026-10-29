import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Firebase Authentication and Cloud Firestore implementation of [AuthRemoteDataSource].
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  bool get isConfigured => Firebase.apps.isNotEmpty;

  @override
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('User credentials could not be loaded.');
      }

      // Attempt to load full user profile from Cloud Firestore
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (_) {
        // Fallback to Firebase Auth user properties if Firestore is offline
      }

      final fallbackUser = UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? email.split('@').first,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
      );

      // Self-heal: ensure Firestore document exists
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(fallbackUser.toJson(), SetOptions(merge: true));
      } catch (_) {}

      return fallbackUser;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('An unexpected error occurred during login: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Could not create user account.');
      }

      // Update displayName on Firebase Auth profile
      await user.updateDisplayName(name);

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      // Persist profile into Cloud Firestore
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson(), SetOptions(merge: true));
      } catch (e) {
        // Handle partial failure safely
        throw const AuthException(
          'Account created, but profile setup failed. Please try signing in again or check connection.',
        );
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
        'An unexpected error occurred during registration: $e',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'invalid-email':
        return const AuthException(
          'The email address is improperly formatted.',
        );
      case 'weak-password':
        return AuthException(
          e.message ??
              'The password is too weak. Please use at least 6 characters.',
        );
      case 'user-disabled':
        return const AuthException('This user account has been disabled.');
      case 'too-many-requests':
        return const AuthException(
          'Too many failed attempts. Please try again in a few moments.',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'Email/Password sign-in is not enabled in Firebase Console. Please enable it under Authentication > Sign-in method.',
        );
      case 'network-request-failed':
        return const NetworkException();
      default:
        return AuthException(e.message ?? 'Authentication failed (${e.code}).');
    }
  }
}
