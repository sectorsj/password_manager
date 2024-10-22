import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';

class HashingUtility {
  static const int PBKDF2_ITERATIONS = 1000;
  static const int SALT_BYTES = 16;
  static const int HASH_BYTES = 32;

  HashingUtility._(); // Приватный конструктор


  // Асинхронная функция для хэширования пароля
  static Future<Map<String, String>> hashPassword(String password) async {
    final salt = generateSalt();
    final hash = await generatePBKDF2Hash(password, salt);
    return {'salt': salt, 'hash': hash};
  }


  // Генерация соли
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = Uint8List(SALT_BYTES);
    for (var i = 0; i < saltBytes.length; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    return base64.encode(saltBytes);
  }


  // Асинхронная функция для генерации хэша PBKDF2
  static Future<String> generatePBKDF2Hash(String password, String salt) async {
    final params = Pbkdf2Parameters(base64.decode(salt), PBKDF2_ITERATIONS, HASH_BYTES);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(params);

    final passwordBytes = utf8.encode(password);
    final key = pbkdf2.process(Uint8List.fromList(passwordBytes));
    return base64.encode(key);
  }


  // Асинхронная проверка пароля
  static Future<bool> verifyPassword(String password, String salt, String hash) async {
    final generatedHash = await generatePBKDF2Hash(password, salt);
    return hash == generatedHash;
  }


  // static String generatePBKDF2HashSync(String password, String salt) {
  //   final params = Pbkdf2Parameters(base64.decode(salt), PBKDF2_ITERATIONS, HASH_BYTES);
  //   final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  //   pbkdf2.init(params);
  //
  //   final passwordBytes = utf8.encode(password);
  //   final key = pbkdf2.process(Uint8List.fromList(passwordBytes));
  //   return base64.encode(key);
  // }
}