import 'dart:typed_data';
import '../models/website.dart';
import 'base_service.dart';

class WebsiteService extends BaseService {
  Future<List<Website>> getWebsitesByUser(int userId) async {
    final jsonData = await get('/websites?user_id=$userId');
    return (jsonData as List).map((e) => Website.fromJson(e)).toList();
  }

  Future<String> addWebsite(Website website) async {
    final jsonBody = website.toJson();

    await post('/websites/add', jsonBody);
    return 'Вебсайт добавлен успешно';
  }

  // --- services/website_service.dart ---
  Future<String> getDecryptedPassword(int id) async {
    final response = await get('/websites/$id/password');
    if (response is Map && response.containsKey('decrypted_password')) {
      return response['decrypted_password'];
    } else {
      throw Exception('Ошибка при получении расшифрованного пароля');
    }
  }
}
