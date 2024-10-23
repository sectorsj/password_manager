import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:8080';

  // Получить все Email для аккаунта
  // Future<List<dynamic>> getEmailsByAccount(int accountId) async {
  //   final response = await http.get(Uri.parse('$baseUrl/emails/$accountId'));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load emails');
  //   }
  // }

  // Добавить Email
  // Future<String> addEmail(String email, String password, String salt, String description, int accountId) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/emails/add'),
  //     body: {
  //       'email_address': email,
  //       'password_hash': password,
  //       'salt': salt,
  //       'email_description': description,
  //       'account_id': accountId.toString(),
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return 'Email added successfully';
  //   } else {
  //     return 'Failed to add email';
  //   }
  // }

  // Получить все Network Connections для аккаунта
  Future<List<dynamic>> getNetworkConnectionsByAccount(int accountId) async {
    final response = await http.get(Uri.parse('$baseUrl/network-connections/$accountId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load network connections');
    }
  }

  // Добавить сетевое подключение
  Future<String> addNetworkConnection(String name, String ipv4, String ipv6, String login, String password, String salt, int accountId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/network-connections/add'),
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
      return 'Network connection added successfully';
    } else {
      return 'Failed to add network connection';
    }
  }

  // Получить все Websites для аккаунта
  Future<List<dynamic>> getWebsitesByAccount(int accountId) async {
    final response = await http.get(Uri.parse('$baseUrl/websites/$accountId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load websites');
    }
  }

  // Добавить Website
  Future<String> addWebsite(String name, String url, String login, String password, String salt, String description, int accountId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/websites/add'),
      body: {
        'website_name': name,
        'url': url,
        'website_login': login,
        'password_hash': password,
        'salt': salt,
        'website_description': description,
        'account_id': accountId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return 'Website added successfully';
    } else {
      return 'Failed to add website';
    }
  }
}