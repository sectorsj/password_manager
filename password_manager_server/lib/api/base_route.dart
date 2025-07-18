import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:common_utility_package/jwt_util.dart';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

final _logger = Logger('BaseRoute');

/// Базовый маршрут с логикой авторизации
class BaseRoute {
  late final EncryptionUtility encryption;

  // Метод для извлечения токена из заголовков запроса
  String? _getToken(Request request) {
    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null; // Токен не найден
    }
    return authHeader.substring(7); // Извлекаем токен
  }

  // Метод для декодирования токена
  Map<String, dynamic>? _decodeToken(String token, String aesKey) {
    final jwt = JwtUtil.verifyToken(token, aesKey);
    if (jwt == null || JwtUtil.isTokenExpired(jwt)) {
      return null; // Невалидный или просроченный токен
    }
    return jwt.payload;
  }

  // Метод для создания шифрования с помощью aes_key из токена
  Future<void> _initializeEncryption(Request request) async {
    final token = _getToken(request);
    if (token == null) {
      throw Exception("Токен не найден");
    }

    final jwtPayload = JwtUtil.extractData(token);
    final aesKey = jwtPayload?['aes_key'];

    if (aesKey == null) {
      throw Exception("Не удалось извлечь aes_key из токена");
    }
    encryption = EncryptionUtility.fromBase64(aesKey);
  }

  // Функция для базовой обработки запроса, можно переопределить в наследниках
  Future<Response> handleRequest(Request request) async {
    await _initializeEncryption(request);

    // Если все прошло успешно, выполняем нужный запрос (можно переопределить)
    return Response.ok(
      jsonEncode({'message': 'Success'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
