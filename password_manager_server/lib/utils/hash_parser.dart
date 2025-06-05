import 'dart:convert';
import 'dart:typed_data';

// Основная функция для парсинга Uint8List из различных форматов данных БД
Uint8List? parseUint8ListFromDb(dynamic rawData, String fieldName) {
  try {
    print('Обрабатываем $fieldName, тип: ${rawData.runtimeType}');

    if (rawData is Uint8List) {
      // Данные уже в правильном формате
      if (rawData.isNotEmpty && rawData[0] == 123) {
        // ASCII код '{'
        // Это объектный формат в виде байтов {98,102,180,...}
        final jsonString = String.fromCharCodes(rawData);
        print('Обнаружен объектный формат для $fieldName: $jsonString');

        return parseObjectFormat(jsonString, fieldName);
      } else {
        // Это настоящие бинарные данные
        print(
            'Настоящие бинарные данные для $fieldName, длина: ${rawData.length}');
        return rawData;
      }
    } else if (rawData is String) {
      print('Строковые данные для $fieldName: $rawData');

      // Проверяем, не является ли это объектным форматом {98,102,180,...}
      if (rawData.startsWith('{') && rawData.endsWith('}')) {
        print('Обнаружен объектный формат в строке для $fieldName');
        return parseObjectFormat(rawData, fieldName);
      }

      // Проверяем на массив JSON [98,102,180,...]
      if (rawData.startsWith('[') && rawData.endsWith(']')) {
        try {
          print('Пробуем парсить как JSON массив для $fieldName');
          final List<dynamic> dataList = jsonDecode(rawData);
          return Uint8List.fromList(dataList.cast<int>());
        } catch (e) {
          print('Ошибка парсинга JSON массива для $fieldName: $e');
        }
      }

      // Пробуем base64
      try {
        print('Пробуем декодировать как base64 для $fieldName');
        return base64Decode(rawData);
      } catch (e) {
        print('Не удалось декодировать как base64 для $fieldName: $e');
      }
    } else if (rawData is List) {
      print('Список данных для $fieldName, длина: ${rawData.length}');
      return Uint8List.fromList(rawData.cast<int>());
    } else {
      print('Неожиданный тип данных для $fieldName: ${rawData.runtimeType}');
    }
  } catch (e, stack) {
    print('Критическая ошибка при обработке $fieldName: $e');
    print('Сырые данные: $rawData');
    print('Тип данных: ${rawData.runtimeType}');
    if (rawData is Uint8List) {
      print('Первые 20 байтов: ${rawData.take(20).toList()}');
      print('Как строка: ${String.fromCharCodes(rawData)}');
    }
    print('Stack trace: $stack');
  }

  print('Не удалось обработать данные для $fieldName');
  return null;
}

// Функция для парсинга объектного формата {98,102,180,...}
Uint8List? parseObjectFormat(String data, String fieldName) {
  try {
    print('Начинаем парсинг объектного формата для $fieldName');
    print('Входные данные: $data');

    // Проверяем базовый формат
    if (!data.startsWith('{') || !data.endsWith('}')) {
      print('Неверный формат: должен начинаться с { и заканчиваться }');
      return null;
    }

    // Убираем фигурные скобки
    final content = data.substring(1, data.length - 1).trim();
    print('Содержимое без скобок: $content');

    if (content.isEmpty) {
      print('Пустое содержимое для $fieldName');
      return Uint8List(0);
    }

    // Разделяем по запятым
    final parts = content.split(',');
    print('Количество частей: ${parts.length}');

    // Конвертируем каждую часть в число
    final numbers = <int>[];
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i].trim();
      if (part.isEmpty) {
        print('Пустая часть на позиции $i, пропускаем');
        continue;
      }

      try {
        final number = int.parse(part);
        if (number < 0 || number > 255) {
          print('Число $number на позиции $i выходит за пределы байта (0-255)');
          return null;
        }
        numbers.add(number);
      } catch (e) {
        print('Ошибка парсинга числа "$part" на позиции $i: $e');
        return null;
      }
    }

    print('Успешно извлечено ${numbers.length} чисел для $fieldName');
    print('Первые 10 чисел: ${numbers.take(10).toList()}');
    if (numbers.length > 10) {
      print('Последние 5 чисел: ${numbers.skip(numbers.length - 5).toList()}');
    }

    final result = Uint8List.fromList(numbers);
    print('Создан Uint8List для $fieldName, размер: ${result.length} байт');

    return result;
  } catch (e, stack) {
    print(
        'Критическая ошибка при парсинге объектного формата для $fieldName: $e');
    print('Входные данные: $data');
    print('Stack trace: $stack');
    return null;
  }
}
