import 'package:flutter_test/flutter_test.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

void main() {
  const password = 'MyVeryStrongPassword123!';
  const wrongPassword = 'WrongPassword456!';

  late Map<String, String> hashedData;

  setUp(() async {
    final raw = await HashingUtility.hashPassword(password);
    hashedData = {
      'salt': HashingUtility.toBase64(raw['salt']!),
      'hash': HashingUtility.toBase64(raw['hash']!),
    };
  });

  test('Хеш и соль не пустые и корректной длины', () {
    expect(hashedData['hash'], isNotNull);
    expect(hashedData['salt'], isNotNull);
    expect(hashedData['hash']!.length >= 44, isTrue); // base64(32 байта)
    expect(hashedData['salt']!.length >= 22, isTrue); // base64(16 байт)
  });

  test('Пароль корректно верифицируется', () async {
    final result = await HashingUtility.verifyPassword(
      password,
      HashingUtility.fromBase64(hashedData['salt']!),
      HashingUtility.fromBase64(hashedData['hash']!),
    );

    expect(result, isTrue);
  });

  test('Неверный пароль не проходит проверку', () async {
    final result = await HashingUtility.verifyPassword(
      wrongPassword,
      HashingUtility.fromBase64(hashedData['salt']!),
      HashingUtility.fromBase64(hashedData['hash']!),
    );

    expect(result, isFalse);
  });

  test('Одинаковый пароль с разной солью даёт разные хеши', () async {
    final first = await HashingUtility.hashPassword(password);
    final second = await HashingUtility.hashPassword(password);

    expect(HashingUtility.toBase64(first['hash']!),
        isNot(equals(HashingUtility.toBase64(second['hash']!))));
    expect(HashingUtility.toBase64(first['salt']!),
        isNot(equals(HashingUtility.toBase64(second['salt']!))));
  });
}
