import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../utils/ui_routes.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkSession(); // Проверка сессии при старте
  }

  Future<void> _checkSession() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Инициализируем AuthService для проверки сессии
    await authService.initialize();

    // Проверяем
    // Если сессия активна
    if (authService.isLoggedIn) {
      // Если сессия активна, сразу переходим на HomePage
      Navigator.pushReplacementNamed(context, UiRoutes.home);
    } else {
      // Иначе показываем страницу логина
      Navigator.pushReplacementNamed(context, UiRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 100.0,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'МЕНЕДЖЕР ПАРОЛЕЙ',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
