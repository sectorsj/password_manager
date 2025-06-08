import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/account.dart';
import 'package:password_manager_frontend/models/user.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../tabs/emails_tab.dart';
import '../tabs/network_connections_tab.dart';
import '../tabs/websites_tab.dart';
import '../utils/ui_routes.dart';

class HomePage extends StatelessWidget {
  final Account account;
  final User user;

  const HomePage({Key? key, required this.account, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String loginText = 'Привет, ${user.userName ?? 'пользователь'}';
    final authService = Provider.of<AuthService>(context, listen: false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // ❌ отключаем стрелку назад
          title: Text(loginText),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () async {
                authService.logout(); // удалит и session, и aes_key
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Emails'),
              Tab(text: 'Network Connections'),
              Tab(text: 'Websites'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmailsTab(),
            NetworkConnectionsTab(),
            WebsitesTab(),
          ],
        ),
      ),
    );
  }
}
