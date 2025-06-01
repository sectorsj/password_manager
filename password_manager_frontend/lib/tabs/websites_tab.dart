import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/models/website.dart';
import 'package:password_manager_frontend/services/website_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';

class WebsitesTab extends StatefulWidget {
  const WebsitesTab({Key? key}) : super(key: key);

  @override
  _WebsitesTabState createState() => _WebsitesTabState();
}

class _WebsitesTabState extends State<WebsitesTab> {
  final WebsiteService websiteService = WebsiteService();
  List<Website> _websites = [];
  Map<int, bool> _showPasswordMap = {}; // состояние отображения пароля

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;

    try {
      final websites = await websiteService.getWebsitesByUser(userId);
      setState(() {
        _websites = websites;
      });
    } catch (e) {
      print('Ошибка при загрузке сайтов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить сайты')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Websites'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Название сайта')),
            DataColumn(label: Text('URL')),
            DataColumn(label: Text('Логин')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Пароль')),
          ],
          rows: _websites.asMap().entries.map((entry) {
            final index = entry.key;
            final website = entry.value;
            final showPassword = _showPasswordMap[index] ?? false;
            final passwordStr = utf8.decode(website.passwordHash);

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(website.websiteName)),
                DataCell(Text(website.websiteUrl)),
                DataCell(Text(website.websiteLogin)),
                DataCell(Text(website.websiteEmail ?? '')),
                DataCell(Row(
                  children: [
                    Text(showPassword ? passwordStr : '****'),
                    IconButton(
                      icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPasswordMap[index] = !showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: passwordStr));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}