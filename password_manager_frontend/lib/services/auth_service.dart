import 'package:flutter/material.dart';
import 'package:hashing_utility_package/secure_storage_helper.dart';
import 'package:password_manager_frontend/models/account.dart';
import 'package:password_manager_frontend/models/user.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthService
///  Хранит accountId и userId.
///  Отвечает за setSession(), logout(), isLoggedIn().
///  Работает как провайдер состояния.

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

  void setCategoryId(int id) {
    _categoryId = id;
    notifyListeners();
  }

  Future<void> setSession({required int accountId, required int userId}) async {
    if (accountId == 0 || userId == 0) {
      print('ОШИБКА: accountId или userId равны 0');
      throw Exception('Неверные данные: accountId=$accountId, userId=$userId');
    }
    _accountId = accountId;
    _userId = userId;
    _categoryId = 0;

    // Загружаем дополнительные данные
    _account = await _accountService.fetchAccountById(accountId);
    _user = await _userService.fetchUserById(userId);

    notifyListeners();
  }

  void clearSession() {
    _accountId = 0;
    _userId = 0;
    _account = null;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _accountId = 0;
    _userId = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_id');
    await prefs.remove('user_id');
    // Удаление AES ключа
    await SecureStorageHelper.deleteAesKey(); // ← удаляем AES-ключ
  }

  bool get isLoggedIn => accountId != 0 && _userId != 0;
}
