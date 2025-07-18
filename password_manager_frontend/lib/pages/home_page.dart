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

  const HomePage({super.key, required this.account, required this.user});

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

        // ✅ Тело приложения
        body: const TabBarView(
          children: [
            EmailsTab(),
            NetworkConnectionsTab(),
            WebsitesTab(),
          ],
        ),

        // ✅ Баннер — ниже AppBar, выше TabBarView
        persistentFooterButtons: _showBanner
            ? [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Stack(
                    children: [
                      // 🔺 Закрыть (в правом верхнем углу)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showBanner = false),
                          tooltip: 'Закрыть',
                        ),
                      ),
                      // 🔹 Содержимое баннера
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, right: 32),
                            child: Text(
                              'Вас приветствует команда InIT! 🎉\n\n'
                              'Спасибо, что согласились принять участие в альфа-тестировании нашего приложения. '
                              'Это важный этап, и ваша помощь особенно ценна.\n\n'
                              '⚠️ Пожалуйста, не используйте настоящие персональные данные — '
                              'в случае ошибок они могут быть безвозвратно утеряны.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const WelcomePreviewPage()),
                                );
                              },
                              child: const Text('Подробнее'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
