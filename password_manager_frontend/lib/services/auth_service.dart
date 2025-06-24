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

  /// Устанавливает сессию из JWT токена
  Future<void> setSessionFromToken(String jwtToken) async {
    try {
      final jwtPayload = JwtUtil.extractData(jwtToken);
      final aesKey = jwtPayload?['aes_key'];

      if (aesKey == null) {
        throw Exception('AES ключ отсутствует в токене');
      }

      final jwt = JwtUtil.verifyToken(
          jwtToken, aesKey); // Используем aesKey для верификации

      // Используем JwtUtil для работы с токеном
      if (jwt == null || JwtUtil.isTokenExpired(jwt)) {
        throw Exception('Токен недействителен или просрочен');
      }

      // Извлекаем данные из JWT токена
      final _accountId = int.parse(jwt.payload['account_id'].toString());
      final _userId = int.parse(jwt.payload['user_id'].toString());
      final _categoryId = 0;

      // Сохраняем данные сессии
      await setSession(accountId: _accountId, userId: _userId);

      // Сохраняем aesKey в SecureStorage
      await SecureStorageHelper.setAesKey(aesKey);

      // Загружаем дополнительные данные пользователя
      _account = await _accountService.fetchAccountById(_accountId);
      _user = await _userService.fetchUserById(_userId);

      // Сохраняем JWT в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', jwtToken);

      notifyListeners();
    } catch (e) {
      print('Ошибка при установке сессии из токена: $e');
      rethrow;
    }
  }

  /// Устанавливает сессию вручную
  Future<void> setSession({
    required int accountId,
    required int userId,
  }) async {
    if (accountId == 0 || userId == 0) {
      print('ОШИБКА: accountId, userId равны 0');
      throw Exception('Неверные данные: accountId=$accountId, userId=$userId');
    }
    _accountId = accountId;
    _userId = userId;
    _categoryId = 0;

    // Загружаем данные
    _account = await _accountService.fetchAccountById(accountId);
    _user = await _userService.fetchUserById(userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('account_id', accountId);
    await prefs.setInt('user_id', userId);
    // await prefs.setInt('category_id', categoryId);

    notifyListeners();
  }

  /// Очищаем текущую сессию
  Future<void> clearSession() async {
    _accountId = 0;
    _userId = 0;
    _account = null;
    _user = null;

    notifyListeners();
  }

  /// Очищаем текущую сессию
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
