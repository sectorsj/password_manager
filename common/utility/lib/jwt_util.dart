import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtil {
  /// Генерация JWT токена с заданной нагрузкой и временем жизни.
  static String generateToken(Map<String, dynamic> payload,
      {Duration expiresIn = const Duration(hours: 1),
      String? audience,
      String? issuer,
      String? subject,
      required String aesKey}) {
    // Добавляем время жизни в payload
    final expirationTime = DateTime.now().add(expiresIn).millisecondsSinceEpoch;
    payload['exp'] = (expirationTime / 1000)
        .floor(); // 'exp' — это стандартный параметр для срока действия токена

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
    try {
      final jwt = JWT.verify(token, SecretKey(aesKey));

      // Проверяем, не истек ли срок действия токена
      final exp = jwt.payload['exp'];
      if (exp != null && DateTime.now().millisecondsSinceEpoch > exp) {
        // Если токен просрочен
        return null;
      }
      return jwt;
    } catch (_) {
      return null;
    }
  }

  /// Проверка, истек ли срок действия токена.
  static bool isTokenExpired(JWT jwt) {
    final exp = jwt.payload['exp'];
    if (exp != null) {
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expirationDate.isBefore(
          DateTime.now()); // Если время истечения меньше текущего времени
    }
    return true; // Если нет поля 'exp', считаем, что токен истек
  }

  /// Обновление (рефреш) токена.
  /// Генерирует новый токен с теми же данными, но с новым сроком действия.
  static String refreshToken(String oldToken,
      {Duration expiresIn = const Duration(hours: 1), required String aesKey}) {
    try {
      final oldJwt = JWT.verify(oldToken, SecretKey(aesKey));
      final payload = Map<String, dynamic>.from(oldJwt.payload);

      // Добавляем время жизни в payload (новое время истечения)
      final expirationTime =
          DateTime.now().add(expiresIn).millisecondsSinceEpoch;
      payload['exp'] = expirationTime;

      // Генерируем новый токен с обновленным сроком действия
      final newJwt = JWT(payload);
      return newJwt.sign(SecretKey(aesKey));
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
}
