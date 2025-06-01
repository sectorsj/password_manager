import 'dart:convert';
import 'dart:typed_data';

import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

final dotenv = DotEnv();

void main() async {
  dotenv.load(['.env']);
  final connection = await createConnection();
  final router = Router();

  // === РЕГИСТРАЦИЯ АККАУНТА ===
  router.post('/register', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final accountLogin = data['account_login'] as String;
      final userName = data['user_name'] as String;
      final emailAddress = data['email_address'] as String;
      final passwordHashBase64 = data['password_hash'] as String;
      final saltBase64 = data['salt'] as String;

      final passwordHash = base64Decode(passwordHashBase64);
      final salt = base64Decode(saltBase64);

      final userPhone = data['user_phone'] as String?;
      final userDescription = data['user_description'] as String?;

      try {
        final registerResult = await connection.execute(
          Sql.named('SELECT * FROM create_account_with_user_and_email('
              '@account_login, @email_address, @password_hash, @salt, '
              '@user_name, @user_phone, @user_description)'),
          parameters: {
            'account_login': accountLogin,
            'email_address': emailAddress,
            'password_hash': passwordHash,
            'salt': salt,
            'user_name': userName,
            'user_phone': userPhone,
            'user_description': userDescription,
          },
        );

        if (registerResult.isEmpty) {
          return Response.internalServerError(
            body: 'Ошибка при создании аккаунта',
          );
        }

        final row = registerResult.first;
        final accountId = row[0] as int;
        final userId = row[1] as int;

        print('Пользователь зарегистрирован: account_id=$accountId, логин=$accountLogin');

        return Response.ok(
          jsonEncode({
            'message': 'Регистрация прошла успешно',
            'account_id': accountId,
            'user_id': userId,
            'account_email': emailAddress,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stackTrace) {
        print('Ошибка при регистрации: $e');
        print(stackTrace);
        return Response.internalServerError(body: 'Ошибка при регистрации');
      }
  });

  // === АВТОРИЗАЦИЯ АККАУНТА ===
  router.post('/login', (Request request) async {
    try {
      final data = await request.readAsString();
      final body = jsonDecode(data);

      final accountLogin = body['account_login'];
      final password = body['password'];

      if (accountLogin == null || password == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Необходимо указать логин и пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Попытка входа с логином: $accountLogin');

      // SQL запрос - добавляем получение user_id
      final result = await connection.execute(
        Sql.named('''
        SELECT 
          a.id, 
          a.account_email, 
          a.password_hash, 
          a.salt,
          u.id as user_id
        FROM accounts a
        LEFT JOIN users u ON a.id = u.account_id
        WHERE a.account_login = @accountLogin
      '''),
        parameters: {'accountLogin': accountLogin},
      );


      if (result.isEmpty) {
        print('Пользователь с логином "$accountLogin" не найден в БД');

        // Проверим, какие логины есть в БД (для отладки)
        final allAccounts = await connection.execute('SELECT account_login FROM accounts LIMIT 10');
        print('Существующие логины в БД:');
        for (final account in allAccounts) {
          print('  - "${account.toColumnMap()['account_login']}"');
        }

        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      final storedHashRaw = row['password_hash'];
      final storedSaltRaw = row['salt'];

      print('Найден пользователь с логином: $accountLogin');
      print('Тип storedHashRaw: ${storedHashRaw.runtimeType}');
      print('Тип storedSaltRaw: ${storedSaltRaw.runtimeType}');

      // Обработка различных форматов данных из БД
      final storedHash = _parseUint8ListFromDb(storedHashRaw, 'hash');
      final storedSalt = _parseUint8ListFromDb(storedSaltRaw, 'salt');

      if (storedHash == null || storedSalt == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Ошибка обработки данных'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Проверяем пароль для пользователя: $accountLogin');

      final passwordMatch = await HashingUtility.verifyPassword(
        password,
        storedSalt,
        storedHash,
      );

      if (!passwordMatch) {
        print('Неверный пароль для логина: $accountLogin');
        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Авторизация успешна для пользователя: $accountLogin');

      // ИСПРАВЛЕННЫЙ ответ - добавляем userId с проверкой на null
      return Response.ok(
        jsonEncode({
          'message': 'Авторизация прошла успешно',
          'account_id': row['id'] ?? 0,
          'user_id': row['user_id'] ?? 0, // Добавляем userId
          'account_email': row['account_email'] ?? '',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при логине: $e$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при авторизации'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Добавьте эти эндпоинты в ваш router (после существующих маршрутов)

// === ПОЛУЧЕНИЕ ДАННЫХ АККАУНТА ===
  // === ПОЛУЧЕНИЕ ИНФОРМАЦИИ ОБ АККАУНТЕ ===
  router.get('/accounts/<id>', (Request request, String id) async {
    try {
      final accountId = int.tryParse(id);

      if (accountId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Неверный ID аккаунта'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Запрос информации об аккаунте с ID: $accountId');

      final result = await connection.execute(
        Sql.named('''
        SELECT 
          a.id,
          a.account_login,
          a.account_email,
          u.user_name,
          u.user_phone,
          u.user_description
        FROM accounts a
        LEFT JOIN users u ON a.id = u.account_id
        WHERE a.id = @accountId
      '''),
        parameters: {'accountId': accountId},
      );

      if (result.isEmpty) {
        print('Аккаунт с ID $accountId не найден');
        return Response.notFound(
          jsonEncode({'error': 'Аккаунт не найден'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      print('Найден аккаунт: ${row['account_login']}');

      return Response.ok(
        jsonEncode({
          'id': row['id'],
          'accountLogin': row['account_login'],
          'accountEmail': row['account_email'],
          'userName': row['user_name'],
          'userPhone': row['user_phone'],
          'userDescription': row['user_description'],
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e, stack) {
      print('Ошибка при получении аккаунта: $e');
      print('Stack trace: $stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении данных аккаунта'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

// === ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ ===
  router.get('/users/<id>', (Request request, String id) async {
    try {
      final userId = int.parse(id);

      final result = await connection.execute(
        Sql.named('''
        SELECT 
          u.id, 
          u.account_id, 
          u.user_name, 
          u.user_phone, 
          u.user_description, 
          u.created_at, 
          u.updated_at
        FROM users u
        JOIN accounts a ON u.account_id = a.id
        WHERE u.id = @id
      '''),
        parameters: {'id': userId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      return Response.ok(
        jsonEncode({
          'id': row['id'],
          'account_id': row['account_id'],
          'user_name': row['user_name'],
          'user_phone': row['user_phone'],
          'user_description': row['user_description'],
          'created_at': row['created_at']?.toIso8601String(),
          'updated_at': row['updated_at']?.toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Ошибка при получении пользователя: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.get('/emails', (Request request) async {
    final userIdStr = request.url.queryParameters['user_id'];
    final userId = int.tryParse(userIdStr ?? '');

    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing or invalid user_id'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('''
        SELECT id, user_id, email_address, provider, created_at, updated_at
        FROM emails
        WHERE user_id = @userId
        ORDER BY created_at DESC
      '''),
        parameters: {'userId': userId},
      );

      final emails = result.map((row) {
        final r = row.toColumnMap();
        return {
          'id': r['id'],
          'user_id': r['user_id'],
          'email_address': r['email_address'],
          'provider': r['provider'],
          'created_at': (r['created_at'] as DateTime?)?.toIso8601String(),
          'updated_at': (r['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList();

      return Response.ok(
        jsonEncode(emails),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении email-аккаунтов: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении email-аккаунтов'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  }))
      .addHandler(router);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Сервер запущен по адресу: http://${server.address.host}:${server.port}');
}

Future<Connection> createConnection() async {
  final connection = await Connection.open(
    Endpoint(
      host: dotenv['DB_HOST']!,
      port: int.parse(dotenv['DB_PORT']!),
      database: dotenv['DB_NAME']!,
      username: dotenv['DB_USER']!,
      password: dotenv['DB_PASSWORD']!,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  print('Подключение к базе данных установлено');
  return connection;
}

// Основная функция для парсинга Uint8List из различных форматов данных БД
Uint8List? _parseUint8ListFromDb(dynamic rawData, String fieldName) {
  try {
    print('Обрабатываем $fieldName, тип: ${rawData.runtimeType}');

    if (rawData is Uint8List) {
      // Данные уже в правильном формате
      if (rawData.isNotEmpty && rawData[0] == 123) { // ASCII код '{'
        // Это объектный формат в виде байтов {98,102,180,...}
        final jsonString = String.fromCharCodes(rawData);
        print('Обнаружен объектный формат для $fieldName: $jsonString');

        return _parseObjectFormat(jsonString, fieldName);
      } else {
        // Это настоящие бинарные данные
        print('Настоящие бинарные данные для $fieldName, длина: ${rawData.length}');
        return rawData;
      }
    } else if (rawData is String) {
      print('Строковые данные для $fieldName: $rawData');

      // Проверяем, не является ли это объектным форматом {98,102,180,...}
      if (rawData.startsWith('{') && rawData.endsWith('}')) {
        print('Обнаружен объектный формат в строке для $fieldName');
        return _parseObjectFormat(rawData, fieldName);
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
Uint8List? _parseObjectFormat(String data, String fieldName) {
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
    print('Критическая ошибка при парсинге объектного формата для $fieldName: $e');
    print('Входные данные: $data');
    print('Stack trace: $stack');
    return null;
  }
}

// Дополнительная функция для отладки - показывает информацию о данных
void debugPrintData(dynamic data, String name) {
  print('=== DEBUG INFO для $name ===');
  print('Тип: ${data.runtimeType}');

  if (data == null) {
    print('Значение: null');
  } else if (data is String) {
    print('Длина строки: ${data.length}');
    print('Содержимое: $data');
    print('Первые 50 символов: ${data.length > 50 ? data.substring(0, 50) + "..." : data}');
  } else if (data is Uint8List) {
    print('Длина массива: ${data.length}');
    print('Первые 20 байтов: ${data.take(20).toList()}');
    if (data.isNotEmpty) {
      try {
        final asString = String.fromCharCodes(data);
        print('Как строка: ${asString.length > 100 ? asString.substring(0, 100) + "..." : asString}');
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
  final test1 = '{98,102,180,137,155,245}';
  print('Тест 1: Объектный формат');
  final result1 = _parseObjectFormat(test1, 'test1');
  print('Результат: $result1');

  // Тест 2: JSON массив
  final test2 = '[98,102,180,137,155,245]';
  print('Тест 2: JSON массив');
  final result2 = _parseUint8ListFromDb(test2, 'test2');
  print('Результат: $result2');

  // Тест 3: Uint8List с объектным форматом
  final test3 = Uint8List.fromList([123, 57, 56, 44, 49, 48, 50, 125]); // '{98,102}'
  print('Тест 3: Uint8List с объектным форматом');
  final result3 = _parseUint8ListFromDb(test3, 'test3');
  print('Результат: $result3');
  print('=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===');
}