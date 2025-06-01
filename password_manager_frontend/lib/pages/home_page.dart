import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/account.dart';
import 'package:password_manager_frontend/models/user.dart';
import '../tabs/emails_tab.dart';
import '../tabs/network_connections_tab.dart';
import '../tabs/websites_tab.dart';

class HomePage extends StatelessWidget {
  final Account account;
  final User user;

  const HomePage({Key? key, required this.account, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String loginText = 'Привет, ${user.userName ?? 'пользователь'}';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loginText),
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