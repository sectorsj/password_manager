import 'dart:typed_data';
import 'dart:convert';

import 'package:password_manager_frontend/services/base_service.dart';

/// RegistrationService
// Метод register():
// - Делает POST на /register.
// - Получает accountId и userId из ответа.
class RegistrationService extends BaseService {
  Future<Map<String, dynamic>> register({
    required String accountLogin,
    required String userName,
    required String emailAddress,
    required String password,
    String? userPhone,
    String? userDescription,
  }) async {
    final response = await post('/register', {
      'account_login': accountLogin,
      'user_name': userName,
      'email_address': emailAddress,
      'password': password,
      if (userPhone != null) 'user_phone': userPhone,
      if (userDescription != null) 'user_description': userDescription,
    });

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      throw Exception('Некорректный ответ сервера при регистрации');
    }
  }
}
