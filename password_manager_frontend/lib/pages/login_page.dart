import 'package:flutter/material.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/login_service.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/models/account.dart'; // Убедись, что это путь к модели
import 'package:password_manager_frontend/pages/home_page.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountLoginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _loginService = LoginService();
  final _secureStorage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите пароль' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            final result = await _loginService.login(
                              accountLogin: _accountLoginController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            print('DEBUG result: $result');

                            final rawAccountId = result['account_id'];
                            final rawUserId = result['user_id'];
                            final aesKey = result['aes_key'];

                            if (rawAccountId == null || rawUserId == null) {
                              throw Exception(
                                  'account_id или user_id отсутствуют в ответе сервера');
                            }

                            final accountId = rawAccountId is int
                                ? rawAccountId
                                : int.tryParse(rawAccountId.toString());
                            final userId = rawUserId is int
                                ? rawUserId
                                : int.tryParse(rawUserId.toString());

                            if (accountId == null || userId == null) {
                              throw Exception(
                                  'account_id или user_id не удалось преобразовать в int');
                            }

                            // Сохраняем сессию
                            await authService.setSession(
                              accountId: accountId,
                              userId: userId,
                            );

                            // Сохраняем AES-ключ в secure storage
                            if (aesKey != null &&
                                aesKey is String &&
                                aesKey.isNotEmpty) {
                              await _secureStorage.write(
                                  key: 'aes_key', value: aesKey);
                            } else {
                              throw Exception('AES ключ не получен от сервера');
                            }

                            // Загружаем данные аккаунта и пользователя
                            final account = await AccountService()
                                .fetchAccountById(accountId);
                            final user =
                                await UserService().fetchUserById(userId);

                            print(
                                "DEBUG Account (после fetch): ${account.toJson()}");

                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(
                                  account: account,
                                  user: user,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка входа: $e')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Войти'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, UiRoutes.register),
                child: const Text('Нет аккаунта? Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
