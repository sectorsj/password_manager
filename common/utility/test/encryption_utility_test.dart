import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hashing_utility_package/encryption_utility.dart';

void main() {
  print('Working dir: ${Directory.current.path}');
  const dummyKeyBase64 =
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; // 32 байта
  late EncryptionUtility encryptionUtility;

  setUp(() {
    encryptionUtility = EncryptionUtility.fromBase64Key(dummyKeyBase64);
  });

  test('Шифрование и расшифровка строки', () {
    const plainText = 'superSecret123!';
    final encrypted = encryptionUtility.encryptText(plainText);
    final decrypted = encryptionUtility.decryptText(encrypted);
    expect(decrypted, plainText);
  });

  test('Шифрование должно давать разный результат при каждом вызове', () {
    const text = 'sameText';
    final encrypted1 = encryptionUtility.encryptText(text);
    final encrypted2 = encryptionUtility.encryptText(text);
    expect(encrypted1 == encrypted2, isFalse); // IV должен быть разный
  });
}
