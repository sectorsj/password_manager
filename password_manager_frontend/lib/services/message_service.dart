import 'package:password_manager_frontend/services/base_service.dart';
import '../models/message.dart';

class MessageService extends BaseService {
  final String baseUrl;

  MessageService(this.baseUrl);

  // Получить сообщение по типу
  Future<Message?> fetchMessage({String type = 'welcome'}) async {
    try {
      final response = await get('/messages?type=$type');
      return Message.fromJson(response);
    } catch (e) {
      print('⚠️ [MessageService] Ошибка получения сообщения типа $type: $e');
      return null;
    }
  }
}
