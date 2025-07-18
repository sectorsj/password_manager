// Дополнительная функция для отладки - показывает информацию о данных
import 'dart:typed_data';
import 'hash_parser.dart';

void debugPrintData(dynamic data, String name) {
  print('=== DEBUG INFO для $name ===');
  print('Тип: ${data.runtimeType}');

  if (data == null) {
    print('Значение: null');
  } else if (data is String) {
    print('Длина строки: ${data.length}');
    print('Содержимое: $data');
    print(
        'Первые 50 символов: ${data.length > 50 ? "${data.substring(0, 50)}..." : data}');
  } else if (data is Uint8List) {
    print('Длина массива: ${data.length}');
    print('Первые 20 байтов: ${data.take(20).toList()}');
    if (data.isNotEmpty) {
      try {
        final asString = String.fromCharCodes(data);
        print(
            'Как строка: ${asString.length > 100 ? "${asString.substring(0, 100)}..." : asString}');
      } catch (e) {
        print('Не удается конвертировать в строку: $e');
      }
    }
  } else if (data is List) {
    print('Длина списка: ${data.length}');
    print('Первые 10 элементов: ${data.take(10).toList()}');
  } else {
    print('Значение: $data');
  }
  print('=== END DEBUG INFO ===');
}

// Функция для тестирования парсинга (можно использовать для отладки)
void testParsing() {
  print('=== ТЕСТИРОВАНИЕ ФУНКЦИЙ ПАРСИНГА ===');

  // Тест 1: Объектный формат
  const test1 = '{98,102,180,137,155,245}';
  print('Тест 1: Объектный формат');
  final result1 = parseObjectFormat(test1, 'test1');
  print('Результат: $result1');

  // Тест 2: JSON массив
  const test2 = '[98,102,180,137,155,245]';
  print('Тест 2: JSON массив');
  final result2 = parseUint8ListFromDb(test2, 'test2');
  print('Результат: $result2');

  // Тест 3: Uint8List с объектным форматом
  final test3 =
      Uint8List.fromList([123, 57, 56, 44, 49, 48, 50, 125]); // '{98,102}'
  print('Тест 3: Uint8List с объектным форматом');
  final result3 = parseUint8ListFromDb(test3, 'test3');
  print('Результат: $result3');
  print('=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===');
}
