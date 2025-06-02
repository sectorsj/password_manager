import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:password_manager_server/utils/hash_parser.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

class AuthRoutes {
  final Connection connection;

  AuthRoutes(this.connection);

  Router get router {
    final router = Router();

    router.post('/login', _login);
    router.post('/register', _register);

    return router;
  }

  Future<Response> _login(Request request) async {
    // === АВТОРИЗАЦИЯ АККАУНТА ===
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
        final allAccounts = await connection
            .execute('SELECT account_login FROM accounts LIMIT 10');
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
      final storedHash = parseUint8ListFromDb(storedHashRaw, 'hash');
      final storedSalt = parseUint8ListFromDb(storedSaltRaw, 'salt');

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
  }

  Future<Response> _register(Request request) async {
    // === РЕГИСТРАЦИЯ АККАУНТА ===
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

      print(
          'Пользователь зарегистрирован: account_id=$accountId, логин=$accountLogin');

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
  }
}
