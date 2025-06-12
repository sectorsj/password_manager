import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _aesKeyName = 'aes_key';

  /// Позволяет подменить storage в тестах
  static void overrideStorage(FlutterSecureStorage mockStorage) {
    _secureStorage = mockStorage;
  }

  static Future<String?> getAesKey() async {
    return await _secureStorage.read(key: _aesKeyName);
  }

  static Future<void> setAesKey(String value) async {
    await _secureStorage.write(key: _aesKeyName, value: value);
  }

  static Future<void> deleteAesKey() async {
    await _secureStorage.delete(key: _aesKeyName);
  }
}
