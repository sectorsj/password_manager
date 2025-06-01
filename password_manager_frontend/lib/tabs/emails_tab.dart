import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/email_service.dart';
import 'package:password_manager_frontend/pages/email_form_page.dart';
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
  Map<int, bool> _showPasswordMap = {};  // Отображение пароля для каждого элемента

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {

    List<Email> emails = await emailService.getEmails(1);
    setState(() {
      _emails = emails;
    });
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
                Text('Salt: ${email.salt}'),
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

  void _addEmail(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    int accountId = authService.accountId;
    int categoryId = authService.categoryId;
    int userId = authService.userId;

    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmailFormPage(accountId: accountId, categoryId: categoryId, userId: userId)),
    );
    _loadEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emails'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addEmail(context)
          ),
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

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(email.emailAddress)),  // email_address
                DataCell(Row(
                  children: [
                    // Отображаем пароль или скрываем его
                    Text(_showPassword
                        ? (email.passwordHash != null
                          ? String.fromCharCodes(email.passwordHash!)
                        : '[нет пароля]')
                      : '****',
                    ),
                    IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPasswordMap[index] = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(
                                text: email.passwordHash != null
                                    ? base64Encode(email.passwordHash!)
                                    : '',
                            ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
                DataCell(Text(email.emailDescription ?? '')),  // email_description
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}