import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordsMatch = true;

  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);

      Navigator.pop(context);  // Возвращаемся на страницу логина
    } else {
      setState(() {
        _passwordsMatch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Имя пользователя'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (!_passwordsMatch)
              const Text(
                'Пароли не совпадают',
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}