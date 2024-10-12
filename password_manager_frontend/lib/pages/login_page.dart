import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager_frontend/pages/home_page.dart';
import 'package:password_manager_frontend/pages/registration_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    var url = Uri.parse('http://localhost:8080/login');
    var response = await http.post(url, body: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      print('Login successful. Server response: ${response.body}');
      // Login successful, navigate to home screen or tabs screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      print('Login failed. Server response code: ${response.statusCode}, message: ${response.body}');
      // Show error message or handle invalid credentials
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Не верное имя пользователя или пароль'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationPage()));
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}