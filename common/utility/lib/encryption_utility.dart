import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:common_utility_package/hashing_utility.dart';

class EncryptionUtility {
  static const int _ivLength = 12;
  final encrypt.Key _key;

  /// Внутренний приватный конструктор
  EncryptionUtility._(this._key);

  // =============================================
  // 🔐 Конструктор 1: из .env (например, для лицензии)
  // =============================================
  factory EncryptionUtility.fromEnv(Map<String, String> env) {
    final keyBase64 = env['APP_AES_KEY'];
    if (keyBase64 == null || keyBase64.isEmpty) {
      throw Exception('APP_AES_KEY не найден в .env');
    }

    final keyBytes = base64Decode(keyBase64);
    if (keyBytes.length != 32) {
      throw Exception('APP_AES_KEY должен быть длиной 256 бит (32 байта)');
    }

    return EncryptionUtility._(encrypt.Key(keyBytes));
  }

  // =============================================
  // 🔐 Конструктор 2: из секретной фразы пользователя
  // =============================================
  factory EncryptionUtility.fromSecretPhrase(String secretPhrase) {
    final aesKey = HashingUtility.deriveAesKeyFromSecret(secretPhrase);
    return EncryptionUtility._(encrypt.Key(aesKey));
  }

  // =============================================
  // 🔐 Конструктор 3: напрямую из base64 AES ключа
  // =============================================
  factory EncryptionUtility.fromBase64(String keyBase64) {
    final keyBytes = base64Decode(keyBase64);
    if (keyBytes.length != 32) {
      throw Exception('AES ключ должен быть длиной 256 бит (32 байта)');
    }
    return EncryptionUtility._(encrypt.Key(keyBytes));
  }

  // =============================================
  // 🔒 Шифрование строки: возвращает base64(IV + encrypted)
  // =============================================
  String encryptText(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(_ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List(_ivLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(_ivLength, combined.length, encrypted.bytes);

    return base64Encode(combined);
  }

  // =============================================
  // 🔓 Расшифровка строки: принимает base64(IV + encrypted)
  // =============================================
  String decryptText(String base64Combined) {
    final combined = base64Decode(base64Combined);
    if (combined.length < _ivLength) {
      throw ArgumentError('Недопустимая длина зашифрованных данных');
    }

    final iv = encrypt.IV(combined.sublist(0, _ivLength));
    final encryptedBytes = combined.sublist(_ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));

    return encrypter.decrypt(encrypt.Encrypted(encryptedBytes), iv: iv);
  }
}
