import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class MiniEncrypt {
  static const int _ivLength = 12;
  final encrypt.Key _key;

  // Конструктор для создания из .env
  MiniEncrypt(Map<String, String> env) : _key = _loadKey(env);

  // Фабричный метод — создаёт EncryptionUtility из base64 AES ключа
  factory MiniEncrypt.fromBase64Key(String keyBase64) {
    final keyBytes = base64Decode(keyBase64);
    if (keyBytes.length != 32) {
      throw Exception('AES ключ должен быть 256-битным (32 байта)');
    }
    return MiniEncrypt._internal(encrypt.Key(keyBytes));
  }

  // Приватный внутренний конструктор
  MiniEncrypt._internal(this._key);

  // Загрузка ключа из .env
  static encrypt.Key _loadKey(Map<String, String> env) {
    final keyBase64 = env['APP_AES_KEY'];
    if (keyBase64 == null || keyBase64.isEmpty) {
      throw Exception('APP_AES_KEY не найден в .env');
    }

    try {
      final keyBytes = base64Decode(keyBase64);
      if (keyBytes.length != 32) {
        throw Exception('APP_AES_KEY должен быть длиной 256 бит (32 байта)');
      }
      return encrypt.Key(keyBytes);
    } catch (e) {
      throw Exception('Ошибка при декодировании APP_AES_KEY: $e');
    }
  }

  /// Шифрует строку и возвращает base64(IV + encrypted)
  String encryptText(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(_ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = Uint8List(_ivLength + encrypted.bytes.length);

    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(
        _ivLength, _ivLength + encrypted.bytes.length, encrypted.bytes);

    return base64Encode(combined);
  }
}

void main() {
  final keyBase64 =
      'NfIrSHcu5Cs3rhxHSATePLqUBRk60piKk1eB96hL9ec='; // Получить AES ключ
  final encryptionUtility = MiniEncrypt.fromBase64Key(keyBase64);

  // Ввод пароля
  final password = '100';
  final encryptedPassword = encryptionUtility.encryptText(password);

  print('Зашифрованный пароль (base64): $encryptedPassword');
}
