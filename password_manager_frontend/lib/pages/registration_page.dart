import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:common_utility_package/hashing_utility.dart';
import 'package:common_utility_package/secure_storage_helper.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/registration_service.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:password_manager_frontend/pages/home_page.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:logging/logging.dart';

// final _logger = Logger('RegisterRoute');

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _accountLoginController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _secretPhraseController = TextEditingController();

  bool _isLoading = false;
  final _registrationService = RegistrationService();

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final secretPhrase = _secretPhraseController.text.trim();

      // Генерация AES ключа на основе секретной фразы
      final aesKey = await HashingUtility.deriveAesKeyFromSecret(secretPhrase);

      print('Debug: accountLogin=${_accountLoginController.text.trim()}');
      print('Debug: emailAddress=${_emailAddressController.text.trim()}');
      print('Debug: password=${_passwordController.text.trim()}');
      print('Debug: secretphrase=$secretPhrase');
      print('Debug: aesKey=$aesKey');

      // Проверка, что все поля заполнены
      if (_accountLoginController.text.trim().isEmpty ||
          _emailAddressController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        throw Exception('Логин, email и пароль обязательны для регистрации');
      }

      final result = await _registrationService.register(
        accountLogin: _accountLoginController.text.trim(),
        emailAddress: _emailAddressController.text.trim(),
        password: _passwordController.text.trim(),
        userName: _userNameController.text.trim(),
        userPhone: _phoneController.text.trim(),
        userDescription: _descriptionController.text.trim(),
        aesKeyBase64: HashingUtility.toBase64(aesKey),
      );

      final accountId = result['account_id'];
      final userId = result['user_id'];

      if (accountId == null || userId == null) {
        throw Exception('Отсутствуют необходимые данные в ответе сервера');
      }

      // Сохраняем AES-ключ в безопасное хранилище
      await SecureStorageHelper.setAesKey(HashingUtility.toBase64(aesKey));

      // Устанавливаем сессию
      await setSession(accountId: accountId, userId: userId);

      final account = await AccountService().fetchAccountById(accountId);
      final user = await UserService().fetchUserById(userId);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(account: account, user: user),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Метод для установки сессии с данными accountId и userId
  Future<void> setSession({required int accountId, required int userId}) async {
    if (accountId == 0 || userId == 0) {
      print('ОШИБКА: accountId или userId равны 0');
      throw Exception('Неверные данные: accountId=$accountId, userId=$userId');
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.setSession(accountId: accountId, userId: userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('account_id', accountId);
    await prefs.setInt('user_id', userId);
  }

  // Метод для установки сессии из JWT токена
  Future<void> setSessionFromToken(String jwtToken) async {
    try {
      final payload = Jwt.parseJwt(jwtToken); // Парсим JWT

      // Извлекаем accountId и userId
      final accountId = int.parse(payload['account_id'].toString());
      final userId = int.parse(payload['user_id'].toString());
      final aesKey = payload['aes_key'];

      if (aesKey is String) {
        await SecureStorageHelper.setAesKey(
            aesKey); // Сохраняем aesKey в SecureStorage
      }

      // Устанавливаем сессию
      await setSession(accountId: accountId, userId: userId);
    } catch (e) {
      print('Ошибка при установке сессии из токена: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _accountLoginController,
                decoration: const InputDecoration(labelText: 'Логин аккаунта'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите логин' : null,
              ),
              TextFormField(
                controller: _userNameController,
                decoration:
                    const InputDecoration(labelText: 'Имя пользователя'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _emailAddressController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите пароль' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Подтвердите пароль'),
                obscureText: true,
                validator: (value) => value != _passwordController.text
                    ? 'Пароли не совпадают'
                    : null,
              ),
              TextFormField(
                controller: _secretPhraseController,
                decoration: const InputDecoration(labelText: 'Секретная фраза'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Введите секретную фразу'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, UiRoutes.login),
                child: const Text('Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
