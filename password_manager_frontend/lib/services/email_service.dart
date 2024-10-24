import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/models/email.dart';

class EmailService {
  final String baseUrl = 'http://localhost:8080';

  // Получить все Email для аккаунта
  Future<List<Email>> getEmails(int accountId) async {
    final response = await http.get(Uri.parse('$baseUrl/emails/$accountId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      return jsonData.map((item) => Email.fromJson(item)).toList();
    } else {
      throw Exception('Неудача при загрузке электронных почт');
    }
  }

  // Добавить Email
  Future<String> addEmail(String email, String password, String salt, String description, int accountId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emails/add'),
      body: {
        'email_address': email,
        'password_hash': password,
        'salt': salt,
        'email_description': description,
        'account_id': accountId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return 'Почта добавлена успешно';
    } else {
      return 'Ошибка при добавлении новой почты';
    }
  }
}