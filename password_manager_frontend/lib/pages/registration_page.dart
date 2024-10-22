import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hashing_utility_package/hashing_utility.dart'; // Подключение вашего класса HashingUtility
import 'dart:convert';
import '';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    print('Registering with username: $username, email: $email, password: $password');

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Пароли не совпадают'),
      ));
      return;
    }

    // Генерация соли и хэша пароля
    Map<String, String> hashedData = await HashingUtility.hashPassword(password);

    var url = Uri.parse('http://localhost:8080/register');
    var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},  // Отправка данных в формате JSON
        body: jsonEncode({
        'username': username,
        'email': email,
        'password': hashedData['hash'],  // Хэшированный пароль
        'salt': hashedData['salt'],      // Соль
        }),   // Отправляем соль
    );

    if (response.statusCode == 200) {
      print('Регистрация прошла успешно. Server response: ${response.body}');
      Navigator.pop(context); // Registration successful, navigate back to login screen
    } else {
      print('Регистрация прошла неудачно. Server response code: ${response.statusCode}, message: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Регистрация прошла неудачно. Имя пользователя или почта уже используются'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}