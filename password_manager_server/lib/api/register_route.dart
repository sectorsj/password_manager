import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:common_utility_package/hashing_utility.dart';
import 'package:common_utility_package/jwt_util.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logging/logging.dart';

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

      if (secretPhrase == null || secretPhrase.isEmpty) {
        _logger.warning('Отсутствует секретная фраза в запросе');
        return Response.badRequest(
          body: jsonEncode({'error': 'Необходимо указать секретную фразу'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Логирование поступивших данных (не логируем пароли и секретную фразу)
      _logger.info(
          'Получены данные для регистрации аккаунта:'
              'accountLogin=$accountLogin,'
              'emailAddress=$emailAddress,'
              'userName=$userName,'
              'userPhone=$userPhone',
          'secretPhrase присутствует: ${secretPhrase.isNotEmpty}');

      // Проверяем, что обязательные поля не пустые
      if ([accountLogin, emailAddress, password]
          .any((field) => field == null || field.isEmpty)) {
        _logger.warning('Ошибка регистрации: не все поля заполнены');
        return Response.badRequest(
          body:
              jsonEncode({'error': 'Необходимо указать логин, email, пароль'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Проверка уникальности логина и email в базе данных
      final checkQuery = await connection.execute(
        'SELECT 1 FROM accounts WHERE account_login = @accountLogin OR account_email = @emailAddress LIMIT 1',
        parameters: {
          'accountLogin': accountLogin,
          'emailAddress': emailAddress,
        },
      );
      if (checkQuery.isNotEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Логин или email уже заняты'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Генерация AES ключа на основе секретной фразы с использованием HashingUtility
      final aesKey = await HashingUtility.deriveAesKeyFromSecret(secretPhrase);
      _logger.fine('Сгенерирован AES ключ для пользователя, $aesKey');

      // Создаем EncryptionUtility с пользовательским AES ключом
      final userEncryption =
          EncryptionUtility.fromBase64Key(HashingUtility.toBase64(aesKey));

      // Шифрование пароля с использованием пользовательского AES ключа
      final encryptedPassword = userEncryption.encryptText(password);

      _logger.fine('Подготовка к записи в БД с параметрами: '
          'accountLogin=$accountLogin, '
          'emailAddress=$emailAddress, '
          'aesKey длина=${HashingUtility.toBase64(aesKey).length}');

      // Выполняем запрос на регистрацию
      final result = await connection.execute(
        Sql.named('''
            SELECT * FROM create_account_with_user_and_email(
            @accountLogin,
            @emailAddress,
            @encryptedPassword,
            @aesKey,
            @userName,
            @userPhone,
            @userDescription)
        '''),
        parameters: {
          'accountLogin': accountLogin,
          'emailAddress': emailAddress,
          'encryptedPassword': encryptedPassword,
          'aesKey': HashingUtility.toBase64(aesKey),
          // Передаем AES ключ как base64 строку
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
      final emailId = int.parse(row['email_id'].toString());

      // Генерация JWT токена с account_id и user_id
      final jwtToken = JwtUtil.generateToken({
        'account_id': accountId,
        'user_id': userId,
        'aes_key': HashingUtility.toBase64(aesKey), // Включаем AES ключ в токен
      });

      _logger.info('Тело запроса: $data');
      _logger.info('Тело запроса: $jwtToken');
      _logger.info('Тело запроса: $accountId');
      _logger.info('Тело запроса: $userId');
      _logger.info('Тело запроса: $emailId');
      // Возвращаем успешный ответ с токеном и aes_key
      _logger.info('Регистрация прошла успешно для аккаунта $accountLogin');

      return Response.ok(
        jsonEncode({
          'message': 'Регистрация прошла успешно',
          'account_id': accountId,
          'user_id': userId,
          'email_id': emailId,
          'jwt_token': jwtToken,
          'aes_key': HashingUtility.toBase64(aesKey),
          // Отправляем aes_key обратно клиенту
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
