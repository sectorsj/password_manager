import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/utils/config.dart';

class BaseService {
  final String _baseUrl = baseUrl;

  Uri buildUri(String endpoint) {
    final rawUrl = '$_baseUrl$endpoint';
    print('🔧 Сборка URI: $rawUrl');
    print('⚠️ baseUrl = "$_baseUrl"');
    return Uri.parse(rawUrl);
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(buildUri(endpoint));
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      buildUri(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Ошибка HTTP: ${response.statusCode}');
      print('Тело ответа: ${response.body}');
      throw Exception('Ошибка ${response.statusCode}: ${response.body}');
    }
  }
}
