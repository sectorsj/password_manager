import '../models/user.dart';
import 'base_service.dart';

class UserService extends BaseService {

  Future<User> fetchUserById(int userId) async {
    try {
      final response = await get('/users/$userId');

      if (response is Map<String, dynamic>) {
        return User.fromJson(response);
      } else {
        throw Exception('Ожидался JSON-объект, но получено: $response');
      }
    } catch (e) {
      print('Ошибка при получении пользователя с ID $userId: $e');
      rethrow;
    }
  }
}