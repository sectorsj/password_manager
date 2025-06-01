import 'package:flutter/material.dart';
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreenPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegistrationPage(),
      },
    );
  }
}