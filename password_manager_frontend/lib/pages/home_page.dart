import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/account.dart';
import 'package:password_manager_frontend/models/user.dart';
import 'package:password_manager_frontend/pages/welcome_preview_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../tabs/emails_tab.dart';
import '../tabs/network_connections_tab.dart';
import '../tabs/websites_tab.dart';
import '../utils/ui_routes.dart';

class HomePage extends StatefulWidget {
  final Account account;
  final User user;

  const HomePage({Key? key, required this.account, required this.user})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBanner = true;

  @override
  Widget build(BuildContext context) {
    final String loginText =
        'Привет, ${widget.user.userName ?? 'пользователь'}';
    final authService = Provider.of<AuthService>(context, listen: false);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(child: Text(loginText)),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Открыть превью',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WelcomePreviewPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Выйти',
                onPressed: () async {
                  authService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      UiRoutes.login,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Электронные почты'),
              Tab(text: 'Сетевые подключения'),
              Tab(text: 'Сайты'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_showBanner)
              MaterialBanner(
                content: const Text('''
                   Вас приветствует команда InIT! 🎉\n
                   Спасибо, что согласились принять участие в альфа-тестировании нашего приложения. Это важный этап, и ваша помощь особенно ценна.\n
                   ⚠️ Важно: не используйте настоящие персональные данные — в случае ошибок они могут быть утеряны.
                    '''),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WelcomePreviewPage()),
                      );
                    },
                    child: const Text('Открыть превью'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showBanner = false),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  EmailsTab(),
                  NetworkConnectionsTab(),
                  WebsitesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
