import 'dart:typed_data';
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/base_service.dart';

class EmailService extends BaseService {

  // Получить все Email для аккаунта
  Future<List<Email>> getEmails(int accountId) async {
    final jsonData = await get('/emails/$accountId');
      return (jsonData as List).map((item) => Email.fromJson(item)).toList();
  }

  // Добавить Email
  Future<String> addEmail(Email email) async {
    final jsonBody = email.toJson()
      ..updateAll((k, v) {
        if (v is Uint8List) return v.toList();
        return v;
      });
    await post('/emails/add', jsonBody);
    return 'Почта (Email) добавлена успешно';
  }
}