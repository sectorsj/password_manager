import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/services/website_service.dart';

class WebsitesTab extends StatefulWidget {
  const WebsitesTab({Key? key}) : super(key: key);

  @override
  _WebsitesTabState createState() => _WebsitesTabState();
}

class _WebsitesTabState extends State<WebsitesTab> {
  final WebsiteService websiteService = WebsiteService();
  List<dynamic> websites = [];
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    List<dynamic> result = await websiteService.getWebsitesByAccount(
        1); // Пример ID аккаунта
    setState(() {
      websites = result;
    });
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
            DataColumn(label: Text('Имя пользователя')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Пароль')),
          ],
          rows: websites
              .asMap()
              .entries
              .map((entry) {
            int index = entry.key + 1;
            var website = entry.value;

            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(website[1])), // website_name
                DataCell(Text(website[2])), // url
                DataCell(Text(website[3])), // login
                DataCell(Text(website[4])), // email
                DataCell(Row(
                  children: [
                    Text(_showPassword ? website[5] : '****'), // пароль
                    IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons
                          .visibility),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: website[5]));
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