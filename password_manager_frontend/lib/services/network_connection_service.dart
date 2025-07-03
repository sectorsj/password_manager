import 'dart:typed_data';

import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/base_service.dart';

class NetworkConnectionService extends BaseService {
  // ✅ Получить все сетевые подключения для пользователя
  Future<List<NetworkConnection>> getNetworkConnectionsByUser(
      int userId) async {
    final jsonData = await get('/network-connections?user_id=$userId');
    return (jsonData as List)
        .map((item) => NetworkConnection.fromJson(item))
        .toList();
  }

  // ✅ Добавить сетевое подключение
  // 🔄 открытый пароль шифруется на сервере
  Future<String> addNetworkConnection(NetworkConnection conn) async {
    final jsonBody = {
      'network_connection_name': conn.networkConnectionName,
      'nickname': conn.nickname,
      'raw_password': conn.rawPassword, // пароль подключения в открытом виде
      'network_connection_email': conn.networkConnectionEmail,
      'raw_email_password': conn.rawEmailPassword, // пароль от email
      'ipv4': conn.ipv4,
      'ipv6': conn.ipv6,
      'network_connection_description': conn.networkConnectionDescription,
      'account_id': conn.accountId,
      'user_id': conn.accountId,
      'category_id': conn.categoryId,
    };

    await post('/network-connections/add', jsonBody);
    return 'Сетевое подключение добавлено успешно';
  }

  // ✅ Получить расшифрованный пароль по ID подключения
  Future<String> getDecryptedPassword(int id) async {
    final response = await get('/network-connections/$id/password');
    if (response is Map && response.containsKey('decrypted_password')) {
      return response['decrypted_password'];
    } else {
      throw Exception('Ошибка при получении расшифрованного пароля');
    }
  }
  
  /// Получить расшифрованный пароль от email
  Future<String> getDecryptedEmailPassword(int id) async {
    final response = await get('/network-connections/$id/email-password');
    if (response is Map && response.containsKey('decrypted_email_password')) {
      return response['decrypted_email_password'];
    } else {
      throw Exception('Ошибка при получении email-пароля');
    }
  }
}
