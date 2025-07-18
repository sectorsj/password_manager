import 'package:flutter/material.dart';
import 'package:password_manager_frontend/pages/home_page.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/pages/splash_screen_page.dart';
import 'package:password_manager_frontend/pages/login_page.dart';
import 'package:password_manager_frontend/pages/registration_page.dart';
import 'package:password_manager_frontend/services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер паролей',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: UiRoutes.splash,
      routes: {
        UiRoutes.splash: (_) => const SplashScreenPage(),
        UiRoutes.login: (_) => const LoginPage(),
        UiRoutes.register: (_) => const RegistrationPage(),
        UiRoutes.home: (_) {
          final authService = Provider.of<AuthService>(context, listen: false);
          return authService.isLoggedIn
              ? HomePage(account: authService.account!, user: authService.user!)
              : const LoginPage(); // Если сессия не активна, показываем LoginPage
        },
      },
    );
  }
}
