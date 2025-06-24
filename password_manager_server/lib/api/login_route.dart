import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:logging/logging.dart';
import 'package:password_manager_server/api/base_route.dart';

final _logger = Logger('LoginRoute');

class LoginRoute extends BaseRoute {
  final Connection connection;

  LoginRoute(this.connection);

  @override
  Router get router {
    final router = Router();
    router.post('/', _login);
    return router;
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final accountLogin = data['account_login'];
      final password = data['password'];

      if (accountLogin == null || password == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Укажите логин и пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _logger.info('Попытка входа с логином: $accountLogin');

      final result = await connection.execute(
        Sql.named('''
        SELECT 
          a.id AS account_id, 
          a.account_email, 
          a.encrypted_password,
          a.aes_key,
          u.id as user_id
        FROM accounts a
        LEFT JOIN users u ON a.id = u.account_id
        WHERE a.account_login = @accountLogin
      '''),
        parameters: {'accountLogin': accountLogin},
      );

      if (result.isEmpty) {
        _logger
            .warning('Пользователь с логином "$accountLogin" не найден в БД');

        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      final encryptedStored = row['encrypted_password'] as String;

      final decryptedStored = encryption.decryptText(encryptedStored);

      _logger.fine('Пароль, введённый пользователем: $password');
      _logger.fine('Зашифрованный пароль из БД:     $encryptedStored');
      _logger.fine('Расшифрованный введённый пароль: $decryptedStored');

      if (decryptedStored != password) {
        _logger.warning('Пароль не совпадает для логина: $accountLogin');
        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      _logger.info('Вход выполнен для логина: $accountLogin');

      return Response.ok(
        jsonEncode({
          'message': 'Авторизация прошла успешно',
          'account_id': row['account_id'] ?? 0,
          'user_id': row['user_id'] ?? 0,
          'account_email': row['account_email'] ?? '',
          'aes_key': row['aes_key'] ?? '',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      _logger.severe('Ошибка при логине: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при авторизации'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
