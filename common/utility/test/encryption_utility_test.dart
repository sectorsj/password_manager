import 'dart:io';

import 'package:common_utility_package/encryption_utility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  print('Working dir: ${Directory.current.path}');
  const dummyKeyBase64 =
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; // 32 байта
  late EncryptionUtility encryptionUtility;

  setUp(() {
    encryptionUtility = EncryptionUtility.fromBase64(dummyKeyBase64);
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
