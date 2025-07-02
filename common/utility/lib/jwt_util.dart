import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtil {
  /// Генерация JWT токена с заданной нагрузкой и временем жизни.
  static String generateToken(
    Map<String, dynamic> payload, {
    Duration expiresIn = const Duration(hours: 1),
    String? audience,
    String? issuer,
    String? subject,
    required String aesKey,
  }) {
    // Добавляем время жизни в payload
    final expirationTime =
        DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
    payload['exp'] = expirationTime;

    if (audience != null) {
      payload['aud'] = audience; // audience claim
    }
    if (issuer != null) {
      payload['iss'] = issuer; // issuer claim
    }
    if (subject != null) {
      payload['sub'] = subject; // subject claim
    }

    final jwt = JWT(payload);
    return jwt.sign(SecretKey(aesKey));
  }

  /// Верификация JWT токена. Возвращает объект JWT или null, если токен не валиден.
  static JWT? verifyToken(String token, String aesKey) {
    if (aesKey.isEmpty) {
      throw Exception("AES ключ не может быть пустым");
    }

    try {
      final jwt = JWT.verify(token, SecretKey(aesKey));

      // Если токен просрочен
      if (isTokenExpired(jwt)) {
        return null; // Возвращаем null
      }
      return jwt; // иначе возвращаем JWT
    } catch (_) {
      return null;
    }
  }

  /// Проверка, истек ли срок действия токена.
  static bool isTokenExpired(JWT jwt) {
    final exp = jwt.payload['exp'];
    if (exp is int) {
      final expiration = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiration.isBefore(
          DateTime.now()); // Если время истечения меньше текущего времени
    }
    return true; // Если нет поля 'exp', считаем, что токен истек
  }

  /// Обновление (рефреш) токена
  /// Генерирует новый токен с теми же данными, но с новым сроком действия.
  static String refreshToken(
    String oldToken, {
    Duration expiresIn = const Duration(hours: 1),
    required String aesKey,
  }) {
    try {
      final oldJwt = JWT.verify(oldToken, SecretKey(aesKey));
      final payload = Map<String, dynamic>.from(oldJwt.payload);

      // Добавляем время жизни в payload (новое время истечения)
      payload['exp'] =
          (DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000);

      // Генерируем новый токен с обновленным сроком действия
      return JWT(payload).sign(SecretKey(aesKey));
    } catch (_) {
      throw Exception('Невозможно обновить токен');
    }
  }

  // Дополнительная функция: Получение данных из токена
  static Map<String, dynamic>? extractData(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload; // Возвращаем полезную нагрузку токена
    } catch (_) {
      return null;
    }
  }

  /// Проверка, истек ли срок действия токена по payload
  static bool isTokenExpiredFromPayload(Map<String, dynamic> payload) {
    final exp = payload['exp'];
    if (exp is int) {
      final expiration = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiration.isBefore(DateTime.now());
    }
    return true;
  }
}
