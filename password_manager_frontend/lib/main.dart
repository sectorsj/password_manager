import 'package:flutter/material.dart';
import 'package:password_manager_frontend/pages/splash_screen_page.dart';
import 'pages/registration_page.dart';
import 'pages/login_page.dart';
import 'pages/home_tabs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreenPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/home-tabs': (context) => const HomeTabs(),
      },
    );
  }
}