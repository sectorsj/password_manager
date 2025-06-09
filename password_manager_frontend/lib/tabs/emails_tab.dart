import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для копирования пароля
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/email_service.dart';
import 'package:password_manager_frontend/widgets/add_email_form_widget.dart';
import 'package:provider/provider.dart';

class EmailsTab extends StatefulWidget {
  const EmailsTab({Key? key}) : super(key: key);

  @override
  _EmailsTabState createState() => _EmailsTabState();
}

class _EmailsTabState extends State<EmailsTab> {
  // final ApiService apiService = ApiService();
  final EmailService emailService = EmailService();
  List<Email> _emails = [];
  Map<int, bool> _showPasswordMap =
      {}; // Отображение пароля для каждого элемента
  Map<int, String> _decryptedPasswords = {};

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    int userId = authService.userId;

    try {
      List<Email> emails = await emailService.getEmails(userId);
      setState(() {
        _emails = emails;
      });
    } catch (e) {
      print('Ошибка при загрузке email-ов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Не удалось загрузить список электронных почт (emails)')),
      );
    }
  }

  void _showEmailDetails(BuildContext context, Email email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(email.emailAddress),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${email.emailDescription}'),
              // Text('Salt: ${email.salt}'),
              Text('Category ID: ${email.categoryId}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _togglePasswordVisibility(int index, Email email) async {
    final isVisible = _showPasswordMap[index] ?? false;

    if (!isVisible && !_decryptedPasswords.containsKey(index)) {
      try {
        final decrypted = await emailService.getDecryptedPassword(email.id);
        setState(() {
          _decryptedPasswords[index] = decrypted;
          _showPasswordMap[index] = true;
        });
      } catch (e) {
        print('Ошибка при расшифровке пароля: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось расшифровать пароль')),
        );
      }
    } else {
      setState(() {
        _showPasswordMap[index] = !isVisible;
      });
    }
  }

  void _addEmail(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    int accountId = authService.accountId;
    int categoryId = authService.categoryId;
    int userId = authService.userId;

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEmailFormWidget(
              accountId: accountId,
              // categoryId: categoryId,
              categoryId: 2,
              //  // 💡 вручную ставим "почты"
              // TODO внедрить TabController в HomePage и связывать вкладки с ID категорий.
              userId: userId)),
    );
    _loadEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронные почты'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: () => _addEmail(context)),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Пароль')),
            DataColumn(label: Text('Описание')),
          ],
          rows: _emails.asMap().entries.map((entry) {
            int index = entry.key;
            Email email = entry.value;

            // Получаем текущее состояние отображения пароля
            bool _showPassword = _showPasswordMap[index] ?? false;
            String decryptedPassword = _decryptedPasswords[index] ?? '';
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(email.emailAddress)),
                // email_address
                DataCell(Row(
                  children: [
                    // Отображаем пароль или скрываем его
                    Text(
                      _showPassword
                          ? (decryptedPassword.isNotEmpty
                              ? decryptedPassword
                              : '[пароль загружается]')
                          : '****',
                    ),
                    IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            _togglePasswordVisibility(index, email)),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: decryptedPassword),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
                DataCell(Text(email.emailDescription ?? '')),
                // email_description
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
