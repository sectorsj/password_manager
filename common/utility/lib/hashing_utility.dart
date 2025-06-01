import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';

class HashingUtility {
  static const int PBKDF2_ITERATIONS = 100000;
  static const int SALT_BYTES = 16;
  static const int HASH_BYTES = 32;

  HashingUtility._(); // Приватный конструктор

  /// Генерирует соль в виде Uint8List
  static Uint8List generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(SALT_BYTES);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Хэширует пароль и возвращает хэш и соль
  static Future<Map<String, Uint8List>> hashPassword(String password) async {
    final salt = generateSalt();
    final hash = await _generatePBKDF2Hash(password, salt);
    return {'salt': salt, 'hash': hash};
  }

  /// Генерация PBKDF2-хэша
  static Future<Uint8List> _generatePBKDF2Hash(String password, Uint8List salt) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, PBKDF2_ITERATIONS, HASH_BYTES);
    pbkdf2.init(params);

    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    return pbkdf2.process(passwordBytes);
  }

  /// Проверка пароля: сравнение хэшей
  static Future<bool> verifyPassword(String password, Uint8List salt, Uint8List expectedHash) async {
    final actualHash = await _generatePBKDF2Hash(password, salt);
    if (actualHash.length != expectedHash.length) return false;

    // Защита от timing attacks
    int diff = 0;
    for (int i = 0; i < actualHash.length; i++) {
      diff |= actualHash[i] ^ expectedHash[i];
    }
    return diff == 0;
  }

  /// Утилиты для конвертации
  static String toBase64(Uint8List data) => base64.encode(data);
  static Uint8List fromBase64(String encoded) => base64.decode(encoded);
}