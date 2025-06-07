import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/pages/home_page.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/registration_service.dart';
import 'package:hashing_utility_package/hashing_utility.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:provider/provider.dart';

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

  bool _isLoading = false;
  final _registrationService = RegistrationService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

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
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Введите логин аккаунта'
                    : null,
              ),
              TextFormField(
                controller: _userNameController,
                decoration:
                    const InputDecoration(labelText: 'Имя пользователя'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Введите имя пользователя'
                    : null,
              ),
              TextFormField(
                controller: _emailAddressController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Введите email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Телефон (необязательно)'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Описание пользователя (необязательно)'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Введите пароль' : null,
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            final result = await _registrationService.register(
                              accountLogin: _accountLoginController.text.trim(),
                              userName: _userNameController.text.trim(),
                              emailAddress: _emailAddressController.text.trim(),
                              userPhone: _phoneController.text.trim().isEmpty
                                  ? null
                                  : _phoneController.text.trim(),
                              userDescription:
                                  _descriptionController.text.trim().isEmpty
                                      ? null
                                      : _descriptionController.text.trim(),
                              password: _passwordController.text,
                            );

                            await authService.setSession(
                              accountId: result['account_id'],
                              userId: result['user_id'],
                            );
                            final account = await AccountService()
                                .fetchAccountById(result['account_id']);
                            final user = await UserService()
                                .fetchUserById(result['user_id']);

                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HomePage(account: account, user: user),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка регистрации: $e')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
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
