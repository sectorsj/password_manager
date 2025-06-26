import 'dart:convert';
import 'dart:typed_data';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:common_utility_package/hashing_utility.dart';
import 'package:common_utility_package/jwt_util.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logging/logging.dart';
import 'package:password_manager_server/api/base_route.dart';

final _logger = Logger('RegisterRoute');

class RegisterRoute extends BaseRoute {
  final Connection connection;

  RegisterRoute(this.connection);

  @override
  Router get router {
    final router = Router();
    router.post('/', _register);
    return router;
  }

  Future<Response> _register(Request request) async {
    print('⚠️ Контроль: Register endpoint достигнут');
    try {
      // 1. Получаем данные от клиента
      final data = await _extractRequestData(request);
      print('⚠️ Контроль: Получены данные для регистрации аккаунта: ${data}');

      // 2. Генерация AES ключа и шифрование пароля
      final aesKey = await _generateAesKey(data['secret_phrase']);

      // 3. Генерация пароля, его шифрование
      final encryptedPassword =
          await _encryptPassword(data['password'], aesKey);
      print('⚠️ Контроль: Пароль зашифрован: $encryptedPassword');

      // Преобразование aesKey в строку Base64
      String aesKeyBase64 = HashingUtility.toBase64(aesKey);
      print('⚠️ Контроль: Преобразование AES ключа в Base64: $aesKeyBase64');

      // 4. Вставка данных в базу данных
      final dbResult =
          await _insertUserDataToDb(data, aesKeyBase64, encryptedPassword);
      print('⚠️ Контроль: Данные успешно вставлены в базу данных: $dbResult');

      if (dbResult == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Регистрация не удалась'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 5. Генерация JWT токена
      final jwtToken = _generateJwtToken(
          dbResult['account_id'], dbResult['user_id'], aesKey);
      print('⚠️ Контроль: Сгенерирован JWT токен: $jwtToken');

      // // 5.1. Проверяем уникальность логина и email
      // final checkResult = await _checkUniqueLoginAndEmail(
      //     data['account_login'], data['email_address']);
      // if (checkResult != null) {
      //   print('⚠️ Контроль: Логин или email уже заняты');
      //   return checkResult;
      // }

      // 6. Возвращаем успешный ответ с токеном и AES ключом
      return Response.ok(
        jsonEncode({
          'message': 'Регистрация прошла успешно',
          'account_id': dbResult['account_id'],
          'user_id': dbResult['user_id'],
          'email_id': dbResult['email_id'],
          'jwt_token': jwtToken,
          'aes_key': aesKeyBase64,
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

  Future<Map<String, dynamic>> _extractRequestData(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    if ([data['account_login'], data['email_address'], data['password']]
        .any((field) => field == null || field.isEmpty)) {
      throw Exception('Необходимо указать логин, email и пароль');
    }
    return data;
  }

  // Генерация AES ключа на основе секретной фразы
  Future<Uint8List> _generateAesKey(String secretPhrase) async {
    final salt = HashingUtility.generateDeterministicSalt(secretPhrase);
    print(
        '⚠️ Контроль: Генерация соли для AES ключа с секретной фразой: $salt');
    final aesKey = HashingUtility.generatePBKDF2Hash(
        secretPhrase, salt, HashingUtility.AES_KEY_LENGTH);
    print('⚠️ Контроль: Сгенерирован AES ключ для пользователя: $aesKey');
    return aesKey;
  }

  // Шифрование пароля с использованием пользовательского AES ключа
  Future<String> _encryptPassword(String password, Uint8List aesKey) async {
    final base64Aes = HashingUtility.toBase64(aesKey);
    final encryption = EncryptionUtility.fromBase64(base64Aes);
    print('⚠️ Контроль: Шифруем пароль с AES ключом');
    return encryption.encryptText(password);
  }

  Future<Map<String, dynamic>?> _insertUserDataToDb(
    Map<String, dynamic> data,
    String aesKeyBase64,
    String encryptedPassword,
  ) async {
    try {
      final result = await connection.execute(
        Sql.named('''
        SELECT * FROM create_account_with_user_nickname_and_email(
        @accountLogin,
        @emailAddress,
        @encryptedPassword,
        @aesKey,
        @userName,
        @userPhone,
        @userDescription)
      '''),
        parameters: {
          'accountLogin': data['account_login'],
          'emailAddress': data['email_address'],
          'encryptedPassword': encryptedPassword,
          'aesKey': aesKeyBase64,
          'userName': data['user_name'],
          'userPhone': data['user_phone'],
          'userDescription': data['user_description'],
        },
      );

      print('⚠️ Контроль: Ответ от базы данных: $result');

      if (result.isEmpty) {
        throw Exception('Не удалось создать пользователя в базе данных');
      }

      final row = result.first.toColumnMap();
      return {
        'account_id': row['account_id'],
        'user_id': row['user_id'],
        'email_id': row['email_id'],
      };
    } catch (e) {
      if (e.toString().contains('unique_violation')) {
        print('⚠️ Контроль: Логин или email уже заняты');
        throw Exception('Логин или email уже заняты');
      }
      _logger.severe('Ошибка при регистрации: $e');
      throw Exception('Ошибка при регистрации');
    }
  }

  // Future<Response?> _checkUniqueLoginAndEmail(
  //     String accountLogin, String emailAddress) async {
  //   final checkQuery = await connection.execute(
  //     'SELECT 1 FROM accounts WHERE account_login = @accountLogin OR account_email = @emailAddress LIMIT 1',
  //     parameters: {
  //       'accountLogin': accountLogin,
  //       'emailAddress': emailAddress,
  //     },
  //   );
  //
  //   if (checkQuery.isNotEmpty) {
  //     print('⚠️ Контроль: Логин или email уже заняты');
  //     return Response.badRequest(
  //       body: jsonEncode({'error': 'Логин или email уже заняты'}),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //   }
  //
  //   return null;
  // }

  String _generateJwtToken(int accountId, int userId, Uint8List aesKey) {
    print('⚠️ Контроль: Генерация JWT токена');
    return JwtUtil.generateToken({
      'account_id': accountId,
      'user_id': userId,
      'aes_key': HashingUtility.toBase64(aesKey),
    }, aesKey: HashingUtility.toBase64(aesKey));
  }
}
