import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:dotenv/dotenv.dart';

class EncryptionUtility {
  static const int _ivLength = 12;
  final Key _key;

  EncryptionUtility(DotEnv env) : _key = _loadKey(env);

  factory EncryptionUtility.fromEnv() {
    final env = DotEnv()..load(); // Загружает .env автоматически
    return EncryptionUtility(env);
  }

  /// Получаем ключ из .env
  static Key _loadKey(DotEnv env) {
    final keyBase64 = env['APP_AES_KEY'];
    if (keyBase64 == null || keyBase64.isEmpty) {
      throw Exception('APP_AES_KEY не найден в .env');
    }

    try {
      final keyBytes = base64Decode(keyBase64);
      if (keyBytes.length != 32) {
        throw Exception('APP_AES_KEY должен быть длиной 256 бит (32 байта)');
      }
      return Key(keyBytes);
    } catch (e) {
      throw Exception('Ошибка при декодировании APP_AES_KEY: $e');
    }
  }

  /// Шифрует строку и возвращает base64(IV + encrypted)
  String encryptText(String plainText) {
    final iv = IV.fromSecureRandom(_ivLength);
    final encrypter = Encrypter(
      AES(_key, mode: AESMode.gcm),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List(_ivLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(
        _ivLength, _ivLength + encrypted.bytes.length, encrypted.bytes);

    return base64Encode(combined);
  }

  /// Расшифровывает строку, зашифрованную encryptText()
  String decryptText(String base64Combined) {
    final combined = base64Decode(base64Combined);
    if (combined.length < _ivLength) {
      throw ArgumentError('Недопустимая длина зашифрованных данных');
    }

    final iv = IV(combined.sublist(0, _ivLength));
    final encryptedBytes = combined.sublist(_ivLength);

    final encrypter = Encrypter(
      AES(_key, mode: AESMode.gcm),
    );

    return encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
  }
}
