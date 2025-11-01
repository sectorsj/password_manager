import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/base_service.dart';

class EmailService extends BaseService {
  // Получить все Email для аккаунта пользователя
  Future<List<Email>> getEmails(int userId) async {
    final jsonData = await get('/emails?user_id=$userId');
    return (jsonData as List).map((item) => Email.fromJson(item)).toList();
  }

  // Добавить Email
  Future<String> addEmail(Email email) async {
    final jsonBody = {
      'email_address': email.emailAddress,
      'email_description': email.emailDescription,
      'raw_password': email.rawPassword, // 🔑 не зашифрованный пароль
      'account_id': email.accountId,
      'category_id': email.categoryId,
      'user_id': email.userId,
    };

    await post('/emails/add', jsonBody);
    print('⚠️ Контроль: Почта добавлена успешно $jsonBody');
    return 'Почта добавлена успешно';
  }

  
  Future<void> deleteEmail(int emailId) async {
    await delete('/emails/delete/$emailId');
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
