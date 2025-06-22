import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/utils/config.dart';

class BaseService {
  final String _baseUrl = baseUrl;

  // Сборка URI для запроса
  Uri buildUri(String endpoint) {
    final rawUrl = '$_baseUrl$endpoint';
    print('🔧 Сборка URI: $rawUrl');
    print('⚠️ baseUrl = "$_baseUrl"');
    return Uri.parse(rawUrl);
  }

  // Выполнение GET-запроса
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(buildUri(endpoint))
          .timeout(const Duration(seconds: 10));
      _handleErrors(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('Ошибка при GET-запросе: $e');
      rethrow; // Бросаем ошибку дальше
    }
  }

  // Выполнение POST-запроса
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
        buildUri(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10));
      _handleErrors(response);
      return jsonDecode(response.body);
    } catch (e) {
      print('Ошибка при POST-запросе: $e');
      rethrow; // Бросаем ошибку дальше
    }
  }

  // Обработка ошибок ответа
  void _handleErrors(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Ошибка HTTP: ${response.statusCode}');
      print('Тело ответа: ${response.body}');
      if (response.statusCode == 401) {
        // Некорректная авторизация
        throw UnauthorizedException('Необходима авторизация');
      } else if (response.statusCode == 404) {
        // Ресурс не найден
        throw NotFoundException('Ресурс не найден');
      } else if (response.statusCode >= 500) {
        // Ошибка на сервере
        throw ServerException('Ошибка на сервере');
      } else {
        throw Exception('Ошибка ${response.statusCode}: ${response.body}');
      }
    }
  }
}

// Исключения для различных типов ошибок
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
