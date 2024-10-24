import 'dart:convert';
import 'package:http/http.dart' as http;


class WebsiteService {
  final String _baseUrl = 'http://localhost:8080';

  // Получить все Websites для аккаунта
  Future<List<dynamic>> getWebsitesByAccount(int accountId) async {
    final response = await http.get(Uri.parse('$_baseUrl/websites/$accountId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка при загрузке вебсайтов');
    }
  }

// Добавить Website
  Future<String> addWebsite(String name, String url, String login, String password, String salt, String description, int accountId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/websites/add'),
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
      return 'Вебсайт успешно добавлен';
    } else {
      return 'Ошибка при добавлении нового вебсайта';
    }
  }
}


