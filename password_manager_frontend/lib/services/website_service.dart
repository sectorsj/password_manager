import '../models/website.dart';
import 'base_service.dart';

class WebsiteService extends BaseService {
  // ✅ Получить все вебсайты для пользователя
  Future<List<Website>> getWebsitesByUser(int userId) async {
    final jsonData = await get('/websites?user_id=$userId');
    return (jsonData as List).map((item) => Website.fromJson(item)).toList();
  }

  // ✅ Добавить новый вебсайт
  // 🔄 открытый пароль шифруется на сервере
  Future<String> addWebsite(Website website) async {
    final jsonBody = {
      'website_name': website.websiteName,
      'website_url': website.websiteUrl,
      'nickname': website.nickname,
      'raw_password': website.rawPassword,
      // пароль вебсайта в открытом виде
      'website_email': website.websiteEmail,
      'raw_email_password': website.rawEmailPassword,
      // пароль от почты в открытом виде
      'website_description': website.websiteDescription,
      'account_id': website.accountId,
      'user_id': website.userId,
      'category_id': website.categoryId,
    };

    await post('/websites/add', jsonBody);
    return 'Вебсайт добавлен успешно';
  }

  // ✅ Получить расшифрованный пароль по ID вебсайта
  Future<String> getDecryptedPassword(int id) async {
    final response = await get('/websites/$id/password');
    if (response is Map && response.containsKey('decrypted_password')) {
      return response['decrypted_password'];
    } else {
      throw Exception('Ошибка при получении расшифрованного пароля');
    }
  }

  /// Получить расшифрованный пароль от email
  Future<String> getDecryptedEmailPassword(int id) async {
    final response = await get('/websites/$id/email-password');
    if (response is Map && response.containsKey('decrypted_email_password')) {
      return response['decrypted_email_password'];
    } else {
      throw Exception('Ошибка при получении email-пароля');
    }
  }
}
