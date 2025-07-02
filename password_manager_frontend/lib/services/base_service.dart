import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:common_utility_package/secure_storage_helper.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/utils/config.dart';

class BaseService {
  final String _baseUrl = baseUrl;

  Uri buildUri(String endpoint) {
    final fullUrl = '$_baseUrl$endpoint';
    print('🔧 [BaseService] Сборка URI: $fullUrl');
    return Uri.parse(fullUrl);
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = buildUri(endpoint);
    print('📤 GET → $uri');
    try {
      final mergedHeaders = await _mergeHeaders(headers);
      final response = await http
          .get(uri, headers: mergedHeaders)
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw NetworkException('Нет подключения к интернету');
    } on HttpException {
      throw NetworkException('Ошибка HTTP');
    } on FormatException {
      throw NetworkException('Ошибка формата данных');
    } on TimeoutException {
      throw TimeoutException('Превышено время ожидания запроса');
    } catch (e) {
      print('❌ Ошибка GET-запроса: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final uri = buildUri(endpoint);
    final encodedBody = jsonEncode(body);

    print('📤 POST → $uri');
    print('📦 Тело запроса: $encodedBody');

    try {
      final mergedHeaders = await _mergeHeaders(headers);
      final response = await http
          .post(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on SocketException {
      throw NetworkException('Нет подключения к интернету');
    } on HttpException {
      throw NetworkException('Ошибка HTTP');
    } on FormatException {
      throw NetworkException('Ошибка формата данных');
    } on TimeoutException {
      throw TimeoutException('Превышено время ожидания запроса');
    } catch (e) {
      print('❌ Ошибка POST-запроса: $e');
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    print('📥 Ответ [${response.statusCode}]: ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException('Необходима авторизация');
      case 404:
        throw NotFoundException('Ресурс не найден');
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException('Ошибка на сервере');
      default:
        throw HttpException('Ошибка ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, String>> _mergeHeaders(
      Map<String, String>? headers) async {
    final token = await SecureStorageHelper.getJwtToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
  }
}

// Исключения
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

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
