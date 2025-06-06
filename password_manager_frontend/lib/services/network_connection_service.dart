import 'dart:typed_data';

import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/base_service.dart';

class NetworkConnectionService extends BaseService {
  // Получить все Сетевое подключение для аккаунта
  Future<List<NetworkConnection>> getNetworkConnectionsByUser(
      int userId) async {
    final jsonData = await get('/network-connections?user_id=$userId');
    return (jsonData as List)
        .map((item) => NetworkConnection.fromJson(item))
        .toList();
  }

  // Добавить Сетевое подключение
  Future<String> addNetworkConnection(NetworkConnection conn) async {
    final jsonBody = conn.toJson()
      ..updateAll((k, v) {
        if (v is Uint8List) return v.toList();
        return v;
      });

    await post('/network-connections/add', jsonBody);
    return 'Сетевое подключение (Network-connection) добавлено успешно';
  }

  Future<String> getDecryptedPassword(int id) async {
    final response = await get('/network-connections/$id/password');
    if (response is Map && response.containsKey('decrypted_password')) {
      return response['decrypted_password'];
    } else {
      throw Exception('Ошибка при получении расшифрованного пароля');
    }
  }
}
