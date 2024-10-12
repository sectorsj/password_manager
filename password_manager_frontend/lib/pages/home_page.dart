import 'package:flutter/material.dart';
import 'emails_tab.dart';
import 'network_connections_tab.dart';
import 'websites_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Password Manager'),
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