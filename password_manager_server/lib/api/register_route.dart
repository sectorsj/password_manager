import 'dart:convert';

import 'package:common_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logging/logging.dart';
import 'package:common_utility_package/hashing_utility.dart';

final _logger = Logger('RegisterRoute');

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
      final secretPhrase = data['secret_phrase'];

      // Логирование поступивших данных (не логируем пароли)
      _logger.info('Получены данные для регистрации аккаунта:'
          'accountLogin=$accountLogin,'
          'emailAddress=$emailAddress,'
          'userName=$userName,'
          'userPhone=$userPhone',
          'secretPhrase=${secretPhrase.isNotEmpty}');

      // Проверяем, что обязательные поля не пустые
      if ([accountLogin, emailAddress, password, secretPhrase]
          .any((field) => field == null || field.isEmpty)) {
        _logger.warning('Ошибка регистрации: не все поля заполнены');
        return Response.badRequest(
          body:
              jsonEncode({'error': 'Необходимо указать логин, email и пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      // Генерация AES ключа на основе секретной фразы с использованием HashingUtility
      final aesKey = await HashingUtility.deriveAesKeyFromSecret(secretPhrase);
      _logger.fine('Сгенерирован AES ключ для пользователя');

      // Шифрование пароля с использованием AES ключа
      final encryptedPassword = encryption.encryptText(password);
      _logger.fine('Пароль зашифрован для пользователя $accountLogin');


      // Логируем параметры перед выполнением SQL запроса
      _logger.fine('Подготовка к запросу в БД: '
          'accountLogin=$accountLogin, '
          'emailAddress=$emailAddress, '
          'aesKey=${HashingUtility.toBase64(aesKey)}');

      // Выполняем запрос на регистрацию
      final result = await connection.execute(
        Sql.named('''
            SELECT * FROM create_account_with_user_and_email(
            @accountLogin,
            @emailAddress,
            @password,
            @aesKey,
            @userName,
            @userPhone,
            @userDescription)
        '''),
        parameters: {
          'accountLogin': accountLogin,
          'emailAddress': emailAddress,
          'password': encryptedPassword,
          'aesKey': HashingUtility.toBase64(aesKey),
          'userName': userName,
          'userPhone': userPhone,
          'userDescription': userDescription,
        },
      );

      if (result.isEmpty) {
        _logger.severe(
            'Ошибка регистрации: не удалось создать пользователя в базе данных');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Регистрация не удалась'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      final accountId = int.parse(row['account_id'].toString());
      final userId = int.parse(row['user_id'].toString());
      final emailId = int.parse(row['mail_id'].toString());

      // Возвращаем успешный ответ с токеном и aes_key
      _logger.info('Регистрация прошла успешно для аккаунта $accountLogin');

      return Response.ok(
        jsonEncode({
          'message': 'Регистрация прошла успешно',
          'account_id': accountId,
          'user_id': userId,
          'email_id': emailId,
          'aes_key': HashingUtility.toBase64(aesKey),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      _logger.severe('Ошибка при регистрации: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при регистрации'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
