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
  // 🔄 открытый пароль теперь шифруется на сервере
  Future<String> addNetworkConnection(NetworkConnection conn) async {
    final jsonBody = Map<String, dynamic>.from(conn.toJson())
      ..removeWhere((key, value) =>
          value == null || (value is String && value.trim().isEmpty))
      ..updateAll((k, v) {
        if (v is Uint8List) return v.toList();
        return v;
      });

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
}
