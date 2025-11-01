import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:common_utility_package/jwt_util.dart';
import 'package:shelf/shelf.dart';

/// тест класса Extractor

/// Middleware для проверки JWT и извлечения AES ключа
Middleware baseAuthMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(jsonEncode({'error': 'Отсутствует токен'}),
            headers: {'Content-Type': 'application/json'});
      }

      final token = authHeader.substring(7);

      try {
        // Первичное извлечение payload без верификации — только чтобы достать aes_key
        final Map<String, dynamic>? payload = JwtUtil.extractData(token);
        if (payload == null) {
          return Response.forbidden(
              jsonEncode({'error': 'Недействительный токен (payload пуст)'}),
              headers: {'Content-Type': 'application/json'});
        }

        final aesKeyBase64 = payload['aes_key'];
        final userId = payload['user_id'];
      
        if (aesKeyBase64 == null || aesKeyBase64.isEmpty) {
          return Response.forbidden(
              jsonEncode({'error': 'Отсутствует ключ шифрования'}),
              headers: {'Content-Type': 'application/json'});
        }

        // Полноценная верификация JWT с использованием aes_key
        final jwt = JwtUtil.verifyToken(token, aesKeyBase64);
        if (jwt == null || JwtUtil.isTokenExpired(jwt)) {
          return Response.forbidden(
              jsonEncode({'error': 'Недействительный или просроченный токен'}),
              headers: {'Content-Type': 'application/json'});
        }

        final encryption = EncryptionUtility.fromBase64(aesKeyBase64);

        // ✅ // Передаём распарсенный payload далее по цепочке
        final updatedRequest = request.change(context: {
          'jwt_payload': jwt.payload,
          'encryption': encryption,
          'user_id': userId,
        });

        return await innerHandler(updatedRequest);
      } catch (e) {
        return Response.forbidden(
            jsonEncode({'error': 'Ошибка обработки токена'}),
            headers: {'Content-Type': 'application/json'});
      }
    };
  };
}
