import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class HashingUtility {
  static const int PBKDF2_ITERATIONS = 100000;
  static const int AES_KEY_LENGTH = 32; // 256-bit AES
  static const int PASSWORD_HASH_LENGTH = 32;
  static const int SALT_BYTES = 16;

  HashingUtility._();

  /// 🔐 Универсальный PBKDF2-генератор
  static Uint8List generatePBKDF2Hash(
      String input, Uint8List salt, int length) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, PBKDF2_ITERATIONS, length);
    pbkdf2.init(params);

    final inputBytes = Uint8List.fromList(utf8.encode(input));
    return pbkdf2.process(inputBytes);
  }

  // ===============================
  // 🔐 AES KEY из секретной фразы
  // ===============================

  /// Стабильная соль на основе фразы
  static Uint8List generateDeterministicSalt(String secretPhrase) {
    final input = utf8.encode('${secretPhrase}salt_suffix');
    final hash = SHA256Digest().process(Uint8List.fromList(input));
    return Uint8List.sublistView(hash, 0, SALT_BYTES);
  }

  /// AES-ключ (256 бит) из фразы
  static Uint8List deriveAesKeyFromSecret(String secretPhrase) {
    final salt = generateDeterministicSalt(secretPhrase);
    return generatePBKDF2Hash(secretPhrase, salt, AES_KEY_LENGTH);
  }

  // ====================================
  // 🔐 Хэш пароля с рандомной солью
  // ====================================

  /// Генерация соли (рандом)
  static Uint8List generateSalt() {
    final rand = Random.secure();
    return Uint8List.fromList(
        List.generate(SALT_BYTES, (_) => rand.nextInt(256)));
  }

  /// Генерация хэша пароля + соль
  static Map<String, String> hashPassword(String password) {
    final salt = generateSalt();
    final hash = generatePBKDF2Hash(password, salt, PASSWORD_HASH_LENGTH);

    return {
      'salt': base64.encode(salt),
      'hash': base64.encode(hash),
    };
  }

  /// Проверка пароля
  static bool verifyPassword(
      String password, String storedSalt, String storedHash) {
    final salt = base64.decode(storedSalt);
    final hash = generatePBKDF2Hash(password, salt, PASSWORD_HASH_LENGTH);
    return base64.encode(hash) == storedHash;
  }

  // ===============================
  // 🔄 Конвертеры
  // ===============================

  static String toBase64(Uint8List data) => base64.encode(data);

  static Uint8List fromBase64(String encoded) => base64.decode(encoded);
}
