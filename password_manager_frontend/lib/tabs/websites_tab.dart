import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/models/website.dart';
import 'package:password_manager_frontend/services/website_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/widgets/add_website_form_widget.dart';

class WebsitesTab extends StatefulWidget {
  const WebsitesTab({Key? key}) : super(key: key);

  @override
  _WebsitesTabState createState() => _WebsitesTabState();
}

class _WebsitesTabState extends State<WebsitesTab> {
  final WebsiteService websiteService = WebsiteService();
  List<Website> _websites = [];
  Map<int, bool> _showPasswordMap = {};
  Map<int, String> _decryptedPasswords = {};

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
      if (!mounted) return;
      setState(() {
        _websites = websites;
      });
    } catch (e) {
      if (!mounted) return;
      print('Ошибка при загрузке сайтов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить сайты')),
      );
    }
  }

  Future<void> _togglePasswordVisibility(int index, Website website) async {
    final isVisible = _showPasswordMap[index] ?? false;

    if (!isVisible && !_decryptedPasswords.containsKey(index)) {
      try {
        final decrypted = await websiteService.getDecryptedPassword(website.id);
        if (!mounted) return;
        setState(() {
          _decryptedPasswords[index] = decrypted;
          _showPasswordMap[index] = true;
        });
      } catch (e) {
        if (!mounted) return;
        print('Ошибка при расшифровке пароля: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось расшифровать пароль')),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        _showPasswordMap[index] = !isVisible;
      });
    }
  }

  void _showWebsiteDetails(BuildContext context, Website website) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(website.websiteName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('URL: ${website.websiteUrl}'),
              Text('Логин: ${website.nickname ?? '—'}'),
              Text('Email: ${website.websiteEmail ?? '—'}'),
              Text('Описание: ${website.websiteDescription ?? '—'}'),
              Text('Категория: ${website.categoryId}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _addWebsite(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final accountId = authService.accountId;
    final categoryId = authService.categoryId;
    final userId = authService.userId;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWebsiteFormWidget(
          accountId: accountId,
          categoryId: 2,
          // 💡 фиксированная категория "Сайты" // TODO внедрить TabController в HomePage и связывать вкладки с ID категорий.
          userId: userId,
        ),
      ),
    );
    _loadWebsites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сайты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addWebsite(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Название')),
            DataColumn(label: Text('URL')),
            DataColumn(label: Text('Логин')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Пароль')),
            DataColumn(label: Text('Подробнее')),
          ],
          rows: _websites.asMap().entries.map((entry) {
            final index = entry.key;
            final website = entry.value;
            final isVisible = _showPasswordMap[index] ?? false;
            final decrypted = _decryptedPasswords[index] ?? '';

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(website.websiteName)),
                DataCell(Text(website.websiteUrl)),
                DataCell(Text(website.nickname ?? '—')),
                DataCell(Text(website.websiteEmail ?? '—')),
                DataCell(Row(
                  children: [
                    Text(
                      isVisible
                          ? (decrypted.isNotEmpty ? decrypted : '[загрузка]')
                          : '****',
                    ),
                    IconButton(
                      icon: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          _togglePasswordVisibility(index, website),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (decrypted.isNotEmpty) {
                          Clipboard.setData(
                            ClipboardData(text: decrypted),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пароль скопирован')),
                          );
                        }
                      },
                    ),
                  ],
                )),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showWebsiteDetails(context, website),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
