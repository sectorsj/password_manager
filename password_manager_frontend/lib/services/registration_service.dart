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
    required String emailPassword,
    required String password,
    String? userPhone,
    String? userDescription,
    required String secretPhrase,
  }) async {
    final result = await post('/register', {
      'account_login': accountLogin,
      'user_name': userName,
      'email_address': emailAddress,
      'email_password': emailPassword,
      'password': password,
      'secret_phrase': secretPhrase,
      if (userPhone != null) 'user_phone': userPhone,
      if (userDescription != null) 'user_description': userDescription,
    });

    // Сохраняем AES-ключ и JWT в защищенное хранилище
    await SecureStorageHelper.setAesKey(result['aes_key']);
    await SecureStorageHelper.setJwtToken(result['jwt_token']);

    return result;
  }
}
