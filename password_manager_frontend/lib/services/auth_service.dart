import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  int _accountId = 0;
  int _categoryId = 0;
  int _userId = 0;

  int get accountId => _accountId;
  int get categoryId => _categoryId;
  int get userId => _userId;

  void setAccountData(int accountId, int categoryId, int userId) {
    _accountId = accountId;
    _categoryId = categoryId;
    _userId = userId;
    notifyListeners();
  }
}