import 'dart:typed_data';
import 'dart:convert';

import 'package:common_utility_package/hashing_utility.dart';
import 'package:common_utility_package/secure_storage_helper.dart';
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
    required String secretPhrase,
  }) async {
    final response = await post('/register', {
      'account_login': accountLogin,
      'user_name': userName,
      'email_address': emailAddress,
      'password': password,
      'secret_phrase': secretPhrase,
      if (userPhone != null) 'user_phone': userPhone,
      if (userDescription != null) 'user_description': userDescription,
    });

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      await SecureStorageHelper.setAesKey(result['aes_key']);
      await SecureStorageHelper.setJwtToken(result['jwt_token']);
      return result;
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }
}
