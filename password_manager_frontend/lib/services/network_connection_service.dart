import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/models/network_connection.dart';

class NetworkConnectionService {
  final String _baseUrl = 'http://localhost:8080';

  // Получить все Email для аккаунта
  Future<List<NetworkConnection>> getNetworkConnectionsByAccount(int accountId) async {
    final response = await http.get(Uri.parse('$_baseUrl/network-connections/$accountId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      return jsonData.map((item) => NetworkConnection.fromJson(item)).toList();
    } else {
      throw Exception('Неудача при загрузке сетевых подключений');
    }
  }

  // Добавить Сетевое подключение
  Future<String> addNetworkConnection(String name, String ipv4, String ipv6, String login, String password, String salt, int accountId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/network-connections/add'),
      body: {
        'connection_name': name,
        'ipv4': ipv4,
        'ipv6': ipv6,
        'network_login': login,
        'password_hash': password,
        'salt': salt,
        'account_id': accountId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return 'Сетевое подключение добавлено успешно';
    } else {
      return 'Ошибка при добавлении нового Сетевое подключения';
    }
  }
}