import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
      const FlutterSecureStorage(
        aOptions: AndroidOptions(
          resetOnError: true,
        ),
      );

  /// Reads a value securely. Catches Keystore platform failures.
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      await _handleKeystoreException(e);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Writes a key-value pair securely.
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      await _handleKeystoreException(e);
    }
  }

  /// Deletes a specific key.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      await _handleKeystoreException(e);
    }
  }

  /// Wipes all stored credentials on logout or Keystore corruption.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Ignore cleanup failures during forced wipe
    }
  }

  /// Handles native Android Keystore invalidation / hardware state changes.
  Future<void> _handleKeystoreException(PlatformException e) async {
    // When Keystore keys are invalidated, existing entries become permanently unreadable.
    // The safest recovery strategy is wiping corrupted storage so the user can re-authenticate cleanly.
    await deleteAll();
  }
}