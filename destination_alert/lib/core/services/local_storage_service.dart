import 'dart:async';

/// Local key-value storage service for persisting application settings,
/// onboarding completion flags, and cached session metadata.
class LocalStorageService {
  static LocalStorageService? _instance;
  final Map<String, dynamic> _memoryStore = <String, dynamic>{};
  bool _isInitialized = false;

  LocalStorageService._();

  /// Singleton accessor.
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  /// Initialize local storage service.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Whether onboarding has been completed by the user.
  bool get isOnboardingCompleted =>
      getBool('has_completed_onboarding') ?? false;

  /// Sets whether onboarding has been completed.
  Future<bool> setOnboardingCompleted(bool value) async {
    return setBool('has_completed_onboarding', value);
  }

  /// Retrieves a boolean value for [key], or null if absent.
  bool? getBool(String key) {
    final value = _memoryStore[key];
    if (value is bool) return value;
    return null;
  }

  /// Stores a boolean [value] for [key].
  Future<bool> setBool(String key, bool value) async {
    _memoryStore[key] = value;
    return true;
  }

  /// Retrieves a string value for [key], or null if absent.
  String? getString(String key) {
    final value = _memoryStore[key];
    if (value is String) return value;
    return null;
  }

  /// Stores a string [value] for [key].
  Future<bool> setString(String key, String value) async {
    _memoryStore[key] = value;
    return true;
  }

  /// Removes a value by [key].
  Future<bool> remove(String key) async {
    _memoryStore.remove(key);
    return true;
  }

  /// Clears all keys in the store (e.g. on full reset).
  Future<bool> clear() async {
    _memoryStore.clear();
    return true;
  }
}
