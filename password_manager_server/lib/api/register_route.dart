import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:password_manager_server/utils/hash_parser.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

class RegisterRoute {
  final Connection connection;

  RegisterRoute(this.connection);

  Router get router {
    final router = Router();

    router.post('/', _register);

    return router;
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
