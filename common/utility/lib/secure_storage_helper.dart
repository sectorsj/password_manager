import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _secureStorage = FlutterSecureStorage();
  static const _aesKeyName = 'aes_key';

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
