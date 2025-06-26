import 'package:password_manager_frontend/services/base_service.dart';

/// LoginService
/// - Отправляет логин и пароль на /login
/// - Получает и проверяет jwt_token, account_id, user_id и aes_key
class LoginService extends BaseService {
  Future<Map<String, dynamic>> login({
    required String accountLogin,
    required String password,
  }) async {
    final response = await post('/login', {
      'account_login': accountLogin,
      'password': password,
    });

    if (response is! Map<String, dynamic>) {
      throw Exception('Некорректный ответ от сервера');
    }

    // Проверка ключей
    final jwtToken = response['jwt_token'];
    final aesKey = response['aes_key'];
    final accountId = response['account_id'];
    final userId = response['user_id'];

    if (jwtToken == null ||
        aesKey == null ||
        accountId == null ||
        userId == null) {
      throw Exception('Ответ сервера не содержит всех обязательных данных');
    }

    // Возвращаем только нужные поля
    return {
      'jwt_token': jwtToken,
      'aes_key': aesKey,
      'account_id': accountId,
      'user_id': userId,
      'account_email': response['account_email'],
    };
  }
}
