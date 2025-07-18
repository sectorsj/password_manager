import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';

class MiniHash {
  static const int PBKDF2_ITERATIONS = 100000; // Количество итераций
  static const int AES_KEY_LENGTH =
      32; // Длина AES ключа в байтах (256-битный ключ)
  static const int SALT_BYTES = 16; // Размер соли (16 байтов)

  MiniHash._(); // Приватный конструктор

  /// Генерация случайной соли
  static Uint8List generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(SALT_BYTES);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Генерация AES ключа из секретной фразы с использованием PBKDF2
  static Future<Uint8List> deriveAesKeyFromSecret(String secretPhrase) async {
    final salt = generateSalt(); // Генерация соли
    final aesKey = await _generatePBKDF2Hash(secretPhrase, salt);
    return aesKey;
  }

  /// Генерация PBKDF2 хэша для получения AES ключа
  static Future<Uint8List> _generatePBKDF2Hash(
      String password, Uint8List salt) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, PBKDF2_ITERATIONS, AES_KEY_LENGTH);
    pbkdf2.init(params);

    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    return pbkdf2.process(passwordBytes);
  }

  /// Конвертация Uint8List в base64 строку
  static String toBase64(Uint8List data) => base64.encode(data);

  /// Конвертация из base64 строки в Uint8List
  static Uint8List fromBase64(String encoded) => base64.decode(encoded);
}

void main() async {
  final secretPhrase = 'Alice'; // Секретная фраза

  final aesKey = await MiniHash.deriveAesKeyFromSecret(secretPhrase);

  final base64AesKey = MiniHash.toBase64(aesKey);
  print('Генерированный AES ключ (base64): $base64AesKey');
}
