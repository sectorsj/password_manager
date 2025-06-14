import 'dart:typed_data';
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/base_service.dart';

class EmailService extends BaseService {
  // Получить все Email для аккаунта
  Future<List<Email>> getEmails(int userId) async {
    final jsonData = await get('/emails?user_id=$userId');
    return (jsonData as List).map((item) => Email.fromJson(item)).toList();
  }

  // Добавить Email
  Future<String> addEmail(Email email) async {
    final jsonBody = email.toJson()
      ..updateAll((k, v) {
        if (v is Uint8List) return v.toList();
        return v;
      });

    if (email.categoryId == null || email.categoryId == 0) {
      throw Exception('Некорректный categoryId: ${email.categoryId}');
    }

    await post('/emails/add', jsonBody);
    return 'Почта (Email) добавлена успешно';
  }

  Future<String> getDecryptedPassword(int id) async {
    final response = await get('/emails/$id/password');
    if (response is Map && response.containsKey('decrypted_password')) {
      return response['decrypted_password'];
    } else {
      throw Exception('Ошибка при получении расшифрованного пароля');
    }
  }
}
