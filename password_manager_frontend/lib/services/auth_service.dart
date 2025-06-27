import 'package:common_utility_package/jwt_util.dart';
import 'package:common_utility_package/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/account.dart';
import 'package:password_manager_frontend/models/user.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthService
/// Отвечает за авторизацию и хранение сессии пользователя.
class AuthService extends ChangeNotifier {
  int _accountId = 0;
  int _userId = 0;
  int _categoryId = 0;

  Account? _account;
  User? _user;

  final AccountService _accountService = AccountService();
  final UserService _userService = UserService();

  int get accountId => _accountId;

  int get userId => _userId;

  int get categoryId => _categoryId;

  Account? get account => _account;

  User? get user => _user;

  bool get isLoggedIn => _accountId != 0 && _userId != 0;

  Future<void> initialize() async {
    try {
      // Проверка валидной сессии
      if (await SecureStorageHelper.isSessionValid()) {
        final jwtToken = await SecureStorageHelper.getJwtToken();
        await setSessionFromToken(
            jwtToken!); // Устанавливаем сессию, если токен есть
      } else {
        print('Сессия не найдена или невалидна');
      }
    } catch (e) {
      print('Ошибка инициализации сессии: $e');
    }
  }

  /// Устанавливает сессию из JWT токена
  Future<void> setSessionFromToken(String jwtToken) async {
    try {
      // Получаем aesKey напрямую из SecureStorage
      final aesKey = await SecureStorageHelper.getAesKey();

      if (aesKey == null || aesKey.isEmpty) {
        throw Exception('AES ключ отсутствует в токене');
      }

      final jwt = JwtUtil.verifyToken(
          jwtToken, aesKey); // Используем aesKey для верификации

      // Используем JwtUtil для работы с токеном
      if (jwt == null || JwtUtil.isTokenExpired(jwt)) {
        throw Exception('Токен недействителен или просрочен');
      }

      // Извлекаем данные из JWT токена
      final accountId = int.parse(jwt.payload['account_id'].toString());
      final userId = int.parse(jwt.payload['user_id'].toString());
      final _categoryId = 0;

      if (accountId == null || userId == null) {
        throw Exception('Некорректные данные в токене');
      }

      await setSession(accountId: accountId, userId: userId);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('jwt_token', jwtToken);

      notifyListeners();
    } catch (e) {
      print('Ошибка при установке сессии из токена: $e');
      rethrow;
    }
  }

  /// Устанавливает сессию вручную
  Future<void> setSession({required int accountId, required int userId}) async {
    _accountId = accountId;
    _userId = userId;
    _categoryId = 0;
    _account = await _accountService.fetchAccountById(accountId);
    _user = await _userService.fetchUserById(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('account_id', accountId);
    await prefs.setInt('user_id', userId);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _accountId = 0;
    _userId = 0;
    _account = null;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _accountId = 0;
    _userId = 0;
    _categoryId = 0;
    _account = null;
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await SecureStorageHelper.deleteAesKey();
  }
}
