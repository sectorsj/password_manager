import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _aesKeyName = 'aes_key';
  static const _jwtTokenField = 'jwt_token';

  /// Позволяет подменить storage в тестах
  static void overrideStorage(FlutterSecureStorage mockStorage) {
    _secureStorage = mockStorage;
  }

  /// Сохраняет AES-ключ в безопасное хранилище
  static Future<void> setAesKey(String aesKey) async {
    await _secureStorage.write(key: _aesKeyName, value: aesKey);
  }

  /// Извлекает AES-ключ из хранилища
  static Future<String?> getAesKey() async {
    return await _secureStorage.read(key: _aesKeyName);
  }

  /// Удаляет AES-ключ
  static Future<void> deleteAesKey() async {
    await _secureStorage.delete(key: _aesKeyName);
  }

  /// Сохраняет JWT токен
  static Future<void> setJwtToken(String token) async {
    await _secureStorage.write(key: _jwtTokenField, value: token);
  }

  /// Получает JWT токен
  static Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: _jwtTokenField);
  }

  /// Удаляет JWT токен
  static Future<void> deleteJwtToken() async {
    await _secureStorage.delete(key: _jwtTokenField);
  }

  /// Полная очистка
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
