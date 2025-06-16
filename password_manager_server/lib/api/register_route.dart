import 'dart:convert';

import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RegisterRoute {
  final Connection connection;
  final EncryptionUtility encryption;
  final Map<String, String> env;

  RegisterRoute(this.connection, this.env)
      : encryption = EncryptionUtility(env);

  Router get router {
    final router = Router();
    router.post('/', _register);
    return router;
  }

  /// === РЕГИСТРАЦИЯ АККАУНТА ===
  Future<Response> _register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final accountLogin = data['account_login'];
      final emailAddress = data['email_address'];
      final password = data['password'];
      final userName = data['user_name'];
      final userPhone = data['user_phone'];
      final userDescription = data['user_description'];

      if ([accountLogin, emailAddress, password]
          .any((field) => field == null || field.isEmpty)) {
        return Response.badRequest(
          body:
              jsonEncode({'error': 'Необходимо указать логин, email и пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final encryptedPassword = encryption.encryptText(password);

      final result = await connection.execute(
        Sql.named('''
            SELECT * FROM create_account_with_user_and_email(
            @accountLogin,
            @emailAddress,
            @password,
            @userName,
            @userPhone,
            @userDescription)
        '''),
        parameters: {
          'accountLogin': accountLogin,
          'emailAddress': emailAddress,
          'password': encryptedPassword,
          'userName': userName,
          'userPhone': userPhone,
          'userDescription': userDescription,
        },
      );

      if (result.isEmpty) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Регистрация не удалась'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();

      return Response.ok(
        jsonEncode({
          'message': 'Регистрация прошла успешно',
          'account_id': int.parse(row['account_id'].toString()),
          'user_id': int.parse(row['user_id'].toString()),
          'email_id': int.parse(row['email_id'].toString()),
          'aes_key': env['APP_AES_KEY'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при регистрации: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при регистрации'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
