import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:common_utility_package/hashing_utility.dart';
import 'package:common_utility_package/jwt_util.dart';
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

      print('⚠️ Внимание контроль! Попытка входа с логином: $accountLogin');

      final result = await connection.execute(
        Sql.named('''
    SELECT 
      a.id AS account_id, 
      e.email_address AS account_email, 
      a.encrypted_password,
      a.aes_key,
      u.id as user_id
    FROM accounts a
    LEFT JOIN users u ON a.id = u.account_id
    LEFT JOIN emails e ON a.email_id = e.id
    WHERE a.account_login = @accountLogin
  '''),
        parameters: {'accountLogin': accountLogin},
      );

      if (result.isEmpty) {
        print(
            '⚠️ Внимание контроль! Пользователь с логином "$accountLogin" не найден в БД');

        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      final encryptedStored = row['encrypted_password'] as String;
      final aesKeyBase64 = row['aes_key'] as String;

      print(
          '⚠️ Внимание контроль! Зашифрованный пароль из БД: $encryptedStored');
      print('⚠️ Внимание контроль! AES ключ (Base64): $aesKeyBase64');

      final encryption = EncryptionUtility.fromBase64(aesKeyBase64);
      final decryptedStored = encryption.decryptText(encryptedStored);

      print('⚠️ Внимание контроль! Введённый пароль: $password');
      print(
          '⚠️ Внимание контроль! Расшифрованный пароль из БД: $decryptedStored');

      if (decryptedStored != password) {
        print(
            '⚠️ Внимание контроль! Пароль не совпадает для логина: $accountLogin');

        return Response.forbidden(
          jsonEncode({'error': 'Неверное имя пользователя или пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Генерация JWT
      final accountId = row['account_id'] as int;
      final userId = row['user_id'] as int;
      final aesKey = HashingUtility.fromBase64(aesKeyBase64);

      final jwtToken = JwtUtil.generateToken({
        'account_id': accountId,
        'user_id': userId,
        'aes_key': aesKeyBase64,
      }, aesKey: aesKeyBase64);

      print('✅ Вход выполнен для: $accountLogin');
      print('⚠️ JWT токен: $jwtToken');

      return Response.ok(
        jsonEncode({
          'message': 'Авторизация прошла успешно',
          'account_id': accountId,
          'user_id': userId,
          'account_email': row['account_email'] ?? '',
          'aes_key': aesKeyBase64,
          'jwt_token': jwtToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('❌ Ошибка при логине: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при авторизации'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
