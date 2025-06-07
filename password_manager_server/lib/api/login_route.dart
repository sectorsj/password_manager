import 'dart:convert';

import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart' show DotEnv;
import 'package:password_manager_server/utils/hash_parser.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

class LoginRoute {
  final Connection connection;
  final EncryptionUtility encryption;

  LoginRoute(this.connection, DotEnv env) : encryption = EncryptionUtility(env);

  Router get router {
    final router = Router();
    router.post('/', _login);
    return router;
  }

  Future<Response> _login(Request request) async {
    // === АВТОРИЗАЦИЯ АККАУНТА ===
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final login = data['login'];
      final password = data['password'];

      if (login == null || password == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Укажите логин и пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Попытка входа с логином: $login');

      // SQL запрос - добавляем получение user_id
      final result = await connection.execute(
        Sql.named('''
        SELECT 
          a.id AS account_id, 
          a.account_email, 
          a.encrypted_password,
          u.id as user_id
        FROM accounts a
        LEFT JOIN users u ON a.id = u.account_id
        WHERE a.account_login = @login
      '''),
        parameters: {'login': login},
      );

      if (result.isEmpty) {
        print('Пользователь с логином "$login" не найден в БД');

        // (ОТЛАДКА) Проверяем, какие логины есть в БД
        // final allAccounts = await connection
        //     .execute('SELECT account_login FROM accounts LIMIT 10');
        // print('Существующие логины в БД:');
        // for (final account in allAccounts) {
        //   print('  - "${account.toColumnMap()['account_login']}"');
        // }

        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      final encryptedPassword = row['encrypted_password'] as String;

      late String decryptedPassword;

      print('Найден пользователь с логином: $login');

      try {
        decryptedPassword = encryption.decryptText(encryptedPassword);
      } catch (e) {
        print('Ошибка расшифровки: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Ошибка при расшифровке пароля'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (decryptedPassword != password) {
        print('Неверный пароль для логина: $login');
        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Вход выполнен: $login');

      // ИСПРАВЛЕННЫЙ ответ - добавляем userId с проверкой на null
      return Response.ok(
        jsonEncode({
          'message': 'Авторизация прошла успешно',
          'account_id': row['account_id'] ?? 0,
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
}
