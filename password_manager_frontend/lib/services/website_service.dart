import 'dart:typed_data';
import '../models/website.dart';
import 'base_service.dart';

class WebsiteService extends BaseService {
  Future<List<Website>> getWebsitesByAccount(int accountId) async {
    final jsonData = await get('/websites/$accountId');
    return (jsonData as List).map((e) => Website.fromJson(e)).toList();
  }

  Future<String> addWebsite(Website website) async {
    final jsonBody = website.toJson()..updateAll((k, v) {
      if (v is Uint8List) return v.toList();
      return v;
    });

    await post('/websites/add', jsonBody);
    return 'Вебсайт (Website) добавлен успешно';
  }
}