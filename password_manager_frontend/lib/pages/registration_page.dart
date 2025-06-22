import 'package:common_utility_package/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/registration_service.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

final _logger = Logger('RegistrationPage');

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
      // Отправка данных на сервер
      final result = await _registrationService.register(
        accountLogin: _accountLoginController.text.trim(),
        emailAddress: _emailAddressController.text.trim(),
        password: _passwordController.text.trim(),
        userName: _userNameController.text.trim(),
        userPhone: _phoneController.text.trim(),
        userDescription: _descriptionController.text.trim(),
        secretPhrase: _secretPhraseController.text.trim(),
      );

      final accountId = result['account_id'];
      final userId = result['user_id'];
      // final categoryId = result['category_id'];
      final jwtToken = result['jwt_token'];
      final aesKey = result['aes_key'];

      _logger.info(
          'Получены данные при регистрации:', 'Account ID: $accountId');
      _logger.info('Получены данные при регистрации:', 'Account ID: $userId');
      _logger.info('Получены данные при регистрации:', 'Account ID: $aesKey');
      print(
          "Отправляемая секретная фраза: ${_secretPhraseController.text.trim()}");

      if (accountId == null || userId == null || jwtToken == null) {
        throw Exception('Отсутствуют необходимые данные в ответе сервера');
      }

      // await SecureStorageHelper.setAesKey(aesKey);
      // Сохраняем AES ключ в безопасном хранилище
      if (aesKey != null) {
        try {
          await SecureStorageHelper.setAesKey(aesKey);
          print("AES ключ успешно сохранен в безопасном хранилище");
        } catch (e) {
          print("Ошибка при сохранении AES ключа: $e");
          // Не прерываем процесс регистрации из-за ошибки сохранения ключа
        }
      }

      await Provider.of<AuthService>(context, listen: false)
          .setSessionFromToken(jwtToken);

      if (mounted) {
        Navigator.pushReplacementNamed(context, UiRoutes.splash);
      }
    } catch (e) {
      print("Ошибка регистрации: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка регистрации: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
