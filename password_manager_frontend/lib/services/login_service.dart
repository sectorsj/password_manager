import 'package:password_manager_frontend/services/base_service.dart';

/// LoginService
/// Метод login():
/// - Делает POST на /login с логином и паролем.
/// - Получает accountId и userId из ответа.
class LoginService extends BaseService {
  Future<Map<String, dynamic>> login({
    required String accountLogin,
    required String password,
  }) async {
    final response = await post('/login', {
      'account_login': accountLogin,
      'password': password,
    });
    print('DEBUG login response: $response');

    return response;
  }
}
