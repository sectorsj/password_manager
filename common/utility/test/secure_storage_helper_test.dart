import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:common_utility_package/secure_storage_helper.dart';

import 'secure_storage_helper_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    SecureStorageHelper.overrideStorage(mockStorage); // добавим такую функцию
  });

  test('setAesKey сохраняет значение', () async {
    const testKey = 'test_key';

    when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
        .thenAnswer((_) async => null);

    await SecureStorageHelper.setAesKey(testKey);

    verify(mockStorage.write(key: 'aes_key', value: testKey)).called(1);
  });

  test('getAesKey возвращает сохранённое значение', () async {
    const storedKey = 'stored_key';

    when(mockStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => storedKey);

    final result = await SecureStorageHelper.getAesKey();

    expect(result, storedKey);
    verify(mockStorage.read(key: 'aes_key')).called(1);
  });

  test('deleteAesKey удаляет ключ', () async {
    when(mockStorage.delete(key: anyNamed('key')))
        .thenAnswer((_) async => null);

    await SecureStorageHelper.deleteAesKey();

    verify(mockStorage.delete(key: 'aes_key')).called(1);
  });
}
