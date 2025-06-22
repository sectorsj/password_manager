import 'dart:convert';

import 'package:common_utility_package/jwt_util.dart';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import 'jwt_util.dart';

final _logger = Logger('JWTMiddleware');

Middleware jwtMiddleware(String secretKey) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        _logger.warning('Нет JWT токена');
        return Response.forbidden(
          jsonEncode({'error': 'Нет JWT токена'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);

      try {
        final jwt = JwtUtil.verifyToken(token);

        if (jwt == null || JwtUtil.isTokenExpired(jwt)) {
          _logger.warning('Неверный или просроченный токен');
          return Response.forbidden(
            jsonEncode({'error': 'Неверный или просроченный токен'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Извлекаем данные из payload токена и добавляем их в контекст запроса
        final updatedRequest = request.change(context: {
          'account_id': jwt.payload['account_id'],
          'user_id': jwt.payload['user_id'],
          'aes_key': jwt.payload['aes_key'],
        });

        return await innerHandler(updatedRequest);
      } catch (e) {
        _logger.severe('Ошибка валидации токена: $e');
        return Response.forbidden(
          jsonEncode({'error': 'Неверный или просроченный токен'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}
