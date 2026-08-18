import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fire_notes/services/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService secureStorageService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Inject the mock storage into our service instance
    secureStorageService = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService Unit Tests', () {
    test('read returns value successfully when key exists', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'mock_token_123');

      final result = await secureStorageService.read('auth_token');

      expect(result, equals('mock_token_123'));
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('write saves key-value pair successfully', () async {
      when(() => mockStorage.write(key: 'key', value: 'value'))
          .thenAnswer((_) async => {});

      await secureStorageService.write('key', 'value');

      verify(() => mockStorage.write(key: 'key', value: 'value')).called(1);
    });

    test('read triggers deleteAll when Keystore PlatformException occurs', () async {
      // Simulate native Android Keystore key invalidation exception
      when(() => mockStorage.read(key: 'corrupted_key'))
          .thenThrow(PlatformException(code: 'KEYSTORE_CORRUPTED'));
      when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

      final result = await secureStorageService.read('corrupted_key');

      // The service should catch the exception, return null, and invoke deleteAll()
      expect(result, isNull);
      verify(() => mockStorage.deleteAll()).called(1);
    });
  });
}